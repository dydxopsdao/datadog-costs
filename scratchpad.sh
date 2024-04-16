# Get the list of metrics that we want to de-index.

# 1) Export a CSV at https://ap1.datadoghq.com/metric/summary?facet.configuration=-configured_tags&facet.query_activity=-queried&filter=dyd 

# 2) Convert the CSV to plain text list of metric names:

cat extract-1713265424899-metrics.csv | tail -n +2 | cut -d, -f1 > metrics.txt

# Authentication

export API_HOST="https://ap1.datadoghq.com" # note the "ap1", not "api" prefix in the URL. This is the Asia-Pacific region.
export DD_API_KEY="..." # see: https://ap1.datadoghq.com/organization-settings/api-keys
export DD_APP_KEY="..." # see: https://ap1.datadoghq.com/organization-settings/application-keys

# Note the "ap1", not "api" prefix in the URL. This is the Asia-Pacific region.

# List metrics

export from=1672531200 # 2023-01-01
curl -X GET "$API_HOST/metrics?from=${from}" \
-H "Accept: application/json" \
-H "DD-API-KEY: ${DD_API_KEY}" \
-H "DD-APPLICATION-KEY: ${DD_APP_KEY}"

# Get metric metadata

export metric_name="dydxprotocol.acknowledge_bridges_latency.count"
curl -X GET "$API_HOST/api/v1/metrics/${metric_name}" \
-H "Accept: application/json" \
-H "DD-API-KEY: ${DD_API_KEY}" \
-H "DD-APPLICATION-KEY: ${DD_APP_KEY}"

# Fetch metric tag configuration

export metric_name="dydxprotocol.acknowledge_bridges_latency.count"
curl -X GET "$API_HOST/api/v2/metrics/${metric_name}/all-tags" \
-H "Accept: application/json" \
-H "DD-API-KEY: ${DD_API_KEY}" \
-H "DD-APPLICATION-KEY: ${DD_APP_KEY}"

# De-index metric example (deindexing = setting tags config to empty)

for metric_name in $(cat metrics.txt); do
  echo -n "De-indexing metric: ${metric_name}... "
  curl -X POST "$API_HOST/api/v2/metrics/${metric_name}/tags" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "DD-API-KEY: ${DD_API_KEY}" \
  -H "DD-APPLICATION-KEY: ${DD_APP_KEY}" \
  -d @- << EOF
  {
    "data": {
      "type": "manage_tags",
      "id": "${metric_name}",
      "attributes": {
        "tags": [
        ],
        "metric_type": "count"
      }
    }
  }
