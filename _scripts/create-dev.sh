#!/bin/bash
# Builds a complete development environment using Docker.
# See http://dcycleproject.org/blog/113
set -e

# Start by destroying previous development environments.
./_scripts/destroy-dev.sh

# Create a new container.
docker run --name dcycle-jekyll-site-container -d -p 4000 -v "$PWD:/srv/jekyll" jekyll/jekyll:pages

echo " => Your site is available at $(./_scripts/url.sh)"
