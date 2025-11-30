--creation of database
CREATE DATABASE imaginary_hospital
WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LOCALE_PROVIDER = 'libc'
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;

-- creation of database objects

-- departments table (Corrected Syntax)
CREATE TABLE departments (
    dept_id VARCHAR(4) PRIMARY KEY,
    department_name VARCHAR(50) NOT NULL
);

-- patients table
DROP TABLE IF EXISTS patients;
CREATE TABLE patients (
    patient_id VARCHAR(4) PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    patient_telephone VARCHAR(15),
    date_of_birth DATE NOT NULL,
    sex CHAR(1) CHECK (sex IN ('M', 'F')),
    address VARCHAR(100),
    dept_id VARCHAR(4) REFERENCES departments(dept_id) NOT NULL
);

-- medical_history table
DROP TABLE IF EXISTS medical_history;
CREATE TABLE medical_history (
    history_ID VARCHAR(5) PRIMARY KEY,
    patient_id VARCHAR(4) REFERENCES patients(patient_id) NOT NULL,
    recorded_date DATE NOT NULL,
    ICD_code VARCHAR(10) NOT NULL,
    condition_name VARCHAR(100) NOT NULL,
    dept_ID VARCHAR(4) REFERENCES departments(dept_id) NOT NULL
);
SELECT * FROM departments
ORDER BY dept_id ASC

INSERT INTO locations (location_id, location_name, dept_id)
VALUES ('L004', 'small clinic', 'D105'); #Deliberate error creation to test constraints

--spark SQL for testing in Fabric

%%sql
SELECT * FROM medical_history

%%sql
SELECT * FROM medical_history
WHERE patient_id = "P003"
