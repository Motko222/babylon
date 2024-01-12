#!/bin/bash

cd ~/scripts/babylon
git stash push --include-untracked
git pull
chmod +x *.sh
