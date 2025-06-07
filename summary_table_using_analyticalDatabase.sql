-- creating summary tables to better understand 

-- total rental income per building by year 
CREATE TABLE Summary_RentalIncome_ByBuilding_Year AS
SELECT 
    db.BuildingID,
    dd.Year,
    SUM(fl.RevenueGenerated) AS TotalRentalIncome
FROM Fact_Lease fl
JOIN Dim_Building db ON fl.BuildingKey = db.BuildingKey
JOIN Dim_Date dd ON fl.DateKey = dd.DateKey
GROUP BY db.BuildingID, dd.Year;

Select *
from Summary_RentalIncome_ByBuilding_Year;

-- summary of unresolved maintenance requests
CREATE TABLE Summary_UnresolvedRequests AS
SELECT 
    BuildingID,
    YEAR(RequestDate) AS Year,
    MONTH(RequestDate) AS Month,
    Status,
    COUNT(*) AS UnresolvedCount
FROM MaintenanceRequest
WHERE Status IN ('Open', 'In Progress')
GROUP BY BuildingID, YEAR(RequestDate), MONTH(RequestDate), Status
ORDER BY BuildingID, Year, Month;

select *
from Summary_UnresolvedRequests;

-- staff performance based on number of maintenance task completed 
CREATE TABLE Summary_MaintenancePerformanceByStaff AS
SELECT 
    de.EmployeeID,
    de.EmployeeFullName,
    COUNT(*) AS CompletedMaintenanceTasks
FROM Fact_Service fs
JOIN Dim_Employee de ON fs.StaffKey = de.EmployeeKey
JOIN Dim_ServiceType dst ON fs.ServiceTypeKey = dst.ServiceTypeKey
JOIN Dim_Status ds ON fs.StatusKey = ds.StatusKey
WHERE dst.ServiceTypeName = 'Maintenance Request'
  AND ds.StatusDescription = 'Completed successfully'
GROUP BY de.EmployeeID, de.EmployeeFullName;

select * 
from Summary_MaintenancePerformanceByStaff;

-- Cleaning Services Completed per Staff
CREATE TABLE Summary_CleaningPerformanceByStaff AS
SELECT 
    de.EmployeeID,
    de.EmployeeFullName,
    COUNT(*) AS TotalCleanings
FROM Fact_Service fs
JOIN Dim_Employee de ON fs.StaffKey = de.EmployeeKey
JOIN Dim_ServiceType dst ON fs.ServiceTypeKey = dst.ServiceTypeKey
JOIN Dim_Status ds ON fs.StatusKey = ds.StatusKey
WHERE dst.ServiceTypeName = 'Apartment Cleaning'
  AND ds.StatusDescription = 'Completed successfully'
GROUP BY de.EmployeeID, de.EmployeeFullName;

SELECT *
FROM Summary_CleaningPerformanceByStaff
ORDER BY TotalCleanings Desc;

-- lease count per building by year 
CREATE TABLE Summary_LeaseCount_ByBuilding_Year AS
SELECT 
    db.BuildingID,
    dd.Year,
    COUNT(*) AS LeaseCount
FROM Fact_Lease fl
JOIN Dim_Building db ON fl.BuildingKey = db.BuildingKey
JOIN Dim_Date dd ON fl.DateKey = dd.DateKey
GROUP BY db.BuildingID, dd.Year;

SELECT * FROM Summary_LeaseCount_ByBuilding_Year;

-- Revenue by Client Industry per Year
CREATE TABLE Summary_Revenue_ByIndustry_Year AS
SELECT 
    dcc.CCIndustry,
    dd.Year,
    SUM(fl.RevenueGenerated) AS TotalRevenue
FROM Fact_Lease fl
JOIN Dim_CorporateClient dcc ON fl.ClientKey = dcc.ClientKey
JOIN Dim_Date dd ON fl.DateKey = dd.DateKey
GROUP BY dcc.CCIndustry, dd.Year;

select * from Summary_Revenue_ByIndustry_Year;

-- summary of corporate clients that lease multiple units
CREATE TABLE Summary_RepeatClients AS
SELECT 
    dcc.CorpClientName,
    COUNT(*) AS TotalLeases
FROM Fact_Lease fl
JOIN Dim_CorporateClient dcc ON fl.ClientKey = dcc.ClientKey
GROUP BY dcc.CorpClientName
HAVING COUNT(*) > 1;


select *
from Summary_RepeatClients;

