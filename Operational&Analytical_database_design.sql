CREATE DATABASE PropertyManagement2;
USE PropertyManagement2;

CREATE TABLE Building (
    BuildingID CHAR(5) NOT NULL,
    Street VARCHAR(100) NOT NULL,
    City VARCHAR(50) NOT NULL,
    State VARCHAR(30) NOT NULL,
    ZipCode VARCHAR(10) NOT NULL,
    ManagerIDOversees CHAR(5) NOT NULL,
    PRIMARY KEY (BuildingID)
);

CREATE TABLE Manager (
    ManagerID CHAR(5) NOT NULL,
    MFirstName VARCHAR(50) NOT NULL,
    MLastName VARCHAR(50) NOT NULL,
    MEmail VARCHAR(100) NOT NULL,
    MSalary NUMERIC(10,2) NOT NULL,
    BuildingIDResides CHAR(5),
    PRIMARY KEY (ManagerID),
    UNIQUE (MEmail)
);

-- Alter Building table to add/indicate foreign key
ALTER TABLE Building
ADD CONSTRAINT FK_Building_Manager
FOREIGN KEY (ManagerIDOversees) REFERENCES Manager(ManagerID);

-- Alter Manager table to add/indicate foreign key
ALTER TABLE Manager
ADD CONSTRAINT FK_Manager_Building
FOREIGN KEY (BuildingIDResides) REFERENCES Building(BuildingID);

CREATE TABLE ManagerPhone (
    MPhoneNo VARCHAR(15) NOT NULL,
    ManagerID CHAR(5) NOT NULL,
    PRIMARY KEY (MPhoneNo, ManagerID),
    FOREIGN KEY (ManagerID) REFERENCES Manager(ManagerID)
);

CREATE TABLE Apartment (
    ApartmentNo VARCHAR(10) NOT NULL,
    BuildingID CHAR(5) NOT NULL,
    NoOfBedrooms INTEGER NOT NULL,
    RentalStatus VARCHAR(20) DEFAULT 'Vacant' NOT NULL,
    PRIMARY KEY (ApartmentNo, BuildingID),
    FOREIGN KEY (BuildingID) REFERENCES Building(BuildingID) ON DELETE CASCADE
);

CREATE TABLE StaffMember (
    StaffID CHAR(4) NOT NULL,
    SFirstName VARCHAR(50) NOT NULL,
    SLastName VARCHAR(50) NOT NULL,
    SEmail VARCHAR(100) NOT NULL,
    PRIMARY KEY (StaffID),
    UNIQUE (SEmail)
);

CREATE TABLE Cleans (
    ApartmentNo VARCHAR(10) NOT NULL,
    BuildingID CHAR(5) NOT NULL,
    StaffID CHAR(4) NOT NULL,
    PRIMARY KEY (ApartmentNo, BuildingID, StaffID),
    FOREIGN KEY (ApartmentNo, BuildingID) REFERENCES Apartment(ApartmentNo, BuildingID),
    FOREIGN KEY (StaffID) REFERENCES StaffMember(StaffID)
);

CREATE TABLE Inspector (
    InspectorID CHAR(7) NOT NULL,
    IFirstName VARCHAR(50) NOT NULL,
    ILastName VARCHAR(50) NOT NULL,
    IEmail VARCHAR(100) NOT NULL,
    PRIMARY KEY (InspectorID),
    UNIQUE (IEmail)
);

CREATE TABLE Inspects (
    BuildingID CHAR(5) NOT NULL,
    InspectorID CHAR(7) NOT NULL,
    Date_Completed DATE NOT NULL,
    Next_Insp_date DATE NOT NULL,
    PRIMARY KEY (BuildingID, InspectorID),
    FOREIGN KEY (BuildingID) REFERENCES Building(BuildingID),
    FOREIGN KEY (InspectorID) REFERENCES Inspector(InspectorID)
);

CREATE TABLE CorporateClient (
    CCID CHAR(5) NOT NULL,
    CCName VARCHAR(100) NOT NULL,
    CCEmail VARCHAR(100) NOT NULL,
    CCIndustry VARCHAR(50) NOT NULL,
    CIDReferedBy CHAR(5),
    PRIMARY KEY (CCID),
    UNIQUE (CCEmail),
    FOREIGN KEY (CIDReferedBy) REFERENCES CorporateClient(CCID)
);

CREATE TABLE MaintenanceRequest (
    RequestID INTEGER NOT NULL,
    RequestDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    Description TEXT(200) NOT NULL,
    Status VARCHAR(20) DEFAULT 'Open' NOT NULL,
    CompletedDate DATE,
    ApartmentNo VARCHAR(10) NOT NULL,
    BuildingID CHAR(5) NOT NULL,
    AssignedStaff 	CHAR(4) NOT NULL,
    PRIMARY KEY (RequestID),
    FOREIGN KEY (ApartmentNo, BuildingID) REFERENCES Apartment(ApartmentNo, BuildingID),
    FOREIGN KEY (AssignedStaff) REFERENCES StaffMember(StaffID)
);

CREATE TABLE Lease (
    LeaseID INTEGER NOT NULL,
    LeaseStartDate DATE NOT NULL,
    SecurityDeposit NUMERIC(10, 2) DEFAULT 0.00 NOT NULL,
    MonthlyRent NUMERIC(10, 2) DEFAULT 0.00 NOT NULL,
    LeaseEndDate DATE NOT NULL,
    ApartmentNo VARCHAR(10) NOT NULL,
    BuildingID CHAR(5) NOT NULL,
    CCID CHAR(5) NOT NULL,
    PRIMARY KEY (LeaseID),
    FOREIGN KEY (ApartmentNo, BuildingID) REFERENCES Apartment(ApartmentNo, BuildingID),
    FOREIGN KEY (CCID) REFERENCES CorporateClient(CCID)
);

-- Insert data into Building Table
INSERT INTO Building (BuildingID, Street, City, State, ZipCode, ManagerIDOversees) VALUES
('B0001', '123 Sunset Blvd', 'Los Angeles', 'CA', '90028', 'M0001'),
('B0002', '456 Hollywood Ave', 'Los Angeles', 'CA', '90038', 'M0001'),
('B0003', '789 Vine St', 'Los Angeles', 'CA', '90036', 'M0001'),
('B0004', '101 Wilshire Blvd', 'Los Angeles', 'CA', '90017', 'M0010'),
('B0005', '202 Capitol Mall', 'Sacramento', 'CA', '95814', 'M0002'),
('B0006', '303 J St', 'Sacramento', 'CA', '95814', 'M0003'),
('B0007', '404 L St', 'Sacramento', 'CA', '95814', 'M0003'),
('B0008', '505 Michigan Ave', 'Chicago', 'IL', '60611', 'M0005'),
('B0009', '606 Wacker Dr', 'Chicago', 'IL', '60601', 'M0005'),
('B0010', '707 Broadway', 'New York', 'NY', '10003', 'M0004'),
('B0011', '808 5th Ave', 'New York', 'NY', '10021', 'M0006'),
('B0012', '909 Boylston St', 'Boston', 'MA', '02116', 'M0008'),
('B0013', '110 Market St', 'San Francisco', 'CA', '94103', 'M0007'),
('B0014', '211 Union St', 'San Francisco', 'CA', '94111', 'M0007'),
('B0015', '312 Pike St', 'Seattle', 'WA', '98101', 'M0009');

-- Insert data into Manager Table
INSERT INTO Manager (ManagerID, MFirstName, MLastName, MEmail, MSalary, BuildingIDResides) VALUES
('M0001', 'Sharon', 'Smith', 'ssmith@example.com', 85000.00, NULL),
('M0002', 'Sarah', 'Johnson', 'sjohnson@example.com', 72000.00, NULL),
('M0003', 'Michael', 'Williams', 'mwilliams@example.com', 78500.00, NULL),
('M0004', 'Emma', 'Brown', 'ebrown@example.com', 70000.00, NULL),
('M0005', 'James', 'Jones', 'jjones@example.com', 77000.00, NULL),
('M0006', 'Linda', 'Garcia', 'lgarcia@example.com', 74000.00, NULL),
('M0007', 'Robert', 'Miller', 'rmiller@example.com', 76500.00, NULL),
('M0008', 'Patricia', 'Davis', 'pdavis@example.com', 73000.00, NULL),
('M0009', 'David', 'Rodriguez', 'drodriguez@example.com', 75000.00, NULL),
('M0010', 'Jennifer', 'Martinez', 'jmartinez@example.com', 77200.00, NULL);

-- Update Manager records with BuildingIDResides values
UPDATE Manager SET BuildingIDResides = 'B0002' WHERE ManagerID = 'M0001';
UPDATE Manager SET BuildingIDResides = 'B0005' WHERE ManagerID = 'M0002';
UPDATE Manager SET BuildingIDResides = 'B0007' WHERE ManagerID = 'M0003';
UPDATE Manager SET BuildingIDResides = 'B0010' WHERE ManagerID = 'M0004';
UPDATE Manager SET BuildingIDResides = 'B0008' WHERE ManagerID = 'M0005';
UPDATE Manager SET BuildingIDResides = 'B0011' WHERE ManagerID = 'M0006';
UPDATE Manager SET BuildingIDResides = 'B0013' WHERE ManagerID = 'M0007';
UPDATE Manager SET BuildingIDResides = 'B0012' WHERE ManagerID = 'M0008';
UPDATE Manager SET BuildingIDResides = 'B0015' WHERE ManagerID = 'M0009';
UPDATE Manager SET BuildingIDResides = 'B0004' WHERE ManagerID = 'M0010';

-- Insert data into ManagerPhone table
INSERT INTO ManagerPhone (MPhoneNo, ManagerID) VALUES
('212-555-1001', 'M0001'),
('212-555-1002', 'M0001'),
('617-555-2001', 'M0002'),
('312-555-3001', 'M0003'),
('415-555-4001', 'M0004'),
('206-555-5001', 'M0005'),
('206-555-5002', 'M0005'),
('305-555-6002', 'M0006'),
('323-555-7001', 'M0007'),
('323-555-7002', 'M0007'),
('303-555-8001', 'M0008'),
('212-555-9001', 'M0009'),
('617-555-0001', 'M0010');

-- Insert data into Apartment Table
INSERT INTO Apartment (ApartmentNo, BuildingID, NoOfBedrooms, RentalStatus) VALUES
-- Los Angeles Buildings
('101', 'B0001', 2, 'Occupied'),
('102', 'B0001', 1, 'Vacant'),
('201', 'B0001', 3, 'Occupied'),
('101', 'B0002', 2, 'Occupied'),
('102', 'B0002', 2, 'Vacant'),
('201', 'B0002', 1, 'Occupied'),
('101', 'B0003', 1, 'Occupied'),
('201', 'B0003', 2, 'Occupied'),
('301', 'B0003', 3, 'Vacant'),
('101', 'B0004', 1, 'Occupied'),
('201', 'B0004', 2, 'Occupied'),
-- Sacramento Buildings
('101', 'B0005', 1, 'Vacant'),
('201', 'B0005', 2, 'Occupied'),
('101', 'B0006', 2, 'Occupied'),
('201', 'B0006', 3, 'Occupied'),
('101', 'B0007', 1, 'Occupied'),
('201', 'B0007', 2, 'Vacant'),
-- Chicago Buildings
('101', 'B0008', 2, 'Occupied'),
('201', 'B0008', 2, 'Occupied'),
('101', 'B0009', 1, 'Occupied'),
('201', 'B0009', 3, 'Vacant'),
-- New York Buildings
('101', 'B0010', 2, 'Occupied'),
('201', 'B0010', 1, 'Occupied'),
('101', 'B0011', 3, 'Occupied'),
('201', 'B0011', 2, 'Vacant'),
-- Boston Building
('101', 'B0012', 1, 'Occupied'),
('201', 'B0012', 2, 'Occupied'),
-- San Francisco Buildings
('101', 'B0013', 2, 'Occupied'),
('201', 'B0013', 3, 'Vacant'),
('101', 'B0014', 1, 'Occupied'),
('201', 'B0014', 2, 'Occupied'),
-- Seattle Building
('101', 'B0015', 2, 'Occupied'),
('201', 'B0015', 1, 'Vacant');

-- Insert data into Staff Members Table
INSERT INTO StaffMember (StaffID, SFirstName, SLastName, SEmail) VALUES
('S001', 'Davida', 'Clark', 'dclark@example.com'),
('S002', 'Laura', 'Lewis', 'llewis@example.com'),
('S003', 'Kevin', 'Lee', 'klee@example.com'),
('S004', 'Maria', 'Walker', 'mwalker@example.com'),
('S005', 'Jammy', 'Hall', 'jhall@example.com'),
('S006', 'Susan', 'Allen', 'sallen@example.com'),
('S007', 'Brown', 'Young', 'byoung@example.com'),
('S008', 'Nonye', 'King', 'nking@example.com'),
('S009', 'Markson', 'Wright', 'mwright@example.com'),
('S010', 'Karen', 'Lopez', 'klopez@example.com');

-- Insert data into Inspector table
INSERT INTO Inspector (InspectorID, IFirstName, ILastName, IEmail) VALUES
('INSP001', 'Jonathan', 'Peterson', 'jpeterson@inspector.gov'),
('INSP002', 'Helen', 'Baker', 'hbaker@inspector.gov'),
('INSP003', 'Richard', 'Carter', 'rcarter@inspector.gov'),
('INSP004', 'Denzel', 'Evans', 'devans@inspector.gov'),
('INSP005', 'Joseph', 'Foster', 'jfoster@inspector.gov'),
('INSP006', 'Carol', 'Green', 'cgreen@inspector.gov'),
('INSP007', 'Edward', 'Harris', 'eharris@inspector.gov'),
('INSP008', 'Logan', 'Irving', 'lirving@inspector.gov'),
('INSP009', 'Steven', 'Jackson', 'sjackson@inspector.gov'),
('INSP010', 'Sandra', 'Kelly', 'skelly@inspector.gov');

-- Insert data into Cleans table
INSERT INTO Cleans (ApartmentNo, BuildingID, StaffID) VALUES
-- Los Angeles Buildings (S001 and S002)
('101', 'B0001', 'S001'),
('102', 'B0001', 'S001'),
('201', 'B0001', 'S001'),
('101', 'B0002', 'S001'),
('102', 'B0002', 'S001'),
('201', 'B0002', 'S002'),
('101', 'B0003', 'S002'),
('201', 'B0003', 'S002'),
('301', 'B0003', 'S002'),
('101', 'B0004', 'S002'),
('201', 'B0004', 'S002'),
-- Sacramento Buildings (S003 and S004)
('101', 'B0005', 'S003'),
('201', 'B0005', 'S003'),
('101', 'B0006', 'S003'),
('201', 'B0006', 'S003'),
('101', 'B0007', 'S004'),
('201', 'B0007', 'S004'),
-- Chicago Buildings (S005)
('101', 'B0008', 'S005'),
('201', 'B0008', 'S005'),
('101', 'B0009', 'S005'),
('201', 'B0009', 'S005'),
-- New York Buildings (S006)
('101', 'B0010', 'S006'),
('201', 'B0010', 'S006'),
('101', 'B0011', 'S006'),
('201', 'B0011', 'S006'),
-- Boston Building (S007)
('101', 'B0012', 'S007'),
('201', 'B0012', 'S007'),
-- San Francisco Buildings (S008)
('101', 'B0013', 'S008'),
('201', 'B0013', 'S008'),
('101', 'B0014', 'S008'),
('201', 'B0014', 'S008'),
-- Seattle Building (S009 and S010)
('101', 'B0015', 'S009'),
('201', 'B0015', 'S010');

-- Insert data into Inspects table
INSERT INTO Inspects (BuildingID, InspectorID, Date_Completed, Next_Insp_date) VALUES
-- Los Angeles Buildings
('B0001', 'INSP001', '2024-01-15', '2025-01-15'),
('B0001', 'INSP002', '2024-06-15', '2025-06-15'),
('B0002', 'INSP001', '2024-01-20', '2025-01-20'),
('B0003', 'INSP002', '2024-02-10', '2025-02-10'),
('B0004', 'INSP002', '2024-02-15', '2025-02-15'),
-- Sacramento Buildings
('B0005', 'INSP003', '2024-02-22', '2025-02-22'),
('B0005', 'INSP004', '2024-06-27', '2025-06-27'),
('B0006', 'INSP003', '2024-03-01', '2025-03-01'),
('B0007', 'INSP004', '2024-03-10', '2025-03-10'),
-- Chicago Buildings
('B0008', 'INSP005', '2024-03-18', '2025-03-18'),
('B0009', 'INSP005', '2024-04-02', '2025-04-02'),
-- New York Buildings
('B0010', 'INSP006', '2024-04-12', '2025-04-12'),
('B0010', 'INSP007', '2024-07-10', '2025-07-10'),
('B0011', 'INSP007', '2024-04-19', '2025-04-19'),
-- Boston Building
('B0012', 'INSP008', '2024-05-03', '2025-05-03'),
-- San Francisco Buildings
('B0013', 'INSP009', '2024-05-15', '2025-05-15'),
('B0014', 'INSP009', '2024-05-22', '2025-05-22'),
-- Seattle Building
('B0015', 'INSP010', '2024-06-01', '2025-06-01');

-- Insert data into CorporateClient Table
-- First, insert clients with no referrals
INSERT INTO CorporateClient (CCID, CCName, CCEmail, CCIndustry, CIDReferedBy) VALUES
('CC001', 'TechNova Inc', 'contact@technova.com', 'Technology', NULL),
('CC002', 'Global Logistics', 'info@globallogistics.com', 'Transportation', NULL),
('CC003', 'Pacific Finance', 'corporate@pacificfinance.com', 'Finance', NULL),
('CC004', 'West Coast Media', 'business@westcoastmedia.com', 'Entertainment', NULL),
('CC005', 'Health Solutions', 'inquiries@healthsolutions.com', 'Healthcare', NULL);
-- Then, insert clients with referrals
INSERT INTO CorporateClient (CCID, CCName, CCEmail, CCIndustry, CIDReferedBy) VALUES
('CC006', 'EcoSystems Design', 'contact@ecosystems.com', 'Environment', 'CC001'),
('CC007', 'Urban Architecture', 'info@urbanarchitecture.com', 'Construction', 'CC003'),
('CC008', 'DataStream Analytics', 'sales@datastream.com', 'Data Science', 'CC001'),
('CC009', 'Creative Solutions', 'inquiries@creativesolutions.com', 'Marketing', 'CC004'),
('CC010', 'Fresh Organics', 'business@freshorganics.com', 'Food Production', 'CC002'),
('CC011', 'Medical Innovations', 'info@medicalinnovations.com', 'Biotechnology', 'CC005'),
('CC012', 'Space Systems Corp', 'contact@spacesystems.com', 'Aerospace', 'CC008'),
('CC013', 'Golden State Insurance', 'info@gsinsurance.com', 'Insurance', 'CC003'),
('CC014', 'Quantum Computing', 'business@quantumcomputing.com', 'Technology', 'CC001'),
('CC015', 'Renewable Energy Group', 'contact@renewableenergy.com', 'Energy', 'CC006');

-- Insert data into Lease table
INSERT INTO Lease (LeaseID, LeaseStartDate, SecurityDeposit, MonthlyRent, LeaseEndDate, ApartmentNo, BuildingID, CCID) VALUES
-- Los Angeles Buildings
(5001, '2024-01-01', 3700.00, 2500.00, '2025-01-01', '101', 'B0001', 'CC001'),
(5002, '2024-01-15', 4200.00, 2800.00, '2025-01-15', '201', 'B0001', 'CC002'),
(5003, '2024-02-01', 3000.00, 2400.00, '2025-02-01', '101', 'B0002', 'CC003'),
(5004, '2024-02-15', 3500.00, 2200.00, '2025-02-15', '201', 'B0002', 'CC004'),
(5005, '2024-03-01', 2500.00, 2000.00, '2025-03-01', '101', 'B0003', 'CC005'),
(5006, '2024-03-15', 3200.00, 2600.00, '2025-03-15', '201', 'B0003', 'CC006'),
(5007, '2024-04-01', 2800.00, 2300.00, '2025-04-01', '101', 'B0004', 'CC007'),
(5008, '2024-04-15', 3200.00, 2500.00, '2025-04-15', '201', 'B0004', 'CC008'),
-- Sacramento Buildings
(5009, '2024-05-01', 3500.00, 2100.00, '2025-05-01', '201', 'B0005', 'CC009'),
(5010, '2024-05-15', 3700.00, 2300.00, '2025-05-15', '101', 'B0006', 'CC010'),
(5011, '2024-06-01', 4100.00, 2600.00, '2025-06-01', '201', 'B0006', 'CC011'),
(5012, '2024-06-15', 3600.00, 2200.00, '2025-06-15', '101', 'B0007', 'CC012'),
-- Chicago Buildings
(5013, '2024-07-01', 2900.00, 2400.00, '2025-07-01', '101', 'B0008', 'CC013'),
(5014, '2024-07-15', 3200.00, 2700.00, '2025-07-15', '201', 'B0008', 'CC014'),
(5015, '2024-08-01', 2800.00, 2300.00, '2025-08-01', '101', 'B0009', 'CC015'),
-- New York Buildings
(5016, '2024-08-15', 3500.00, 3000.00, '2025-08-15', '101', 'B0010', 'CC001'),
(5017, '2024-09-01', 3700.00, 3200.00, '2025-09-01', '201', 'B0010', 'CC002'),
(5018, '2024-09-15', 3800.00, 3300.00, '2025-09-15', '101', 'B0011', 'CC003'),
-- Boston Building
(5019, '2024-10-01', 3300.00, 2800.00, '2025-10-01', '101', 'B0012', 'CC004'),
(5020, '2024-10-15', 3500.00, 3000.00, '2025-10-15', '201', 'B0012', 'CC005'),
-- San Francisco Buildings
(5021, '2024-11-01', 3900.00, 3400.00, '2025-11-01', '101', 'B0013', 'CC006'),
(5022, '2024-11-15', 3600.00, 3100.00, '2025-11-15', '101', 'B0014', 'CC007'),
(5023, '2024-12-01', 3700.00, 3200.00, '2025-12-01', '201', 'B0014', 'CC008'),
-- Seattle Building
(5024, '2024-12-15', 3400.00, 2900.00, '2025-12-15', '101', 'B0015', 'CC009');

-- Insert data into Maintenance Request Table
INSERT INTO MaintenanceRequest (RequestID, RequestDate, Description, Status, CompletedDate, ApartmentNo, BuildingID, AssignedStaff) VALUES
(701, '2023-01-10', 'Leaking kitchen sink', 'Completed', '2023-01-12', '101', 'B0001', 'S001'),
(702, '2023-01-20', 'Broken bathroom light fixture', 'Completed', '2023-01-23', '201', 'B0001', 'S001'),
(703, '2023-02-05', 'Thermostat not working', 'Completed', '2023-02-08', '101', 'B0002', 'S001'),
(704, '2024-02-15', 'Window won\'t close properly', 'Completed', '2024-02-16', '101', 'B0003', 'S002'),
(705, '2024-03-01', 'Dishwasher not draining', 'Completed', '2024-03-03', '201', 'B0003', 'S002'),
(706, '2024-03-15', 'Ceiling fan makes noise', 'Completed', '2024-03-19', '101', 'B0004', 'S002'),
(707, '2024-04-01', 'Smoke detector battery replacement', 'Completed', '2024-04-01', '201', 'B0005', 'S003'),
(708, '2024-04-15', 'Front door lock jammed', 'Completed', '2024-04-17', '101', 'B0006', 'S003'),
(709, '2024-05-01', 'Air conditioning not cooling', 'Completed', '2024-05-03', '201', 'B0006', 'S003'),
(710, '2024-05-15', 'Garbage disposal not working', 'Completed', '2024-05-17', '101', 'B0007', 'S004'),
(711, '2025-04-01', 'Shower drain clogged', 'In Progress', NULL, '101', 'B0008', 'S005'),
(712, '2025-04-10', 'Refrigerator temperature issues', 'Open', NULL, '201', 'B0008', 'S005'),
(713, '2025-03-20', 'Closet door off track', 'Open', NULL, '101', 'B0009', 'S005'),
(714, '2025-04-01', 'Water heater leaking', 'Open', NULL, '101', 'B0010', 'S006'),
(715, '2025-05-02', 'Stove burner not lighting', 'Open', NULL, '101', 'B0011', 'S006');

-- Update completion dates for tracking resolution times
UPDATE MaintenanceRequest
  SET Status = 'Completed',
      CompletedDate = '2025-04-03'
WHERE RequestID = 711;

UPDATE MaintenanceRequest
  SET Status = 'Completed',
      CompletedDate = '2025-04-07'
WHERE RequestID = 713;

-- Adding more historical maintenance request data for trend analysis
-- Including data from multiple years to support year-to-year comparisons
INSERT INTO MaintenanceRequest (RequestID, RequestDate, Description, Status, CompletedDate, ApartmentNo, BuildingID, AssignedStaff) VALUES
-- Historical  data for Maintenance Request from 2023
(306, '2023-06-15', 'Roof leak in attic', 'Completed', '2023-06-18', '301', 'B0003', 'S004'),
(307, '2023-07-02', 'Broken sidewalk light', 'Completed', '2023-07-04', '101', 'B0007', 'S002'),
(308, '2023-08-20', 'Pest control requested', 'Completed', '2023-08-22', '201', 'B0010', 'S005'),
(309, '2023-09-10', 'Elevator malfunction', 'Completed', '2023-09-12', '101', 'B0005', 'S001'),
(310, '2023-10-05', 'Smoke alarm false alarm', 'Completed', '2023-10-06', '101', 'B0006', 'S006'),
-- Historical data from 2024
(421, '2024-06-15', 'Garage door sensor failure', 'Completed', '2024-06-17', '201', 'B0008', 'S007'),
(422, '2024-07-01', 'Mold in bathroom corner', 'Completed', '2024-07-03', '101', 'B0009', 'S008'),
(423, '2024-08-20', 'Air vent clogged', 'Completed', '2024-08-21', '102', 'B0002', 'S009'),
(424, '2024-09-10', 'Hot water inconsistent', 'Completed', '2024-09-12', '201', 'B0004', 'S010'),
(425, '2024-11-05', 'Carpet stains cleaned', 'Completed', '2024-11-06', '101', 'B0001', 'S001');

-- History data added to lease to enable rental trends
 INSERT INTO Lease (LeaseID, LeaseStartDate, SecurityDeposit, MonthlyRent, LeaseEndDate, ApartmentNo, BuildingID, CCID) VALUES
  -- 2022 leases
  (4025, '2022-02-01', 1200.00, 1800.00, '2023-01-31', '101', 'B0001', 'CC001'),
  (4026, '2022-03-15', 1500.00, 2000.00, '2023-03-14', '201', 'B0003', 'CC003'),
  (4027, '2022-06-01', 1000.00, 1600.00, '2023-05-31', '101', 'B0005', 'CC005'),
  -- 2023 leases
  (4028, '2023-01-10', 1100.00, 1700.00, '2024-01-09', '102', 'B0002', 'CC002'),
  (4029, '2023-04-01', 1300.00, 1900.00, '2024-03-31', '201', 'B0004', 'CC006'),
  (4030, '2023-07-15', 1400.00, 2000.00, '2024-07-14', '201', 'B0006', 'CC008');
  
-- Simultating Changes in ManagerIDOversees to demonstrate SCD functionality
-- These updates will trigger historical tracking in Dim_Building
-- Original ManagersIDOversees
--
  
-- Creating Dimension and Fact Tables
-- Some data refers to original tables except surrogate keys or stated otherwise
-- Create Building dimension table
CREATE TABLE Dim_Building (
    BuildingKey INT AUTO_INCREMENT PRIMARY KEY,	-- Surrogate Key
    BuildingID CHAR(5) NOT NULL,
    BuildingAddress VARCHAR(255) NOT NULL,	-- Building street + city + state + zipcode
    ManagerID CHAR(5) NOT NULL,
    ManagerFullName VARCHAR(100) NOT NULL,	-- Manager MFirstName + MLastName
    ManagerPhone VARCHAR(20) NOT NULL,
    ManagerEmail VARCHAR(100) NOT NULL,
    EffectiveDate DATE NOT NULL,	-- Start date for SCD tracking
    EndDate DATE,	-- End date for SCD tracking
    IsCurrent BOOLEAN NOT NULL	-- Indicator for the current record
);

-- Create Apartment dimension table
CREATE TABLE Dim_Apartment (
    ApartmentKey INT AUTO_INCREMENT PRIMARY KEY,	-- Surrogate Key
    BuildingID CHAR(5) NOT NULL,
    ApartmentNumber VARCHAR(10) NOT NULL,
    NumberOfBedrooms INT,	
    CurrentStatus VARCHAR(20)	-- Rental status
);

-- Create CorporateClient dimension table
CREATE TABLE Dim_CorporateClient (
    ClientKey INT AUTO_INCREMENT PRIMARY KEY,	-- Surrogate Key
    CCID CHAR(5) NOT NULL,
    CorpClientName VARCHAR(100) NOT NULL,	-- CCName on CorporateClient Table
    CCIndustry VARCHAR(50),
    CCEmail VARCHAR(100),
    CCReferredBy CHAR(5)	-- CIDReferredBy on CorporateClient Table
);

-- Create Date dimension table
CREATE TABLE Dim_Date (
    DateKey INT AUTO_INCREMENT PRIMARY KEY,	-- Surrogate Key
    Date DATE NOT NULL,	-- Actual Date
    Week INT NOT NULL,	-- Week of Year
    Month INT NOT NULL,	-- Month of Year
    Quarter INT NOT NULL,	-- Quarter of Year
    Year INT NOT NULL,	-- Year
    DayOfWeek INT NOT NULL,		-- Day name (e.g., Monday)
    DayOfMonth INT NOT NULL,	-- Day of the month(e.g., 1,2,3...)
    FiscalYear INT NOT NULL		-- Fiscal Year
);

-- Create Employee dimension table
CREATE TABLE Dim_Employee (			-- Combines staff and inspectors details)
    EmployeeKey INT AUTO_INCREMENT PRIMARY KEY,		-- Surrogate Key
    EmployeeID CHAR(7) NOT NULL,	-- Staff/Inspector ID
    EmployeeFullName VARCHAR(100) NOT NULL,		-- Staff/Inspector full name
    EmployeeEmail VARCHAR(100) NOT NULL,	-- Staff/Inspector email
    EmployeeRole VARCHAR(50) NOT NULL		-- Staff or Inspector
);

-- Create ServiceType dimension table
CREATE TABLE Dim_ServiceType (
    ServiceTypeKey INT AUTO_INCREMENT PRIMARY KEY,	-- Surrogate Key
    ServiceTypeCode VARCHAR(50) NOT NULL,	-- Generated for service type
    ServiceTypeName VARCHAR(100) NOT NULL	-- Inspection, Cleaning, Maintenance
);

-- Create Status dimension table
CREATE TABLE Dim_Status (
    StatusKey INT AUTO_INCREMENT PRIMARY KEY, 	-- Surrogate Key
    StatusCode VARCHAR(50) NOT NULL,	-- Generated for status
    StatusDescription VARCHAR(255) NOT NULL		-- Open, In-Progress, Completed, Cancelled
);

-- FACT TABLES
-- Create Lease fact table
CREATE TABLE Fact_Lease (
    LeaseKey INT AUTO_INCREMENT PRIMARY KEY, 	-- Surrogate key
    ClientKey INT NOT NULL,
    DateKey INT NOT NULL,
    ApartmentKey INT NOT NULL,
    BuildingKey INT NOT NULL,
    LeaseID INT NOT NULL,	-- Original LeaseID
    MonthlyRent DECIMAL(10, 2) NOT NULL,
    SecurityDeposit DECIMAL(10, 2) NOT NULL,
    LeaseDuration INT NOT NULL,
    LeaseStartDate DATE NOT NULL,
    LeaseEndDate DATE NOT NULL,
    RevenueGenerated DECIMAL(10, 2) NOT NULL,	-- Added for revenue analysis
    FOREIGN KEY (ClientKey) REFERENCES Dim_CorporateClient(ClientKey),
    FOREIGN KEY (DateKey) REFERENCES Dim_Date(DateKey),
    FOREIGN KEY (ApartmentKey) REFERENCES Dim_Apartment(ApartmentKey),
    FOREIGN KEY (BuildingKey) REFERENCES Dim_Building(BuildingKey)
);

-- Create Service fact table
CREATE TABLE Fact_Service (
    ServiceKey INT AUTO_INCREMENT PRIMARY KEY,		-- Surrogate Key
    StaffKey INT NOT NULL,
    DateKey INT NOT NULL,
    ApartmentKey INT NOT NULL,
    BuildingKey INT NOT NULL,
    StatusKey INT NOT NULL,
    ServiceTypeKey INT NOT NULL,
    RequestID INT NOT NULL,
    TotalRequests INT NOT NULL,		-- Count metric
    CompletedRequests INT NOT NULL,	-- Count metric
    AvgResolutionDays DECIMAL(5, 2) NOT NULL,	-- Calculated metric
    DurationDays INT NOT NULL,	-- Calculated metric
    Next_Insp_Date DATE NOT NULL,
    TotalNoOfInspections INT NOT NULL,		-- Count metrics
    FOREIGN KEY (StaffKey) REFERENCES Dim_Employee(EmployeeKey),
    FOREIGN KEY (DateKey) REFERENCES Dim_Date(DateKey),
    FOREIGN KEY (ApartmentKey) REFERENCES Dim_Apartment(ApartmentKey),
    FOREIGN KEY (BuildingKey) REFERENCES Dim_Building(BuildingKey),
    FOREIGN KEY (StatusKey) REFERENCES Dim_Status(StatusKey),
    FOREIGN KEY (ServiceTypeKey) REFERENCES Dim_ServiceType(ServiceTypeKey)
);







