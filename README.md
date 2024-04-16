# datadog-costs
Script for optimizing Datadog spending.

## Rationale

A lot of mstrics collected from nodes by the Metric Ingestor are not used and generate costs.

The ones that are not used can be queried with:
https://ap1.datadoghq.com/metric/summary?facet.configuration=-configured_tags&facet.query_activity=-queried&filter=dyd 

These metrics can be exported to a CSV and then each one of them can be "de-indexed" via API, meaning that
it can be configured such that it contains no tags. This causes Datadog to not charge for it.

If in the future any of such metrics is required after all, the metric needs to be configured with "all tags".
It is easy to do via UI:
- https://ap1.datadoghq.com/metric/summary?facet.configuration=-all_tags&facet.query_activity=-queried&filter=dydxprotocol
- select a metric
- manage tags
- all tags
- save

Research is needed on how to do that via API but it should be possible.

## Usage

Fill in the enviroment variables at the beginning of the `deindex.sh` script and run it.
