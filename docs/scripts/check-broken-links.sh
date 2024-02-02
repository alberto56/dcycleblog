#!/bin/bash
#
# Check for broken links.
#
set -e

source ./config/versioned

echo "Testing links, including external links. Drupal.org links always show up as 403 forbidden even though they are not, so we are ignoring them."

docker run --rm \
  --network "$DOCKERNETWORK" \
  dcycle/broken-link-checker:3 http://"$DOCKERNAME" \
  --check-extern \
  --ignore-url "[./]drupal\.org\/"
echo ""
echo "Done checking for broken links!"
echo ""
