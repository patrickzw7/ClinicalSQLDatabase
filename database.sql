# Set global parameters
SET GLOBAL local_infile=1;

# Create the schema
CREATE SCHEMA clinical_schema;

# Use the schema
USE clinical_schema;



# Create the patients table
CREATE TABLE patients (
    PRIMARY KEY (patient_id),
    patient_id SMALLINT UNSIGNED AUTO_INCREMENT,
    first_name VARCHAR(20),
    last_name VARCHAR(20),
    sex CHAR(1),
    height_at_enroll DECIMAL(5, 2), /* here we use centimeters (cm) */
    weight_at_enroll DECIMAL(5, 2), /* here we use kilograms (kg) */
    birth_date DATE,
    enroll_date DATE,
    zip_code VARCHAR(10),
    phone VARCHAR(15),
    email VARCHAR(255)
);

# Create the notes table (fist child table)
CREATE TABLE notes (
	PRIMARY KEY (note_id),
	note_id SMALLINT UNSIGNED AUTO_INCREMENT,
    patient_id SMALLINT UNSIGNED,
    note_date DATE,
    note_type VARCHAR(20),
    note_text TEXT,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
);

# Create the lookup (medications) table
CREATE TABLE medications (
	PRIMARY KEY (med_id),
	med_id SMALLINT,
    med_name VARCHAR(255)
);

# Create the prescriptions table (second child table)
CREATE TABLE prescriptions (
	PRIMARY KEY (pre_id),
    pre_id INT UNSIGNED AUTO_INCREMENT,
    patient_id SMALLINT UNSIGNED,
    med_id SMALLINT,
    start_date DATE,
    end_date DATE,
    dose DECIMAL(8, 2),
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (med_id) REFERENCES medications(med_id)
);

# Create trigger for patients
DELIMITER //
CREATE TRIGGER patients_trigger
	BEFORE INSERT ON patients
	FOR EACH ROW
BEGIN 
	/* limit on sex */
    IF NEW.sex NOT IN ('M', 'F') THEN 
		SIGNAL SQLSTATE 'HY000'
        SET MESSAGE_TEXT = 'Sex incorrect';
	END IF;
    
	/* limit on height at enroll */
    IF NEW.height_at_enroll < 30 OR NEW.height_at_enroll > 250 THEN 
		SIGNAL SQLSTATE 'HY000'
        SET MESSAGE_TEXT = 'Height incorrect';
	END IF;
    
    /* limit on weight at enroll */
    IF NEW.weight_at_enroll < 1 OR NEW.weight_at_enroll > 600 THEN 
		SIGNAL SQLSTATE 'HY000'
        SET MESSAGE_TEXT = 'Weight incorrect';
	END IF;
    
	/* limit on enroll date */
	IF NEW.birth_date > NEW.enroll_date THEN 
		SIGNAL SQLSTATE 'HY000'
        SET MESSAGE_TEXT = 'Enroll date larger than birth date';
	END IF;
END //

# Create trigger for prescriptions
DELIMITER //
CREATE TRIGGER prescriptions_trigger
	BEFORE INSERT ON prescriptions
	FOR EACH ROW
BEGIN 
	IF NEW.start_date > NEW.end_date THEN
		SIGNAL SQLSTATE 'HY000'
        SET MESSAGE_TEXT = 'start date later than end date';
	END IF;
END //



# Data entry for the patient table (parent table)
INSERT INTO patients (patient_id, first_name, last_name, sex, height_at_enroll, weight_at_enroll, 
					  birth_date, enroll_date, zip_code, phone, email) 
VALUES
(1, 'John', 'Doe', 'M', 185, 72, '1993-03-05', '2022-01-07', '10044', '917-323-4567', 'jod3002@med.cornell.edu'),
(2, 'Jane', 'Doe', 'F', 168, 55, '1996-04-03', '2022-03-08', '10044', '917-332-7654', 'jad4009@med.cornell.edu'),
(3, 'Brie', 'Meng', 'F', 157, 42, '1998-03-05', '2022-03-17', '11001', '917-582-3067', 'brm2001@med.cornell.edu'),
(4, 'Jason', 'Picks', 'M', 198, 89, '1989-08-03', '2022-04-01', '60607', '217-932-3429', 'jasonp2@illinois.edu'),
(5, 'Logan', 'Paine', 'M', 179, 87, '1970-11-23', '2022-04-21', '94603', '341-932-3429', 'loganpainerocks@gmail.com'),
(6, 'Lesley', 'Paine', 'F', 161, 46, '1998-10-30', '2022-04-23', '94603', '341-932-3365', 'lesleypaine@gmail.com'),
(7, 'Rebecca', 'Weiss', 'F', 165, 46, '1976-10-30', '2022-04-23', '93082', '217-932-3365', 'becboss@gmail.com'),
(8, 'Ben', 'Weiss', 'M', 167, 72, '1989-12-22', '2022-04-26', '93082', '217-932-3325', 'benweiss@gmail.com'),
(9, 'Matt', 'Mosby', 'M', 169, 65, '1976-10-30', '2022-04-29', '93082', '217-932-3423', 'mmosby@gmail.com'),
(10, 'George', 'Rentz', 'M', 173, 67, '1940-11-03', '2022-05-06', '92039', '212-334-2343', 'georgerentz@ucla.edu'),
(11, 'Leo', 'Lasso', 'M', 182, 73, '1937-12-26', '2023-02-04', '61821', '217-764-2947','leowoo@gmail.com'),
(12, 'Natalie','Smith', 'F', 164, 62, '1986-05-26', '2023-02-22', '59487', '865-5487-8716','nataliensmith@berkley.edu'),
(13, 'David', 'Yang', 'M', 180, 75, '1991-09-09', '2023-02-23', '10011', '917-745-6376', 'yyshuai@gmail.com'),
(14,'Tina', 'Smith', 'F', 156, 60, '1958-08-05', '2023-02-28', '40059','915-432-5826', 'tinasmith@gmail.com'),
(15,'Camellia', 'Brown', 'F', 160, 85, '1968-04-07', '2023-03-01', '10362','847-938-8624', 'camelliabrown@gmail.com'),
(16,'Selina', 'Lee', 'F', 169, 50, '1986-03-20', '2023-03-06', '24663','683-284-8365', 'selinalee@gmail.com'),
(17,'Adam', 'Johnson', 'M', 189, 85, '1998-06-25', '2023-03-24', '91008','228-683-2947', 'adamjohnson@gmail.com'),
(18,'Alice', 'Williams', 'F', 166, 57, '1994-03-30', '2023-03-25', '10016','316-352-6325', 'alivewilliams@gmail.com'),
(19,'Angela', 'Hill', 'F', 173, 60, '1982-06-28', '2023-03-27', '10018','263-758-2574', 'angelahill@gmail.com'),
(20,'Bill', 'Stewart', 'M', 160, 80, '1956-08-30', '2023-04-15', '10253','183-532-8263', 'billstewart@yahoo.com');

# Data entry for the notes table (first child table)
INSERT INTO notes (note_id, patient_id, note_date, note_type, note_text)
VALUES
(1, 1, '2022-01-07', 'Combined', 'Got hit in the eye, left eye injured. Tylenol needed.'),
(2, 1, '2022-01-08', 'Treatment', 'Antibiotics polysporin also needed.'),
(3, 2, '2022-03-08', 'Description', 'Eye pain for one week.'),
(4, 2, '2022-03-08', 'Combined', 'Possibly because of allergies. Allergy drops needed.'),
(5, 3, '2022-03-17', 'Combined', 'Simply because watches too much TV, no medicine needed.'),
(6, 4, '2022-04-01', 'Description', 'Eye check, no problem found.'),
(7, 5, '2022-04-21', 'Description', 'Pinkeye.'),
(8, 6, '2022-04-23', 'Description', 'Pinkeye, got infected by father.' ),
(9, 6, '2022-04-23', 'Treatment', 'Antibiotics needed.'),
(10, 7, '2022-04-23', 'Treatment', 'Surgery, LASIK'),
(11, 8, '2022-04-26', 'Treatment', 'Surgery, LASIK performed, Tylenol given'),
(12, 9, '2022-04-29', 'Treatment', 'New Ortho-k needed.'),
(13, 10, '2022-05-06', 'Combined', 'Pinkeye, polysporin needed.'),
(14, 11, '2023-02-04', 'Description', 'Eye pain and cannot see clearly, cataract possibly.'),
(15, 11, '2023-02-04', 'Treatment', 'Antibiotic eye-drops shall be given after cataract surgery.'),
(16, 11, '2023-02-10', 'Result', 'Cataract surgery success.'),
(17, 12, '2023-02-22', 'Description', 'Eye check, no obvious problem.'),
(18, 13, '2023-03-01', 'Treatment', 'Surgery performed. Need to stay for observation.'),
(19, 15, '2023-03-02', 'Treatment', 'Antibiotics needed.'),
(20, 13, '2023-03-07', 'Result', 'Discharged.'),
(21, 16, '2023-03-06', 'Combined', 'Severely hit in the eye. Ice-pack needed.'),
(22, 16,  '2023-03-07', 'Treatment', 'Eye drops provided.'),
(23, 18, '2023-03-25', 'Result', 'No need for stay in hospital.'),
(24, 19, '2023-03-27', 'Treatment', 'Surgery, LASIK.'),
(25, 19, '2023-04-03', 'Result', 'Discharged.'),
(26, 20, '2023-04-15', 'Combined', 'Pinkeye, drops provided.');

# Data entry for the lookup table (medications table)
# Here you need to change the path to the path where you store the medications_lookup_data.csv file
LOAD DATA LOCAL INFILE 'D:\medications_lookup_data.csv'
INTO TABLE medications
FIELDS TERMINATED BY ","
LINES TERMINATED BY "\n"
IGNORE 1 ROWS
(med_id, med_name);

# Data entry for the prescriptions table (second child table)
INSERT INTO prescriptions (pre_id, patient_id, med_id, start_date, end_date, dose) 
VALUES
(1, 1, 1, '2022-01-07', '2022-01-14', 500),
(2, 1, 2, '2022-01-08', '2022-01-15', 2),
(3, 2, 3, '2022-03-08', '2022-03-15', 2),
(4, 3, 5, '2022-03-17', '2022-03-24', 1000),
(5, 5, 2, '2022-04-21', '2022-04-28', 2),
(6, 6, 2, '2022-04-23', '2022-04-30', 2),
(7, 7, 5, '2022-04-23', '2022-04-30', 2),
(8, 8, 1, '2022-04-26', '2022-05-03', 500),
(9, 10, 2, '2022-05-06', '2022-05-13', 2),
(10, 11, 5, '2023-02-10', '2023-02-17', 2),
(11, 16, 1, '2023-03-06', '2023-03-13', 500),
(12, 16, 4, '2023-03-07', '2023-03-14', 1000),
(13, 18, 1, '2023-03-25', '2023-04-01', 500),
(14, 19, 5, '2023-04-03', '2023-04-10', 2),
(15, 20, 2, '2023-04-15', '2023-04-22', 2),
(16, 12, 3, '2023-02-22', '2023-03-01', 2),
(17, 13, 5, '2023-02-23', '2023-03-02', 2),
(18, 14, 4, '2023-02-28', '2023-03-07', 1000),
(19, 15, 1, '2023-03-01', '2023-03-08', 500),
(20, 17, 3, '2023-03-24', '2023-03-31', 2),
(21, 17, 3, '2023-04-01', '2023-04-08', 3);



# Query 1
# This is a view in order to see for each patient, the last time they were on a prescription of a type of drug
# This should be saved as a view for convenience of access to the latest prescription end date for each patient with each drug,
# and there is no need to write a query again every time. 

CREATE VIEW patient_latest_pre_end AS
	SELECT p.patient_id,
		   p.first_name,
           p.last_name,
           m. med_name,
           MAX(pre.end_date) AS latest_pre_date
	FROM patients p
		INNER JOIN prescriptions AS pre 
		USING (patient_id)
		INNER JOIN medications AS m
		USING (med_id)
	GROUP BY p.patient_id, p.first_name, p.last_name, m.med_name
    ORDER BY p.patient_id;

SELECT *
FROM patient_latest_pre_end;



# Query 2
# The temporary table gets the age of each patient with the prescriptions they own.
# The query using the temporary table here first set the ages into three categories, "young", "middle age" and "elder".
# Then the query groups the number of total prescriptions written for people of each age category. 
 
CREATE TEMPORARY TABLE patient_age_med AS
	SELECT p.patient_id,
		   p.first_name,
           p.last_name,
           p.birth_date,
           TIMESTAMPDIFF(YEAR, p.birth_date, CURDATE()) AS age,
           m.med_name
	FROM patients p
        INNER JOIN prescriptions pre
        USING (patient_id)
		INNER JOIN medications m
        USING (med_id);

SELECT CASE
	WHEN age < 20 THEN 'Child/Teenager'
    WHEN age >= 20 AND age < 40 THEN 'Young'
    WHEN age >= 40 AND age < 60 THEN 'Middle-age'
    ELSE 'Elder'
    END as age_group,
    COUNT(*) AS count_prescriptions
FROM patient_age_med
GROUP BY age_group;



# Query 3
# The CTE is the information of each patient with each of their notes
# The query here is the count of notes for each sex of patients
WITH patient_notes AS (
	SELECT p.patient_id,
		   p.first_name,
           p.last_name,
           p.sex,
           n.note_id,
           n.note_text
	FROM patients p
		INNER JOIN notes AS n
        USING (patient_id)
)

SELECT sex, COUNT(*) AS note_count
FROM patient_notes
GROUP BY sex;



# Query 4
# We combine the note for each single patient with columns for different note types.
# We can compare the difference of notes in different note types,
# For example note classification tasks using NLP skills with samples for each patient.
# We can also find the duplicate or missing note details for each single patient. 
SELECT patient_id,
	MAX(CASE WHEN note_type = "Combined" THEN note_text END) AS note_combined,
    MAX(CASE WHEN note_type = "Description" THEN note_text END) AS note_description,
    MAX(CASE WHEN note_type = "Treatment" THEN note_text END) AS note_treatment,
    MAX(CASE WHEN note_type = "Result" THEN note_text END) as note_result
FROM notes
GROUP BY patient_id
ORDER BY patient_id;



# Query 5
# For the following query,
# We find pairs of people with the same height at enrollment. 
SELECT p1.patient_id AS patient_id_1,
	   p1.first_name AS first_name_1,
       p1.last_name AS last_name_1,
       p2.patient_id AS patient_id_2,
       p2.first_name AS first_name_2,
       p2.last_name AS last_name_2,
       p1.height_at_enroll
FROM patients p1
	INNER JOIN patients p2
    USING (height_at_enroll)
    WHERE p1.patient_id < p2.patient_id;



# Query 6
# For the following query,
# We find the tallest people, and account for ties. 
SELECT patient_id,
	   height_at_enroll
FROM patients
WHERE height_at_enroll = (
	SELECT MAX(height_at_enroll)
    FROM patients
);



# Query 7
# For the following query, 
# The query unions the note text and prescription text for each patient,
# So we can get both the note and prescription text for each patient, to get an overview. 
# We use UNION instead of UNION ALL to reduce the duplicates that might occur.

SELECT patient_id,
	   note_text AS info_text
FROM notes
WHERE note_type = "Treatment"
UNION
SELECT patient_id,
	   med_name AS info_text
FROM prescriptions
	INNER JOIN medications
    ON prescriptions.med_id = medications.med_id
ORDER BY patient_id;



# Query 8
# I am trying to display the average weight for patients on each medication,
# to tell similarities and differences between different medical groups. 
# I use OVER (PARTITION BY) here to find the average weight for patients on each medication. 
SELECT DISTINCT patient_id,
	   weight_at_enroll,
       med_id,
       AVG(weight_at_enroll) OVER (PARTITION BY med_id) AS avg_weight_med
FROM prescriptions
	INNER JOIN patients
    USING (patient_id);



# Query 9
# The following query ranks the height of each patient.
# We use the rank function so certain numbers are skipped when there are ties.
SELECT DISTINCT patient_id,
	   height_at_enroll,
       RANK () OVER (ORDER BY height_at_enroll DESC) AS height_rank
FROM patients;



# Query 10
# Question: what is the total number of patients, total number of prescription,
# and average number of prescriptions per patient for drug "Allergy Eye Drops"?

# For this query,
# We count the number of patient on this medicine,
# and the number of prescriptions related to this medicine,
# and the average prescription number per patient for this medicine,
# for the "Allergy Eye Drops".

# We can find the result is 3 patients and 4 prescriptions, 
# and average number of prescriptions per patient being 1.3333. 
SELECT m.med_id,
	   m.med_name,
       COUNT(DISTINCT pre.patient_id) AS patient_num,
       COUNT(pre.pre_id) AS prescription_num,
       COUNT(pre.pre_id) / COUNT(DISTINCT pre.patient_id) AS avg_pre_per_patient
FROM medications m
	INNER JOIN prescriptions pre 
    USING (med_id)
WHERE med_name like "%Allergy Eye Drops%"
GROUP BY m.med_id, m.med_name;


    
