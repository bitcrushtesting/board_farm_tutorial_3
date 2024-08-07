#!/bin/bash -e

# Copyright © 2024 Bitcrush Testing

rm -rf pi-gen
git clone https://github.com/RPI-Distro/pi-gen.git --depth 1
cp -r ./custom-stage ./pi-gen/custom-stage
cd pi-gen || exit

touch ./stage3/SKIP ./stage4/SKIP ./stage5/SKIP
touch ./stage2/SKIP_IMAGES ./stage4/SKIP_IMAGES ./stage5/SKIP_IMAGES

# Check if the container named "pigen_work" exists
container_exists=$(docker ps -a --filter "name=pigen_work" --format "{{.ID}}")
if [ -n "$container_exists" ]; then
    echo "Container 'pigen_work' exists. Removing it."
    docker rm -f pigen_work
fi

./build-docker.sh -c ../config
