CREATE TABLE Countries(
	CountriesId SERIAL PRIMARY KEY,
	Name VARCHAR(40) NOT NULL,
	Population INT CHECK (Population > 0),
	AverageSalary FLOAT CHECK (AverageSalary > 0)
);

CREATE TABLE FitnessCenters(
	FitnessCentersId SERIAL PRIMARY KEY,
	Name VARCHAR(50),
	OpeningTime TIME,
	ClosingTime TIME,
	CountryId INT,
	FOREIGN KEY (CountryId) REFERENCES Countries(CountriesId)
);
ALTER TABLE FitnessCenters 
	ADD CONSTRAINT UniqueName UNIQUE(Name, CountryId);

CREATE TABLE Users(
	UsersId SERIAL PRIMARY KEY,
	Name VARCHAR(30),
	Surname VARCHAR(30),
	Birth DATE,
	Gender CHAR CHECK (Gender IN ('M', 'F', 'U')),
	FitnessCenterId INT,
	FOREIGN KEY (FitnessCenterId) REFERENCES FitnessCenters(FitnessCentersId)
);

CREATE TABLE Trainers(
	TrainersId SERIAL PRIMARY KEY,
	Name VARCHAR(30),
	Surname VARCHAR(30),
	Birth DATE,
	Gender CHAR CHECK (Gender IN ('M', 'F', 'U')),
	CountryId INT NOT NULL,
	FitnessCenterId INT NOT NULL,
	FOREIGN KEY (CountryId) REFERENCES Countries(CountriesId),
	FOREIGN KEY (FitnessCenterId) REFERENCES FitnessCenters(FitnessCentersId)
);
ALTER TABLE Trainers
	ADD CONSTRAINT UniqueNameSurnameFitness UNIQUE(Name, Surname, fitnesscenterid);

CREATE TABLE ActivityType(
	ActivityTypeId SERIAL PRIMARY KEY,
	TypeOfActivity VARCHAR(30) CHECK (TypeOfActivity IN ('strength', 'cardio', 'yoga', 'dance', 'injury rehabilitation'))
);

CREATE TABLE Activities(
	ActivitiesId SERIAL PRIMARY KEY,
	TypeOfActivityId INT CHECK (TypeOfActivityId BETWEEN 1 AND 5),
	Price INT Check (Price > 0),
	FOREIGN KEY (TypeOfActivity) REFERENCES ActivityType(ActivityTypeId)
);

CREATE TABLE TrainerActivity(
	TrainerId INT,
	ActivityId INT,
	TypeOfTrainer VARCHAR(30) CHECK (TypeOfTrainer IN ('Glavni', 'Pomocni')),
	FOREIGN KEY (TrainerId) REFERENCES Trainers(TrainersId),
	FOREIGN KEY (ActivityId) REFERENCES Activities(ActivitiesId)
);
ALTER TABLE TrainerActivity
	ADD CONSTRAINT UniqueTrainerActivity UNIQUE (TrainerId, ActivityId);

CREATE TABLE ActivityUser(
	ActivityId INT,
	UserId INT,
	FOREIGN KEY (ActivityId) REFERENCES Activities(ActivitiesId),
	FOREIGN KEY (UserId) REFERENCES Users(UsersId)
);
ALTER TABLE ActivityUser
	ADD CONSTRAINT ActivityUserUnique UNIQUE (ActivityId, UserId);

CREATE TABLE Schedule(
	ScheduleId SERIAL PRIMARY KEY,
	Code INT UNIQUE NOT NULL,
	ActivityId INT NOT NULL,
	StartingTime TIMESTAMP,
	EndingTime TIMESTAMP,
	Capacity INT CHECK (Capacity > 0),
	FOREIGN KEY (ActivityId) REFERENCES Activities(ActivitiesId)
);
ALTER TABLE Schedule
	DROP COLUMN StartingTime,
	DROP COLUMN EndingTime;
ALTER TABLE Schedule
	ADD COLUMN ActivityStart TIMESTAMP;


CREATE OR REPLACE FUNCTION check_trainer_limit()
RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT COUNT(*)
        FROM TrainerActivity
        WHERE TrainerId = NEW.TrainerId AND TypeOfTrainer = 'Glavni') > 2 THEN
        RAISE EXCEPTION 'Trener moze biti glavni na max 2 aktivnosti';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER limit_trainer
BEFORE INSERT OR UPDATE ON TrainerActivity
FOR EACH ROW
WHEN (NEW.TypeOfTrainer = 'Glavni')
EXECUTE FUNCTION check_trainer_limit();