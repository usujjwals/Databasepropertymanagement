-- Occupancy Trends (by building and year)


SELECT 
    BuildingID,
    Year,
    LeaseCount AS LeasedUnits
FROM Summary_LeaseCount_ByBuilding_Year
WHERE Year >= YEAR(CURDATE()) - 3
ORDER BY BuildingID, Year;

-- Rental Income by Building and Year
SELECT *
FROM Summary_RentalIncome_ByBuilding_Year
ORDER BY Year, TotalRentalIncome DESC;

-- Repeated Corporate Clients
SELECT *
FROM Summary_RepeatClients
ORDER BY TotalLeases DESC;


-- Staff Maintenance Performance
SELECT *
FROM Summary_MaintenancePerformanceByStaff
ORDER BY CompletedMaintenanceTasks DESC;


-- Cleaning Staff Productivity
SELECT *
FROM Summary_CleaningPerformanceByStaff
ORDER BY TotalCleanings DESC;


