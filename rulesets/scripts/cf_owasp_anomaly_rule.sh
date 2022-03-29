#!/bin/bash
set -e 

# Error function that will respond with error message if check_dep function fails
function error_exit() {
     echo "$1" 1>&2
     exit 1
}

# Function to check if jq is installed as it is a dependency 
function check_dep() {
     test -f $(which jq) || error_exit "jq command not detected in path, please install it"
}

function parse_input() {
     eval "$(jq -r '@sh "export ZONE_ID=\(.cf_zone_id) EMAIL=\(.cf_user) TOKEN=\(.cf_token)"')"
}

function owasp_id() {
    curl -sX GET "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/rulesets" \
          -H "X-Auth-Email: ${EMAIL}" \
          -H "X-Auth-Key: ${TOKEN}" \
          -H "Content-Type: application/json" | \
          jq -r \
          '.result[] | select(.kind == "managed") | select (.name | contains ("Cloudflare OWASP Core Ruleset")) | .id'
}
     # Added the last jq pip of `jq '. | {id}'` to limit the output of this script to just the id key/value pair
     # The reason for this is this object/call prints strings (what terraform can use), numbers and
function produce_output() {
     OWASP_ID=$(owasp_id)
     curl -sX GET "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/rulesets/${OWASP_ID}" \
          -H "X-Auth-Email: ${EMAIL}" \
          -H "X-Auth-Key: ${TOKEN}" \
          -H "Content-Type: application/json" | \
          jq -r \
          '.result.rules[] | select(.description | contains ("949110: Inbound Anomaly Score Exceeded"))' | \
          jq 'del(.score_threshold, .enabled)'
}

# main program
check_dep
parse_input
produce_output 