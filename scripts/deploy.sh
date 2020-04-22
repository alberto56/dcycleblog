#!/bin/bash
set -e

./scripts/destroy.sh
./scripts/build-static-site.sh
docker run --rm -d --name dcycleblog -p 8081:80 -v "$PWD/_site":/usr/local/apache2/htdocs/ httpd:2.4

echo ""
echo "Visitez http://0.0.0.0:8081 pour voir le site localement."
echo ""
echo "Utilisez ./scripts/destroy.sh pour arrêter l'environnement local."
echo ""
