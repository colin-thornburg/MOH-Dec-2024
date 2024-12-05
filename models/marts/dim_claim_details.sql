SELECT 
    claim_id,
    provider_id,
    provider_name,
    provider_npi,
    provider_specialty,
    patient_age,
    patient_gender,
    diagnosis_code,
    diagnosis_description,
    procedure_code,
    procedure_amount,
    procedure_date,
    record_loaded_at
FROM {{ ref('stg_claim_details_flattened') }}