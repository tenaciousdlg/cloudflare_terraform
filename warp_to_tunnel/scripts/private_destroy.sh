#!/bin/bash
# Instructs a shell (script) to exit if a command fails, i.e., if it outputs a non-zero (error) exit status.
set -e

function route_delete() {
    cloudflared tunnel route ip delete ${private_ip}/32
}
# Main program
route_delete