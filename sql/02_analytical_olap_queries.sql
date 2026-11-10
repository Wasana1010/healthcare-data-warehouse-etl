-- ==============================================================================
-- Healthcare Data Warehouse: Analytical OLAP & KPI Queries
-- Database: PostgreSQL
-- Author: Thilini Wasana
-- ==============================================================================

-- 1. Data Integrity & Warehouse Population Audit
SELECT
    (SELECT COUNT(*) FROM dim_patient) AS total_patients,
    (SELECT COUNT(*) FROM dim_doctor) AS total_doctors,
    (SELECT COUNT(*) FROM dim_clinic) AS total_clinics,
    (SELECT COUNT(*) FROM dim_date) AS total_dates,
    (SELECT COUNT(*) FROM fact_appointment) AS total_fact_appointments;

-- 2. Referential Integrity Verification (Orphan Key Check)
-- Expected result: 0 orphans across all dimension joins
SELECT
    COUNT(*) FILTER (WHERE p.patient_key IS NULL) AS orphan_patients,
    COUNT(*) FILTER (WHERE d.doctor_key IS NULL) AS orphan_doctors,
    COUNT(*) FILTER (WHERE c.clinic_key IS NULL) AS orphan_clinics,
    COUNT(*) FILTER (WHERE dt.date_key IS NULL) AS orphan_dates
FROM fact_appointment f
LEFT JOIN dim_patient p ON f.patient_key = p.patient_key
LEFT JOIN dim_doctor d ON f.doctor_key = d.doctor_key
LEFT JOIN dim_clinic c ON f.clinic_key = c.clinic_key
LEFT JOIN dim_date dt ON f.date_key = dt.date_key;

-- 3. Clinic Operational Performance & Average Wait Times
SELECT
    c.clinic_name,
    COUNT(*) AS total_appointments,
    ROUND(AVG(f.wait_minutes), 2) AS avg_wait_minutes,
    ROUND(AVG(f.consultation_minutes), 2) AS avg_consultation_minutes,
    ROUND(AVG(f.fee), 2) AS avg_consultation_fee
FROM fact_appointment f
JOIN dim_clinic c ON f.clinic_key = c.clinic_key
GROUP BY c.clinic_name
ORDER BY total_appointments DESC;

-- 4. Workload & Fee Analysis by Doctor Specialty (Hierarchical ROLLUP)
-- Multi-level aggregation calculating specialty subtotals and clinic-wide grand totals
SELECT
    COALESCE(d.specialty, 'ALL SPECIALTIES') AS specialty,
    COALESCE(d.doctor_name, 'Subtotal / Total') AS doctor_name,
    COUNT(*) AS appointment_count,
    ROUND(AVG(f.fee), 2) AS avg_fee,
    SUM(f.fee) AS total_revenue
FROM fact_appointment f
JOIN dim_doctor d ON f.doctor_key = d.doctor_key
GROUP BY ROLLUP (d.specialty, d.doctor_name)
ORDER BY
    d.specialty NULLS LAST,
    d.doctor_name NULLS LAST;

-- 5. Time-Series Revenue & Patient Volume Trends (Year / Quarter / Month)
SELECT
    dt.year,
    dt.quarter,
    dt.month,
    COUNT(*) AS appointment_volume,
    SUM(f.fee) AS total_revenue,
    ROUND(AVG(f.fee), 2) AS avg_ticket_size
FROM fact_appointment f
JOIN dim_date dt ON f.date_key = dt.date_key
GROUP BY dt.year, dt.quarter, dt.month
ORDER BY dt.year, dt.quarter, dt.month;
