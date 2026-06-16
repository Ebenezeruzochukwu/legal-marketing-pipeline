-- ==========================================
-- LEGAL MARKETING PERFORMANCE PIPELINE VIEW
-- DESCRIPTION: Automated cleaning, schema mapping, and calculated fields
--              for tracking multi-million dollar ad spend and intakes.
-- TARGET WAREHOUSE: Google BigQuery
-- ==========================================

CREATE OR REPLACE VIEW `legal_marketing.v_performance_summary` AS
SELECT
    -- Campaign Metadata
    SAFE_CAST(campaign AS STRING) AS campaign_name,
    SAFE_CAST(state AS STRING) AS target_state,
    
    -- Financial Data Mapping (Handling currencies safely)
    SAFE_CAST(billable_amount AS NUMERIC) AS billable_spend,
    
    -- Volume Metric Extractions
    SAFE_CAST(intakes AS INT64) AS total_intakes,
    SAFE_CAST(retainers AS INT64) AS total_retainers,
    
    -- Safe Division for Cost Per Intake (CPI) to prevent Division-by-Zero errors
    SAFE_DIVIDE(SAFE_CAST(billable_amount AS NUMERIC), SAFE_CAST(intakes AS INT64)) AS cost_per_intake,
    
    -- Safe Division for Conversion Ratio (Intake-to-Retainer %)
    SAFE_DIVIDE(SAFE_CAST(retainers AS INT64), SAFE_CAST(intakes AS INT64)) AS intake_to_retainer_ratio,
    
    -- System Governance Metadata (Tracks pipeline freshness down to the second)
    CURRENT_TIMESTAMP() AS data_pipeline_freshness_utc

FROM
    `legal_marketing.raw_operational_data`
WHERE
    campaign IS NOT NULL;
