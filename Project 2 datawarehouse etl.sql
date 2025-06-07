-- ETL Script for Property Management Data Warehouse
-- This script extracts data from the PropertyManagement2 operational database
-- and loads it into the dimensional model for analytics
USE PropertyManagement2;

-- Step 1: Populate Dimension Tables
-- ====================================================
-- 1.1 Populate Dim_Date table 
-- This creates date entries from 2022-01-01 to 2025-12-31
DROP PROCEDURE IF EXISTS PopulateDateDimension;
DELIMITER $$

CREATE PROCEDURE PopulateDateDimension()
BEGIN
    DECLARE start_date DATE DEFAULT '2022-01-01';	-- Start Date can be adjusted as needed
    DECLARE end_date   DATE DEFAULT '2025-12-31';	-- End Date can be adjusted as needed
    DECLARE curr_date  DATE DEFAULT start_date;		
	
    -- Clear existing data from DimDate table
    DELETE FROM `Dim_Date`
     WHERE DateKey > 0;
    ALTER TABLE `Dim_Date` AUTO_INCREMENT = 1;

    WHILE curr_date <= end_date DO
        INSERT IGNORE INTO `Dim_Date` (
            `Date`,`Week`,`Month`,`Quarter`,`Year`,
            `DayOfWeek`,`DayOfMonth`,`FiscalYear`
        ) VALUES (
            curr_date,
            WEEKOFYEAR(curr_date),
            MONTH(curr_date),
            QUARTER(curr_date),
            YEAR(curr_date),
            DAYOFWEEK(curr_date),
            DAYOFMONTH(curr_date),
            CASE WHEN MONTH(curr_date)>=7 	-- Assuming the fiscal year starts in July
                 THEN YEAR(curr_date)+1 
                 ELSE YEAR(curr_date)
            END
        );
        SET curr_date = DATE_ADD(curr_date, INTERVAL 1 DAY);	-- Increment by 1 day
    END WHILE;
END$$

DELIMITER ;

CALL PopulateDateDimension();

-- 1.2 Populate Dim_Status table
INSERT INTO Dim_Status (StatusCode, StatusDescription) VALUES
('OPEN', 'Open request awaiting assignment'),
('PROG', 'In progress and being worked on'),
('COMP', 'Completed successfully'),
('CANC', 'Cancelled or unnecessary');

-- 1.3 Populate Dim_ServiceType table
INSERT INTO Dim_ServiceType (ServiceTypeCode, ServiceTypeName) VALUES
('INSP', 'Building Inspection'),
('CLEAN', 'Apartment Cleaning'),
('MAINT', 'Maintenance Request');

-- 1.4 Populate Dim_Building (with Slowly Changing Dimension Type 2 handling)
INSERT INTO Dim_Building (
    BuildingID, BuildingAddress, ManagerID, ManagerFullName, ManagerPhone, ManagerEmail, 
    EffectiveDate, EndDate, IsCurrent
)
SELECT 
    b.BuildingID,
    CONCAT(b.Street, ', ', b.City, ', ', b.State, ' ', b.ZipCode) AS BuildingAddress,
    m.ManagerID,
    CONCAT(m.MFirstName, ' ', m.MLastName) AS ManagerFullName,
    -- Get the first phone number for each manager
    (SELECT mp.MPhoneNo FROM ManagerPhone mp WHERE mp.ManagerID = m.ManagerID LIMIT 1) AS ManagerPhone,
    m.MEmail,
    '2022-01-01' AS EffectiveDate, -- Starting point for our data
    NULL AS EndDate,
    TRUE AS IsCurrent
FROM Building b
JOIN Manager m ON b.ManagerIDOversees = m.ManagerID;

-- 1.5 Populate Dim_Apartment
INSERT INTO Dim_Apartment (
    BuildingID, ApartmentNumber, NumberOfBedrooms, CurrentStatus
)
SELECT
    BuildingID, ApartmentNo, NoOfBedrooms, RentalStatus
FROM Apartment;

-- 1.6 Populate Dim_CorporateClient
INSERT INTO Dim_CorporateClient (
    CCID, CorpClientName, CCIndustry, CCEmail, CCReferredBy
)
SELECT
    CCID, CCName, CCIndustry, CCEmail, CIDReferedBy
FROM CorporateClient;

-- 1.7 Populate Dim_Employee (combining Staff and Inspectors)
-- Insert Staff Members
INSERT INTO Dim_Employee (
    EmployeeID, EmployeeFullName, EmployeeEmail, EmployeeRole
)
SELECT
    StaffID,
    CONCAT(SFirstName, ' ', SLastName) AS EmployeeFullName,
    SEmail,
    'Staff' AS EmployeeRole
FROM StaffMember;

-- Insert Inspectors
INSERT INTO Dim_Employee (
    EmployeeID, EmployeeFullName, EmployeeEmail, EmployeeRole
)
SELECT
    InspectorID,
    CONCAT(IFirstName, ' ', ILastName) AS EmployeeFullName,
    IEmail,
    'Inspector' AS EmployeeRole
FROM Inspector;

-- Step 2: Populate Fact Tables
-- =============================================================
-- 2.1 Populate Fact_Lease
INSERT INTO Fact_Lease (
    ClientKey, DateKey, ApartmentKey, BuildingKey, LeaseID, MonthlyRent, SecurityDeposit, 
    LeaseDuration, LeaseStartDate, LeaseEndDate, RevenueGenerated
)
SELECT
    dc.ClientKey, dd.DateKey, da.ApartmentKey, db.BuildingKey, l.LeaseID, 
    l.MonthlyRent, l.SecurityDeposit,
    DATEDIFF(l.LeaseEndDate, l.LeaseStartDate) AS LeaseDuration,
    l.LeaseStartDate, l.LeaseEndDate,
    -- Calculate total revenue as months * monthly rent
    (TIMESTAMPDIFF(MONTH, l.LeaseStartDate, l.LeaseEndDate) * l.MonthlyRent) AS RevenueGenerated
FROM Lease l
JOIN Dim_CorporateClient dc ON l.CCID = dc.CCID
JOIN Dim_Date dd ON dd.Date = l.LeaseStartDate
JOIN Dim_Apartment da ON l.ApartmentNo = da.ApartmentNumber AND l.BuildingID = da.BuildingID
JOIN Dim_Building db ON l.BuildingID = db.BuildingID AND db.IsCurrent = TRUE;

-- 2.2 Populate Fact_Service (combining Maintenance, Cleaning, and Inspections)
-- ============================================
-- Insert Maintenance Requests
INSERT INTO Fact_Service (
    StaffKey, DateKey, ApartmentKey, BuildingKey, StatusKey, ServiceTypeKey, RequestID,
    TotalRequests, CompletedRequests, AvgResolutionDays, DurationDays, Next_Insp_Date,
    TotalNoOfInspections
)
SELECT
    de.EmployeeKey, dd.DateKey, da.ApartmentKey, db.BuildingKey,
    -- Map status to status key
    (SELECT StatusKey FROM Dim_Status WHERE 
        CASE 
            WHEN mr.Status = 'Open' THEN StatusCode = 'OPEN'
            WHEN mr.Status = 'In Progress' THEN StatusCode = 'PROG'
            WHEN mr.Status = 'Completed' THEN StatusCode = 'COMP'
            ELSE StatusCode = 'CANC'
        END
    ) AS StatusKey,
    -- Service Type for Maintenance
    (SELECT ServiceTypeKey FROM Dim_ServiceType WHERE ServiceTypeCode = 'MAINT') AS ServiceTypeKey,
    mr.RequestID,
    1 AS TotalRequests, -- Each record is one request
    CASE WHEN mr.Status = 'Completed' THEN 1 ELSE 0 END AS CompletedRequests,
    -- Calculate resolution days only for completed requests
    CASE 
        WHEN mr.CompletedDate IS NOT NULL THEN DATEDIFF(mr.CompletedDate, mr.RequestDate)
        ELSE 0
    END AS AvgResolutionDays,
    -- Calculate duration (completed or current duration)
    CASE 
        WHEN mr.CompletedDate IS NOT NULL THEN DATEDIFF(mr.CompletedDate, mr.RequestDate)
        ELSE DATEDIFF(CURRENT_DATE(), mr.RequestDate)
    END AS DurationDays,
    -- Not applicable for maintenance requests
    '2999-12-31' AS Next_Insp_Date,		-- common placeholder for non-applicable field
    0 AS TotalNoOfInspections
FROM MaintenanceRequest mr
JOIN Dim_Employee de ON mr.AssignedStaff = de.EmployeeID
JOIN Dim_Date dd ON dd.Date = mr.RequestDate
JOIN Dim_Apartment da ON mr.ApartmentNo = da.ApartmentNumber AND mr.BuildingID = da.BuildingID
JOIN Dim_Building db ON mr.BuildingID = db.BuildingID AND db.IsCurrent = TRUE;

-- Insert Cleaning Records
INSERT INTO Fact_Service (
    StaffKey, DateKey, ApartmentKey, BuildingKey, StatusKey, ServiceTypeKey, RequestID,
    TotalRequests, CompletedRequests, AvgResolutionDays, DurationDays, Next_Insp_Date,
    TotalNoOfInspections
)
SELECT
    de.EmployeeKey,
    -- Use a reference date since cleaning doesn't have specific dates
    (SELECT DateKey FROM Dim_Date WHERE Date = '2024-01-01') AS DateKey,
    da.ApartmentKey,
    db.BuildingKey,
    -- Default to completed for cleaning assignments
    (SELECT StatusKey FROM Dim_Status WHERE StatusCode = 'COMP') AS StatusKey,
    -- Service Type for Cleaning
    (SELECT ServiceTypeKey FROM Dim_ServiceType WHERE ServiceTypeCode = 'CLEAN') AS ServiceTypeKey,
    -- Generate a synthetic request ID for cleaning
    100000 + ROW_NUMBER() OVER (ORDER BY c.BuildingID, c.ApartmentNo) AS RequestID,
    1 AS TotalRequests,
    1 AS CompletedRequests, -- Assume all cleanings are completed
    0 AS AvgResolutionDays, -- Not applicable
    0 AS DurationDays, -- Not applicable
    '2999-12-31' AS Next_Insp_Date, -- Not applicable
    0 AS TotalNoOfInspections -- Not applicable
FROM Cleans c
JOIN Dim_Employee de ON c.StaffID = de.EmployeeID
JOIN Dim_Apartment da ON c.ApartmentNo = da.ApartmentNumber AND c.BuildingID = da.BuildingID
JOIN Dim_Building db ON c.BuildingID = db.BuildingID AND db.IsCurrent = TRUE;

-- Insert Inspection Records
INSERT INTO Fact_Service (
    StaffKey, DateKey, ApartmentKey, BuildingKey, StatusKey, ServiceTypeKey, RequestID,
    TotalRequests, CompletedRequests, AvgResolutionDays, DurationDays, Next_Insp_Date,
    TotalNoOfInspections
)
SELECT
    de.EmployeeKey,
    dd.DateKey,
    -- Not tied to an apartment, use a default value
    (SELECT MIN(ApartmentKey) FROM Dim_Apartment WHERE BuildingID = i.BuildingID) AS ApartmentKey,
    db.BuildingKey,
    -- Default to completed for past inspections
    (SELECT StatusKey FROM Dim_Status WHERE StatusCode = 'COMP') AS StatusKey,
    -- Service Type for Inspection
    (SELECT ServiceTypeKey FROM Dim_ServiceType WHERE ServiceTypeCode = 'INSP') AS ServiceTypeKey,
    -- Generate a synthetic request ID for inspections
    200000 + ROW_NUMBER() OVER (ORDER BY i.BuildingID, i.InspectorID) AS RequestID,
    1 AS TotalRequests,
    1 AS CompletedRequests, -- All recorded inspections are completed
    0 AS AvgResolutionDays, -- Not applicable
    0 AS DurationDays, -- Not applicable
    i.Next_Insp_date,
    1 AS TotalNoOfInspections
FROM Inspects i
JOIN Dim_Employee de ON i.InspectorID = de.EmployeeID
JOIN Dim_Date dd ON dd.Date = i.Date_Completed
JOIN Dim_Building db ON i.BuildingID = db.BuildingID AND db.IsCurrent = TRUE;

-- Step 3: Create Stored Procedures to Simulate SCD Type 2 Changes for Building-Manager Relationship
-- =============================================
-- Procedure to update Building-Manager relationships with SCD Type 2
DROP PROCEDURE IF EXISTS UpdateBuildingManager;
DELIMITER $$
CREATE PROCEDURE UpdateBuildingManager(
  IN p_BuildingID    CHAR(5),
  IN p_NewManagerID  CHAR(5),
  IN p_EffectiveDate DATE
)
BEGIN
  DECLARE vDimKey          INT;
  DECLARE vManagerFullName VARCHAR(100);
  DECLARE vManagerPhone    VARCHAR(20);
  DECLARE vManagerEmail    VARCHAR(100);

  -- 1) grab the current row’s primary key
  SELECT BuildingKey INTO vDimKey FROM Dim_Building
  WHERE BuildingID = p_BuildingID
    AND IsCurrent  = TRUE
  LIMIT 1;

  -- 2) pull new manager info
  SELECT CONCAT(MFirstName,' ',MLastName),
    (SELECT MPhoneNo FROM ManagerPhone WHERE ManagerID = p_NewManagerID ORDER BY MPhoneNo
      LIMIT 1),
    MEmail
  INTO vManagerFullName, vManagerPhone, vManagerEmail
  FROM Manager
  WHERE ManagerID = p_NewManagerID;

  -- 3) “close” the old dimension row by PK
  UPDATE Dim_Building
     SET EndDate   = DATE_SUB(p_EffectiveDate, INTERVAL 1 DAY),
         IsCurrent = FALSE
   WHERE BuildingKey = vDimKey;

  -- 4) insert the new current row
  INSERT INTO Dim_Building (
    BuildingID, BuildingAddress, ManagerID, ManagerFullName,
    ManagerPhone, ManagerEmail, EffectiveDate, EndDate, IsCurrent
  )
  SELECT 
    b.BuildingID, CONCAT(b.Street, ', ', b.City, ', ', b.State, ' ', b.ZipCode),
    m.ManagerID, vManagerFullName, vManagerPhone, vManagerEmail, p_EffectiveDate,
    NULL, TRUE
  FROM Building AS b
  JOIN Manager  AS m ON m.ManagerID = p_NewManagerID
  WHERE b.BuildingID = p_BuildingID;

  -- 5) sync the OLTP table
  UPDATE Building
     SET ManagerIDOversees = p_NewManagerID
   WHERE BuildingID = p_BuildingID;
END$$
DELIMITER ;

-- Step 4: Sample Dimensional Model Updates
-- =============================================
-- Simulate a manager change to demonstrate SCD Type 2
CALL UpdateBuildingManager('B0003','M0004','2024-06-01');
CALL UpdateBuildingManager('B0008','M0002','2024-07-15');
CALL UpdateBuildingManager('B0001','M0007','2024-11-01');

-- Step 5: Update Fact tables to Reflect Current Building Keys where Manager Changed
-- =============================================
-- Update Fact_Lease to use current Building keys
UPDATE Fact_Lease fl
JOIN Dim_Building db ON fl.BuildingKey = db.BuildingKey
SET fl.BuildingKey = (
    SELECT MAX(BuildingKey) FROM Dim_Building 
    WHERE BuildingID = db.BuildingID AND IsCurrent = TRUE
)
WHERE EXISTS (
    SELECT 1 FROM Dim_Building 
    WHERE BuildingID = db.BuildingID AND IsCurrent = TRUE AND BuildingKey != fl.BuildingKey
);

-- Update Fact_Service to use current Building keys
UPDATE Fact_Service fs
JOIN Dim_Building db ON fs.BuildingKey = db.BuildingKey
SET fs.BuildingKey = (
    SELECT MAX(BuildingKey) FROM Dim_Building 
    WHERE BuildingID = db.BuildingID AND IsCurrent = TRUE
)
WHERE EXISTS (
    SELECT 1 FROM Dim_Building 
    WHERE BuildingID = db.BuildingID AND IsCurrent = TRUE AND BuildingKey != fs.BuildingKey
);

-- Step 6: Add Some Additional Sample Data for Analysis
-- =============================================
-- Add a few more maintenance requests for trend analysis
INSERT INTO MaintenanceRequest (RequestID, RequestDate, Description, Status, CompletedDate, ApartmentNo, BuildingID, AssignedStaff) VALUES
(716, '2025-04-15', 'Toilet constantly running', 'Open', NULL, '201', 'B0012', 'S007'),
(717, '2025-04-18', 'Broken kitchen drawer', 'Open', NULL, '101', 'B0013', 'S008'),
(718, '2025-04-20', 'Ceiling paint peeling', 'Open', NULL, '201', 'B0014', 'S008'),
(719, '2025-04-22', 'Noisy air conditioner', 'Open', NULL, '101', 'B0015', 'S009');

-- Process these new maintenance requests into the fact table
INSERT INTO Fact_Service (
    StaffKey, DateKey, ApartmentKey, BuildingKey, StatusKey, ServiceTypeKey, RequestID,
    TotalRequests, CompletedRequests, AvgResolutionDays, DurationDays, Next_Insp_Date,
    TotalNoOfInspections
)
SELECT
    de.EmployeeKey, dd.DateKey, da.ApartmentKey, db.BuildingKey,
    (SELECT StatusKey FROM Dim_Status WHERE StatusCode = 'OPEN') AS StatusKey,
    (SELECT ServiceTypeKey FROM Dim_ServiceType WHERE ServiceTypeCode = 'MAINT') AS ServiceTypeKey,
    mr.RequestID,
    1 AS TotalRequests,
    0 AS CompletedRequests, -- Not completed yet
    0 AS AvgResolutionDays, -- Not applicable
    DATEDIFF(CURDATE(), mr.RequestDate) AS DurationDays,
    '2999-12-31' AS Next_Insp_Date,
    0 AS TotalNoOfInspections
FROM MaintenanceRequest mr
JOIN Dim_Employee de ON mr.AssignedStaff = de.EmployeeID
JOIN Dim_Date dd ON dd.Date = mr.RequestDate
JOIN Dim_Apartment da ON mr.ApartmentNo = da.ApartmentNumber AND mr.BuildingID = da.BuildingID
JOIN Dim_Building db ON mr.BuildingID = db.BuildingID AND db.IsCurrent = TRUE
WHERE mr.RequestID IN (716, 717, 718, 719);