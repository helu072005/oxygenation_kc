WITH 

pat AS (
SELECT * FROM `oxygenators-209612.eicu.patient`),

pc AS (
SELECT * FROM `oxygenators-209612.eicu.patient_cohort`),

diag AS (
SELECT * FROM `oxygenators-209612.eicu.diagnosis`),


icd_code AS (
SELECT
diag.patientunitstayid,
SAFE_CAST(SUBSTR(diag.icd9code, 0, 3) as INT64) AS icd9code
FROM diag),


icd_presence AS (
SELECT
icd_code.patientunitstayid,
COUNT(CASE WHEN icd_code.icd9code BETWEEN 001 AND 139 THEN 1 END) > 0 AS has_infectous_disease,
COUNT(CASE WHEN icd_code.icd9code BETWEEN 140 AND 239 THEN 1 END) > 0 AS has_neoplasm_disease,
COUNT(CASE WHEN icd_code.icd9code BETWEEN 240 AND 279 THEN 1 END) > 0 AS has_endocrine_disease,
COUNT(CASE WHEN icd_code.icd9code BETWEEN 280 AND 289 THEN 1 END) > 0 AS has_blood_disease,
COUNT(CASE WHEN icd_code.icd9code BETWEEN 290 AND 319 THEN 1 END) > 0 AS has_mental_disease,
COUNT(CASE WHEN icd_code.icd9code BETWEEN 320 AND 389 THEN 1 END) > 0 AS has_nervous_disease,
COUNT(CASE WHEN icd_code.icd9code BETWEEN 390 AND 459 THEN 1 END) > 0 AS has_circulatory_disease,
COUNT(CASE WHEN icd_code.icd9code BETWEEN 460 AND 519 THEN 1 END) > 0 AS has_respiratory_disease,
COUNT(CASE WHEN icd_code.icd9code BETWEEN 520 AND 579 THEN 1 END) > 0 AS has_digestive_disease,
COUNT(CASE WHEN icd_code.icd9code BETWEEN 580 AND 629 THEN 1 END) > 0 AS has_urinary_disease,
COUNT(CASE WHEN icd_code.icd9code BETWEEN 630 AND 679 THEN 1 END) > 0 AS has_pregnancy_disease,
COUNT(CASE WHEN icd_code.icd9code BETWEEN 680 AND 709 THEN 1 END) > 0 AS has_skin_disease,
COUNT(CASE WHEN icd_code.icd9code BETWEEN 710 AND 739 THEN 1 END) > 0 AS has_muscle_disease,
COUNT(CASE WHEN icd_code.icd9code BETWEEN 740 AND 759 THEN 1 END) > 0 AS has_congenital_disease,
COUNT(CASE WHEN icd_code.icd9code BETWEEN 760 AND 779 THEN 1 END) > 0 AS has_perinatal_disease,
COUNT(CASE WHEN icd_code.icd9code BETWEEN 780 AND 799 THEN 1 END) > 0 AS has_other_disease,
COUNT(CASE WHEN icd_code.icd9code BETWEEN 800 AND 999 THEN 1 END) > 0 AS has_injury_disease,
COUNT(CASE WHEN icd_code.icd9code BETWEEN 410 AND 414 THEN 1 END) > 0 AS has_isachaemic_heart_disease,
COUNT(CASE WHEN icd_code.icd9code BETWEEN 427 AND 427 THEN 1 END) > 0 AS has_atrial_fibrillation_disease,
COUNT(CASE WHEN icd_code.icd9code BETWEEN 434 AND 434 THEN 1 END) > 0 AS has_stroke_disease
FROM icd_code
GROUP BY icd_code.patientunitstayid)



SELECT 
  pc.subject_id as patient_ID,
  pat.gender,
  pc.age,  
  pc.icu_length_of_stay,
  pc.max_fiO2,
  pat.hospitalid,
  pat.unittype,
--  pc.is_first_icu_stay,
  CASE WHEN pat.unitdischargestatus = "Alive" THEN 0 ELSE 1 END AS mortality_in_ICU,
  CASE WHEN pat.hospitaldischargestatus = "Alive" THEN 0 ELSE 1 END AS mortality_in_Hospt,
  icd_presence.*
FROM pc
INNER JOIN pat
  ON pc.icustay_id = pat.patientunitstayid
INNER JOIN icd_presence
  ON pc.icustay_id = icd_presence.patientunitstayid
