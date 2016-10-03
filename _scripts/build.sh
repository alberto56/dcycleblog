#!/bin/bash
set -e

docker build -f="Dockerfile-jekyll" -t dcycle-jekyll-site-image .

docker run \
  --rm \
  --name dcycle-jekyll-site-container \
  -v "$PWD:/srv/jekyll" \
  dcycle-jekyll-site-image /bin/bash -c "jekyll build --config _config.yml,_config_dev.yml"
