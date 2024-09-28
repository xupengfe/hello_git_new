#!/bin/bash

repos_root=$(realpath "$(dirname "${BASH_SOURCE[0]}")")

for repo in $(find $repos_root -maxdepth 1 -type d); do
    if [ -d $repo/.git ]; then
        cd $repo
        echo "git config --global --add safe.directory $repo"
        git config --global --add safe.directory $repo
        cd - >/dev/null
    fi
done
