WITH flattened_diagnoses AS (
    SELECT 
        claim_id,
        f.value:code::STRING as diagnosis_code,
        f.value:description::STRING as diagnosis_description,
        loaded_at
    FROM {{ source('raw_insurance', 'raw_claim_details') }},
    LATERAL FLATTEN(input => claim_json:diagnosis) f
),

flattened_treatments AS (
    SELECT 
        claim_id,
        f.value:procedureCode::STRING as procedure_code,
        f.value:amount::FLOAT as procedure_amount,
        f.value:date::DATE as procedure_date,
        loaded_at
    FROM {{ source('raw_insurance', 'raw_claim_details') }},
    LATERAL FLATTEN(input => claim_json:treatments) f
)

SELECT 
    cd.claim_id,
    cd.claim_json:providerId::STRING as provider_id,
    cd.claim_json:providerDetails.name::STRING as provider_name,
    cd.claim_json:providerDetails.npi::STRING as provider_npi,
    cd.claim_json:providerDetails.specialty::STRING as provider_specialty,
    cd.claim_json:patientInfo.age::INT as patient_age,
    cd.claim_json:patientInfo.gender::STRING as patient_gender,
    d.diagnosis_code,
    d.diagnosis_description,
    t.procedure_code,
    t.procedure_amount,
    t.procedure_date,
    cd.loaded_at as record_loaded_at
FROM {{ source('raw_insurance', 'raw_claim_details') }} cd
LEFT JOIN flattened_diagnoses d
    ON cd.claim_id = d.claim_id
LEFT JOIN flattened_treatments t
    ON cd.claim_id = t.claim_id