#!/bin/bash

# This takes the CONTAINER_HOSTNAME environment variable specified on the balena dashboard or other method and uses mdns-publish-cname to create a CNAME record on mDNS.
# However, it sets a default of octobalena.local if nothing is provided.

if [[ -z "$CONTAINER_HOSTNAME" ]]; then
  mdns-publish-cname octobalena.local
else
  mdns-publish-cname ""$OCTOPRINT_HOSTNAME"".local
fi
