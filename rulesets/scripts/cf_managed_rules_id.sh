#!/bin/bash
# Credit for inspiration to https://gist.github.com/irvingpop/968464132ded25a206ced835d50afa6b
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

function produce_output() {
     curl -sX GET "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/rulesets" \
          -H "X-Auth-Email: ${EMAIL}" \
          -H "X-Auth-Key: ${TOKEN}" \
          -H "Content-Type: application/json" | \
          jq -r \
          '.result[] | select(.kind == "managed") | select (.name | contains ("Cloudflare Managed Ruleset"))'
}

# main program
check_dep
parse_input
produce_output 