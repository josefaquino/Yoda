SET TimeZone='UTC';
WITH predictions AS (
 SELECT is_fraud AS y,
 CAST(1.0/(1.0+EXP(-CAST(is_fraud_logits[2]-is_fraud_logits[1] AS FLOAT))) AS FLOAT) AS score
 FROM read_parquet('scores/*.parquet')
 WHERE YEAR(timestamp__orig)>=2018
), grouped AS (
 SELECT score, COUNT(*) AS n, SUM(y) AS positives
 FROM predictions GROUP BY score
), ranked AS (
 SELECT score, positives,
 SUM(n) OVER (ORDER BY score DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS predicted_positive,
 SUM(positives) OVER (ORDER BY score DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS true_positive
 FROM grouped
), metrics AS (
 SELECT *,
 MAX(true_positive) OVER () AS total_positive,
 MAX(predicted_positive) OVER () AS total_rows,
 true_positive*1.0/predicted_positive AS precision,
 2.0*true_positive/(predicted_positive+MAX(true_positive) OVER ()) AS f1
 FROM ranked
)
SELECT MAX(total_rows) AS test_rows,
 MAX(total_positive) AS test_fraud,
 SUM(positives*precision)/MAX(total_positive) AS auprc,
 MAX(f1) AS best_threshold_f1
FROM metrics;
