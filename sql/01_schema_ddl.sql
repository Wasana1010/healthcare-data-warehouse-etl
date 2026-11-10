-- ==============================================================================
-- Healthcare Data Warehouse Schema DDL (PostgreSQL)
-- Architecture: Star Schema with Surrogate Keys
-- ==============================================================================

-- Drop tables if exists (clean reload)
DROP TABLE IF EXISTS fact_appointment CASCADE;
DROP TABLE IF EXISTS dim_patient CASCADE;
DROP TABLE IF EXISTS dim_doctor CASCADE;
DROP TABLE IF EXISTS dim_clinic CASCADE;
DROP TABLE IF EXISTS dim_date CASCADE;

-- 1. Patient Dimension
CREATE TABLE dim_patient (
    patient_key INTEGER PRIMARY KEY,
    patient_id VARCHAR(20) NOT NULL,
    gender VARCHAR(10),
    date_of_birth DATE,
    district VARCHAR(100)
);

-- 2. Doctor Dimension
CREATE TABLE dim_doctor (
    doctor_key INTEGER PRIMARY KEY,
    doctor_id VARCHAR(20) NOT NULL,
    doctor_name VARCHAR(100) NOT NULL,
    specialty VARCHAR(100) NOT NULL
);

-- 3. Clinic Dimension
CREATE TABLE dim_clinic (
    clinic_key INTEGER PRIMARY KEY,
    clinic_id VARCHAR(20) NOT NULL,
    clinic_name VARCHAR(100) NOT NULL,
    city VARCHAR(100),
    province VARCHAR(100)
);

-- 4. Date Dimension
CREATE TABLE dim_date (
    date_key INTEGER PRIMARY KEY,
    full_date DATE NOT NULL,
    year INTEGER NOT NULL,
    quarter INTEGER NOT NULL,
    month INTEGER NOT NULL,
    day_name VARCHAR(20) NOT NULL
);

-- 5. Appointment Fact Table
CREATE TABLE fact_appointment (
    appointment_id SERIAL PRIMARY KEY,
    patient_key INTEGER NOT NULL,
    doctor_key INTEGER NOT NULL,
    clinic_key INTEGER NOT NULL,
    date_key INTEGER NOT NULL,
    wait_minutes INTEGER,
    consultation_minutes INTEGER,
    fee NUMERIC(10,2) NOT NULL,

    CONSTRAINT fk_patient
        FOREIGN KEY (patient_key)
        REFERENCES dim_patient(patient_key)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    CONSTRAINT fk_doctor
        FOREIGN KEY (doctor_key)
        REFERENCES dim_doctor(doctor_key)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    CONSTRAINT fk_clinic
        FOREIGN KEY (clinic_key)
        REFERENCES dim_clinic(clinic_key)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    CONSTRAINT fk_date
        FOREIGN KEY (date_key)
        REFERENCES dim_date(date_key)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- Create indexes on Foreign Keys for high-performance join aggregations
CREATE INDEX idx_fact_patient ON fact_appointment(patient_key);
CREATE INDEX idx_fact_doctor ON fact_appointment(doctor_key);
CREATE INDEX idx_fact_clinic ON fact_appointment(clinic_key);
CREATE INDEX idx_fact_date ON fact_appointment(date_key);
