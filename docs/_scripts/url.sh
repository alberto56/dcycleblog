#!/bin/bash
set -e

# Find the port.
PORT=$(docker ps|grep dcycle-jekyll-apache-container|sed \
  's/.*0.0.0.0://g'|sed 's/->.*//g')

# Display result.
echo "http://localhost:$PORT"
