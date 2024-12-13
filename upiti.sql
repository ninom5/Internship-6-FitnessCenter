-- 1.UPIT
SELECT t.trainersid, t.name, t.surname, 
    CASE 
        WHEN t.gender = 'M' THEN 'MUŠKI'
        WHEN t.gender = 'F' THEN 'ŽENSKI'
        WHEN t.gender = 'U' THEN 'NEPOZNATO'
        WHEN t.gender = 'R' THEN 'OSTALO'
        ELSE 'NEPOZNATO'
    END AS gender,
    c.name AS Country, 
    c.averagesalary AS average_salary
FROM Trainers t
JOIN Countries c ON c.countriesid = t.countryid;

-- 2.UPIT
SELECT 
    at.typeofactivity AS "Naziv",
    s.ActivityStart AS "Termin",
    STRING_AGG(
        CONCAT(t.Surname, ', ', LEFT(t.Name, 1), '.'),
        '; '
    ) AS "Glavni trener"
FROM 
    Schedule s
JOIN Activities a ON s.ActivityId = a.ActivitiesId
JOIN ActivityType at ON a.typeofactivityid = at.activitytypeid
JOIN TrainerActivity ta ON ta.ActivityId = a.ActivitiesId AND ta.TypeOfTrainer = 'Glavni'
JOIN Trainers t ON ta.TrainerId = t.TrainersId
GROUP BY 
    at.TypeOfActivity, s.ActivityStart
ORDER BY 
    s.ActivityStart;



-- 3.UPIT

SELECT fc.Name AS FitnessCenterName, COUNT(s.Code) AS BrojAktivnosti FROM FitnessCenters fc
JOIN Schedule s ON fc.FitnessCentersId = s.fitnesscenterid
GROUP BY 
	fc.Name
ORDER BY 
	BrojAktivnosti DESC
LIMIT 3;



-- 4.UPIT

SELECT t.Name, t.Surname, 
CASE
	WHEN COUNT(ta.ActivityId) = 0 THEN 'Dostupan'
	WHEN COUNT(ta.ActivityId) BETWEEN 1 AND 3 THEN 'Aktivan'
	ELSE 'Potpuno zauzet' END AS Availability
FROM Trainers t 
LEFT JOIN TrainerActivity ta ON ta.TrainerId = t.TrainersId
GROUP BY 
	t.TrainersId



-- 5.UPIT

SELECT u.Name, u.Surname, u.Gender FROM Users u
JOIN ActivityUser au ON au.userid = u.usersid
JOIN Activities a ON au.activityid = a.activitiesid



-- 6.UPIT 

SELECT DISTINCT t.trainersid, t.Name, t.Surname, ta.typeoftrainer FROM Trainers t
JOIN TrainerActivity ta ON t.TrainersId = ta.TrainerId
JOIN Activities a ON ta.ActivityId = a.ActivitiesId
JOIN Schedule s ON s.ActivityId = a.ActivitiesId
WHERE  
    s.ActivityStart BETWEEN '2019-01-01' AND '2022-12-31';


-- 7.UPIT

SELECT c.Name AS Country, at.TypeOfActivity, ROUND(AVG(sudjelovanja.TrenutnoSudionika), 2)
	AS Average
FROM Countries c
JOIN FitnessCenters f ON c.CountriesId = f.CountryId
JOIN Schedule s ON f.FitnessCentersId = s.FitnessCenterId
JOIN Activities a ON s.ActivityId = a.ActivitiesId
JOIN ActivityType at ON a.TypeOfActivityId = at.ActivityTypeId
LEFT JOIN 
    (SELECT 
        au.ActivityId, 
        COUNT(au.UserId) AS TrenutnoSudionika
    FROM 
        ActivityUser au
    GROUP BY 
        au.ActivityId) sudjelovanja ON a.ActivitiesId = sudjelovanja.ActivityId
GROUP BY 
    c.Name, at.TypeOfActivity
ORDER BY 
    c.Name, at.TypeOfActivity;


-- 8.UPIT

SELECT c.Name AS CountryName, 
       at.TypeOfActivity AS ActivityType,
       COUNT(au.UserId) AS Participations
FROM Countries c
JOIN FitnessCenters fc ON fc.CountryId = c.CountriesId
JOIN Users u ON u.FitnessCenterId = fc.FitnessCentersId
JOIN ActivityUser au ON au.UserId = u.UsersId
JOIN Activities a ON a.ActivitiesId = au.ActivityId
JOIN ActivityType at ON at.ActivityTypeId = a.TypeOfActivityId
WHERE at.TypeOfActivity = 'injury rehabilitation'
GROUP BY 
    c.Name, at.TypeOfActivity
ORDER BY 
    Participations DESC
LIMIT 10;



-- 9.UPIT

SELECT 
	a.activitiesid, at.TypeOfActivity, f.Name AS FitnessCenterName,
    COUNT(au.UserId) AS CurrentParticipants,
    s.Capacity AS MaxCapacity,
    CASE 
        WHEN COUNT(au.UserId) < s.Capacity THEN 'IMA MJESTA'
        ELSE 'POPUNJENO'
    END AS Status
FROM Activities a
JOIN Schedule s ON a.ActivitiesId = s.ActivityId
JOIN ActivityType at ON a.TypeOfActivityId = at.ActivityTypeId
JOIN FitnessCenters f ON s.FitnessCenterId = f.FitnessCentersId
LEFT JOIN ActivityUser au ON a.ActivitiesId = au.ActivityId
GROUP BY 
    a.activitiesid, at.TypeOfActivity, f.Name, s.Capacity
ORDER BY
	CurrentParticipants DESC

-- 10.UPIT

SELECT t.trainersid, t.Name, t.surname, t.gender, 
       SUM(COALESCE(au.ParticipantCount * a.Price, 0)) AS TotalIncome
FROM Trainers t
JOIN TrainerActivity ta ON ta.TrainerId = t.TrainersId
JOIN Activities a ON a.ActivitiesId = ta.ActivityId
LEFT JOIN (
    SELECT au.ActivityId, COUNT(au.UserId) AS ParticipantCount FROM ActivityUser au
    GROUP BY 
		au.ActivityId
) au ON au.ActivityId = a.ActivitiesId
GROUP BY 
	t.TrainersId, t.Name, t.Surname
ORDER BY 
	TotalIncome DESC
LIMIT 10;





