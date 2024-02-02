#!/bin/bash
set -e

docker build -f="Dockerfile-sass" -t docker-sass .
docker run --rm -v $(pwd):/src docker-sass compile . --force
