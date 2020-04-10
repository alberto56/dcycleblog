#!/bin/bash
set -e

echo " => Building our site"
docker-compose run --rm jekyll build
