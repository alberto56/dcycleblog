#!/bin/bash
#
# Build the static site in ..
#
set -e

echo '=> Build the Jekyll site.'
docker build -f="Dockerfile-jekyll" -t dcycleblog-docker-image .
# This is required on CircleCI to avoid https://github.com/jekyll/jekyll/issues/7591
touch ./.jekyll-metadata
# On CircleCI, ./.jekyll-metadata, when the container tries to write to
# ./.jekyll-metadata during an incremental build, it does so using the
# "ubuntu" user, which, on the host, is "other". Therefore, "other" (o) needs
# "write" (+w) access to this file.
chmod o+w ./.jekyll-metadata
mkdir -p ./.jekyll-cache
mkdir -p ./_site
# If you change the image here also change it in ./scripts/deploy.sh
docker run --rm \
  --volume="$PWD:/srv/jekyll" \
  dcycleblog-docker-image \
  build --trace --incremental
