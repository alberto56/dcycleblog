#!/bin/bash
# Kills the Docker development environment using Docker; all data is lost.
# See http://blog.dcycle.com/blog/113

docker kill dcycle-jekyll-apache-container 2>/dev/null \
  || echo 'Container not running, moving on...'
docker rm dcycle-jekyll-apache-container 2>/dev/null \
  || echo 'Container does not exist, moving on...'
