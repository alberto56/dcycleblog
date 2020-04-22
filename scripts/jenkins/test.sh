#!/bin/bash
#
# Run tests on a Docker host. Requirements:
# * https://github.com/dcycle/docker-digitalocean-php.
# * the dcycleblog droplet should be deleted in "Post-build Actions".
# * DOCKERHOSTUSER, DOCKERHOSTUSER set using Jenkins's
#   /credentials/store/system/domain/_/ section.
#
set -e

if [ -z "$DOCKERHOSTUSER" ] || [ -z "$DOCKERHOST" ]; then
  >&2 echo "Please configure DOCKERHOSTUSER and DOCKERHOST using"
  >&2 echo "Jenkins secrets (credentials) and export."
  exit 1
fi

# Create a droplet
IP=$(ssh "$DOCKERHOSTUSER@$DOCKERHOST" \
  "./digitalocean/scripts/new-droplet.sh dcycleblog")
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no \
  root@"$IP" \
  "git clone https://github.com/alberto56/dcycleblog.git && \
  cd site-web && \
  ./scripts/ci.sh"
