SELECT *
FROM dbo.HRData
ORDER BY StoreLocation ASC

---First, I am going to clean up this data by rounding the age, length of service, and absent hours
---The query below demonstrates how to round down, since we are working with age and do not want to round up

SELECT FLOOR(Age) AS RoundedAge
FROM dbo.HRData

ALTER TABLE dbo.HRData
ADD RoundedAge FLOAT

UPDATE dbo.HRData
SET RoundedAge = FLOOR(age)

---Next, we will round the length of service and absent hours to 2 decimal places

SELECT ROUND(LengthService, 2) AS RoundedLengthService,
ROUND(AbsentHours, 2) AS RoundedAbsentHours
FROM dbo.HRData

ALTER TABLE dbo.HRData
ADD RoundedLengthService FLOAT

UPDATE dbo.HRData
SET RoundedLengthService = ROUND(LengthService, 2)

ALTER TABLE dbo.HRData
ADD RoundedAbsentHours FLOAT

UPDATE dbo.HRData
SET RoundedAbsentHours = ROUND(AbsentHours, 2)

---Next, we will change 'M' and 'F' to 'Male' and 'Female'

SELECT Gender
,		CASE WHEN Gender = 'M' THEN 'Male'
			 WHEN Gender = 'F' THEN 'Female'
				ELSE Gender
				END
FROM dbo.HRData

UPDATE dbo.HRData
SET Gender = CASE WHEN Gender = 'M' THEN 'Male'
			 WHEN Gender = 'F' THEN 'Female'
				ELSE Gender
				END

---Many employees in this data set are under the age of 15, so lastly, we will delete those rows from the dataset

SELECT * 
FROM dbo.HRData
WHERE RoundedAge < 15
ORDER BY RoundedAge ASC

---This data states that 34 employees are between the ages of 3 and 14, since this is likely innacurate we will delete these rows

DELETE FROM dbo.HRData
WHERE RoundedAge < 15


---Now that the data is clean and more workable, we can start exploring the dataset

---What is the average number of absent hours by each department compared to the average length of service?

SELECT DepartmentName, ROUND(AVG(RoundedAbsentHours), 2) AS AbsentHoursByDepartment, 
ROUND(AVG(RoundedLengthService), 2) AS AverageLengthService
FROM dbo.HRData
GROUP BY DepartmentName
ORDER BY AbsentHoursByDepartment DESC

SELECT DepartmentName, ROUND(AVG(RoundedAbsentHours), 2) AS AbsentHoursByDepartment, 
ROUND(AVG(RoundedLengthService), 2) AS AverageLengthService
FROM dbo.HRData
GROUP BY DepartmentName
ORDER BY AverageLengthService ASC

---The processed foods department has the highest average absent hours, as well as the lowest average length of service

--- At this company, are males or females absent from work more frequently?

SELECT DISTINCT(Gender), COUNT(Gender) AS CountGender 
FROM dbo.HRData
GROUP BY Gender
ORDER BY CountGender DESC

---There are 4204 male employees and 4098 female employees at this company, so the sample size is adequate

SELECT DISTINCT(Gender), COUNT(Gender) AS CountGender, ROUND(AVG(RoundedAbsentHours), 2) AS AbsentHoursByGender,
ROUND(Avg(RoundedLengthService), 2) AS LengthServiceByGender
FROM dbo.HRData
GROUP BY Gender
ORDER BY AbsentHoursByGender DESC

---The average length of service by gender is nearly identical, but females average about 10 more absent hours than males

---Which stores have the highest average rate of absence?

SELECT DISTINCT(StoreLocation), ROUND(AVG(RoundedAbsentHours), 2) AS AbsentHoursByStore, COUNT(JobTitle) AS NumberOfEmployees,
ROUND(AVG(RoundedLengthService), 2) AS AverageEmployeeTenure
FROM dbo.HRData
GROUP BY StoreLocation
ORDER BY AbsentHoursByStore DESC

---This query presents a list of which stores have the most absence in descending order, along with how many employees work at each store

---Next, it may be important to identify the following minimum and maximum data points

SELECT MAX(RoundedLengthService) AS LongestTenure,
MAX(RoundedAge) AS OldestEmployee,
MAX(RoundedAbsentHours) AS MostAbsentHours,
MIN(RoundedLengthService) AS ShortestTenure,
MIN(RoundedAge) AS YoungestEmployee,
MIN(RoundedAbsentHours) AS LeastAbsentHours
FROM dbo.HRData

---From this query, I identified errors in the age of employees in the dataset, so I went ahead and deleted those rows in an earlier query

---Lastly, I want to see if there is correlation between absent hours and whether an employee works in-store or in the back office

SELECT DISTINCT(BusinessUnit), ROUND(AVG(RoundedAbsentHours), 2) AS AbsentHoursByBusinessUnit,
ROUND(AVG(RoundedLengthService), 2) AS AverageLengthService
FROM dbo.HRData
GROUP BY BusinessUnit

---The average length of service is about 4 and a half years for in-store employees, and about 14.7 years for back-office employees 
---Despite this, the average absent hours is about 14 more hours for in-store employees





