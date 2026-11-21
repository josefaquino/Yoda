# Yoda Forecast Engine v0.1 (research, not live trading)

As-of: 2026-11-20 close. Horizon: 60 NYSE sessions, through the 2027-02-19 monthly options expiry (validate exchange holidays). Currency USD, ticker NVDA.

## Algorithm

- Compute historical NVDA close-to-close daily log returns.
- Use the last 100 eligible returns (minimum 60), no post-origin observations.
- Subtract the sample mean. Forward return drift is deliberately zero; the model does not assume either recovery or further decline.
- Estimate current daily volatility with EWMA lambda=0.94.
- Resample overlapping five-session blocks of centered historical returns, scaling their dispersion to current EWMA volatility.
- Fixed pseudorandom seed=20261120; simulate 10,000 terminal prices at a 60-session horizon.
- Report 5/10/50/90/95th percentiles and probabilities of down/up moves of at least ten percent.

The method is a conditional risk-scenario generator, not a calibrated direction forecast. Zero drift, fixed future volatility, historical tail frequency and block length are simplifying assumptions. An extreme information shock may violate all of them.

## Validation

A walk-forward procedure makes forecasts at past origins with strictly earlier inputs and evaluates their realized terminal prices 60 sessions later. It compares median absolute percentage error against the price-persistence benchmark and reports interval coverage. Overlapping outcomes and few test origins reduce statistical reliability. A PASS status for script execution does NOT imply statistically demonstrated predictive edge.

The QQQ and SOXX price series inform the separate event-study factor model. They do NOT enter the current forecasting simulation, and the EDGAR filing facts are provenance/context only. Add real event or factor predictors only after independent point-in-time validation.

## Options research candidate

Buy a Feb 19 2027 NVDA 125 PUT and sell a Feb 19 2027 NVDA 105 PUT, same number of contracts. Bear put debit spread; it would gain at expiry from a sufficiently large decline in NVDA. Let D be the actual net debit per share, calculated using long leg ask minus short leg bid. Each standard 100-share spread then has maximum loss=100*D, maximum gain=100*(20-D), expiry breakeven=125-D.

The evaluator refuses absent or malformed quotes, requires matching contract IDs, matching timestamps and 0<D<20. It estimates intrinsic-at-expiry payoffs using the simulated terminal price distribution, excluding fees, early assignment, financing and model error. The source of quotes must be independently verified. Options quotations on third-party sites may be stale or inconsistent with the underlying stock price.

Even with a favorable simulation, NO LIVE ORDER may be justified without reliable independent forecast backtests, up-to-date broker bids/asks and a risk budget. No execution interface is included.

## Evidence and provenance

The application produces SHA-256 fingerprints of input prices, code, seed/model metadata, and simulated results. To validate preservation through Yoda itself, use the already-proven Frontier/Yoda/Kyber/Lakehouse pipeline under the actual installed public interface; do not assert that these standalone scripts have executed the Yoda ingest path.

Frozen predecessor remains untouched. Source identity, file adjustment policy, corporate actions, source timestamps and all reproducibility failures must be recorded.
