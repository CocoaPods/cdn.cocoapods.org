#!/bin/bash
set -eo pipefail

rm -rf _specs
git clone https://github.com/CocoaPods/Specs --filter=blob:none --no-checkout --depth 1 -- _specs

cd _specs

echo "Setting up sparse checkout"
git config core.sparseCheckout true
git config core.sparseCheckoutCone true
echo '/*' > .git/info/sparse-checkout

echo "Performing checkout"
git checkout --progress
