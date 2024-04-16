# See: https://ap1.datadoghq.com/metric/summary?facet.configuration=-configured_tags&facet.query_activity=-queried&filter=dydxprotocol
export CSV_FILE="extract-1713265424899-metrics.csv"

# Note the "ap1", not "api" prefix in the URL. This is the Asia-Pacific region.
export API_HOST="https://ap1.datadoghq.com"

# See: https://ap1.datadoghq.com/organization-settings/api-keys
export DD_API_KEY="..."

# See: https://ap1.datadoghq.com/organization-settings/application-keys
export DD_APP_KEY="..."

# ---

# Convert the CSV to plain text list of metric names
cat $CSV_FILE | tail -n +2 | cut -d, -f1 > metrics.txt

# De-index metrics (deindexing = setting tags config to empty)
for metric_name in $(cat metrics.txt); do
  echo -n "De-indexing metric: ${metric_name}... "

  metric_type=$(
    curl -s -X GET "${API_HOST}/api/v1/metrics/${metric_name}" \
    -H "Accept: application/json" \
    -H "DD-API-KEY: ${DD_API_KEY}" \
    -H "DD-APPLICATION-KEY: ${DD_APP_KEY}" \
    | jq -r '.type'
  )
  echo -n "(${metric_type})... "

  result=$(
    curl -s -X POST "${API_HOST}/api/v2/metrics/${metric_name}/tags" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -H "DD-API-KEY: ${DD_API_KEY}" \
    -H "DD-APPLICATION-KEY: ${DD_APP_KEY}" \
    -d '{
      "data": {
        "type": "manage_tags",
        "id": "'${metric_name}'",
        "attributes": {
          "tags": [
          ],
          "metric_type": "'${metric_type}'"
        }
      }
    }' \
    | jq -r '.errors'
  )

  if [ "$result" != "null" ]; then
    echo "error: ${result}"
  else
    echo "done."
  fi
done
