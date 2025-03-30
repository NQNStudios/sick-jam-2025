#! /bin/bash

if [ -z "$ITCH_PUSH" ]; then exit 0; fi

# -L follows redirects
# -O specifies output name
curl -L -o butler.zip https://broth.itch.ovh/butler/linux-amd64/LATEST/archive/default
unzip butler.zip
# GNU unzip tends to not set the executable bit even though it's set in the .zip
chmod +x butler
butler -V
butler push export nqn/sliming:html