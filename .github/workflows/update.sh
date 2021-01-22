#!/usr/bin/env bash

set -xeu

NIXPKGS_BRANCH=nixos-20.09

# Fetch unshallow
git fetch --unshallow

# Update the nixpkgs.json with the latest version of the branch
nix-prefetch-github --rev "refs/heads/$NIXPKGS_BRANCH" NixOS nixpkgs > nixpkgs.json

# Update Python packages
poetry update

# Only continue if there are any changes
if ! git diff-index --quiet HEAD; then
  today=$(date -I)
  # Commit the new changes and push them to the repository so a PR can be opened
  git checkout -b "package-update-$today"
  git config user.name "Package updater"
  git commit -a -m "Package update $today"
  git push -u origin "package-update-$today"
  hub pull-request --no-edit --assign zupo
fi
