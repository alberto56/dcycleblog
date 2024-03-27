#!/bin/bash
set -e

source ./config/versioned

./scripts/destroy.sh
./scripts/build-static-site.sh

docker network ls | grep "$DOCKERNETWORK" || docker network create "$DOCKERNETWORK"

docker run --rm -d \
  --name "$DOCKERNAME" \
  --network "$DOCKERNETWORK" \
  -p "$DOCKERPORT":80 -v "$PWD/docs/_site":/usr/share/nginx/html:ro nginx:alpine

echo ""
echo "Visitez http://0.0.0.0:$DOCKERPORT pour voir le site localement."
echo ""
echo "Utilisez ./scripts/destroy.sh pour arrêter l'environnement local."
echo ""
