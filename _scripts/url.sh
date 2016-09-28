#!/bin/bash
set -e

# Find the port.
PORT=$(docker ps|grep dcycle-jekyll-site-container|sed \
  's/.*0.0.0.0://g'|sed 's/->.*//g')

# Display result.
echo "http://localhost:$PORT"
