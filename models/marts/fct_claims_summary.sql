SELECT
    c.policy_id,
    COUNT(DISTINCT c.claim_id) as total_claims,
    SUM(c.claim_amount) as total_claim_amount,
    MAX(c.claim_date) as latest_claim_date,
    COUNT(CASE WHEN cs.status = 'APPROVED' THEN 1 END) as approved_claims,
    AVG(c.claim_amount) as avg_claim_amount
FROM {{ ref('stg_claims') }} c
JOIN {{ ref('stg_claim_status') }} cs
    ON c.claim_id = cs.claim_id
GROUP BY c.policy_id