# YODA-NVDA-EVENT-STUDY-001

Research-only event study plus three-month forecast. Observe NVIDIA price drawdown from June 24 to November 20, 2026 (150 calendar days); use pre-window market/semiconductor returns to estimate abnormal returns; then generate conditional 60-session probability scenarios as of the November 20 close.

## Relationship to prior frozen Yoda work

Predecessor: cases/YODA-EDGAR-FILING-CONTEXT-001-successive-financial-state. It validated accession-specific source identity and exact context recovery in a SEC/EDGAR financial-state chain across Frontier, Kyber and Lakehouse without modifying Yoda/Kyber. It did NOT establish price forecasting skill.

This is a NEW standalone application module. It does not modify the predecessor, Yoda or Kyber. The generated SHA256 manifest is a portable evidence artifact, NOT evidence of completed Yoda integration.

## Run on Debian (POSIX shell, awk, sort, sha256sum, curl)

The GitHub file API may not preserve executable bits. Run through sh:

1. sh tests/nasdaq-parser-smoke.sh (local C11 syntax + fail-closed tests)
2. sh scripts/fetch.sh
3. sh scripts/run.sh
4. sh scripts/forecast.sh
5. sh scripts/backtest.sh
6. sha256sum -c evidence/FORECAST-MANIFEST.sha256

The fetcher now uses the Nasdaq public website historical endpoint (stocks: NVDA; ETF: QQQ, SOXX) through curl and a strict C11 JSON parser (requires a C11 compiler, e.g. `cc`). It saves unchanged raw JSON and CSV under data/raw/, with hashes in evidence/NASDAQ-SOURCE-MANIFEST.sha256. Nasdaq's website endpoint is undocumented; it may return null, rate-limit requests or change its schema. Run `sh tests/nasdaq-parser-smoke.sh` before fetching. Verify split adjustment, source coverage, terms of use and attribution; never fabricate or blindly redistribute market data. If unavailable, supply independently authorized CSVs with the same `Date,Open,High,Low,Close,Volume` schema.

Forecast outputs: results/forecast/summary.tsv, model-metadata.tsv, terminal-samples.tsv.
Backtest outputs: results/forecast/backtest.tsv and backtest-report.txt.

For an illustrative options payoff evaluation, copy options/quotes-template.tsv to options/quotes.tsv, replace all REPLACE values with executable broker bid/ask snapshots with the SAME confirmed UTC quote timestamp at the November 20 close, then run: sh scripts/options-evaluate.sh. Missing or invalid quotes produce NO_TRADE.

Do not interpret this as trading advice, a verified price target or a demonstrated predictive model. See FORECAST.md.
