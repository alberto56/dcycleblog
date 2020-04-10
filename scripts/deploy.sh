#!/bin/bash
#
# Assuming you have the latest version Docker installed, this script will
# fully create your environment.
#
set -e

# See http://patorjk.com/software/taag/#p=display&f=Ivrit&t=Test%208
cat ./scripts/lib/ascii-art.txt

echo ''
echo 'About to try to get the latest version of images the Docker hub.'
docker pull httpd:2
docker pull jekyll/jekyll:pages

echo ''
echo '-----'
echo 'Updating the server if necessary.'
docker-compose up -d --build

echo ''
echo '-----'
echo 'About to build the Jekyll site.'
./scripts/build.sh

echo ''
echo '-----'
echo 'You can now visit your site:'
echo ''
URL=$(docker-compose port httpd 80)
echo " => Frontend: http://$URL"
echo " => Netlify backend: http://$URL/admin"
echo ''
