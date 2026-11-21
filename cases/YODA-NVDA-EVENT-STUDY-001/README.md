# YODA-NVDA-EVENT-STUDY-001

Research-only event study plus three-month forecast. Observe NVIDIA price drawdown from June 24 to November 20, 2026 (150 calendar days); use pre-window market/semiconductor returns to estimate abnormal returns; then generate conditional 60-session probability scenarios as of the November 20 close.

## Relationship to prior frozen Yoda work

Predecessor: cases/YODA-EDGAR-FILING-CONTEXT-001-successive-financial-state. It validated accession-specific source identity and exact context recovery in a SEC/EDGAR financial-state chain across Frontier, Kyber and Lakehouse without modifying Yoda/Kyber. It did NOT establish price forecasting skill.

This is a NEW standalone application module. It does not modify the predecessor, Yoda or Kyber. The generated SHA256 manifest is a portable evidence artifact, NOT evidence of completed Yoda integration.

## Run on Debian (POSIX shell, awk, sort, sha256sum, curl)

The GitHub file API may not preserve executable bits. Run through sh:

1. sh scripts/fetch.sh
2. sh scripts/run.sh
3. sh scripts/forecast.sh
4. sh scripts/backtest.sh
5. sha256sum -c evidence/FORECAST-MANIFEST.sha256

If Stooq denies requests, manually supply authoritative provider CSV data in data/raw/NVDA.csv, data/raw/QQQ.csv, data/raw/SOXX.csv. Required columns: Date,Open,High,Low,Close,Volume. Validate currency, corporate actions and adjustment convention. Do not fabricate prices.

Forecast outputs: results/forecast/summary.tsv, model-metadata.tsv, terminal-samples.tsv.
Backtest outputs: results/forecast/backtest.tsv and backtest-report.txt.

For an illustrative options payoff evaluation, copy options/quotes-template.tsv to options/quotes.tsv, replace all REPLACE values with executable broker bid/ask snapshots with the SAME confirmed UTC quote timestamp at the November 20 close, then run: sh scripts/options-evaluate.sh. Missing or invalid quotes produce NO_TRADE.

Do not interpret this as trading advice, a verified price target or a demonstrated predictive model. See FORECAST.md.
