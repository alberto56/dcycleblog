#!/bin/bash
# Builds a complete development environment using Docker.
# See http://dcycleproject.org/blog/113
set -e

# Start by destroying previous development environments.
./_scripts/destroy-dev.sh

./_scripts/build.sh

docker run \
  -dit \
  --name dcycle-jekyll-apache-container \
  -p 80 \
  -v "$PWD/_site":/usr/local/apache2/htdocs/ \
  httpd:2.4

echo " => Your site is available at $(./_scripts/url.sh)"
