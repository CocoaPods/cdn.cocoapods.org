#!/bin/bash
set -eo pipefail

mkdir -p _specs/_site || true

# generate sharded index
bundle exec ruby Scripts/create_pods_and_versions_index.rb 

cp _specs/*.yml _specs/_site/
cp index.html _specs/_site