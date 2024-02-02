#!/bin/bash

set -a

#CFG_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
#ROOT=$(cd -- $CFG_DIR/.. &> /dev/null && pwd )

#PACKER_PLUGIN_PATH=$ROOT/packer/plugins
#PACKER_CACHE_DIR=$ROOT/packer/cache

. packer/environment

# cleanup old images
find . -type d -name 'output-*' -exec rm -rf {} \;

for img in u2204
do
    echo "--- building image $img ---"
    cd $img && {
        packer build $img.pkr.hcl
        cd -
    }
done
