#!/bin/bash

## Setup password filter as global GIT settings
## Password/Replace strings can't contain '/'

read -p "Filter name: " filter
read -s -p "Password: " pass
read -p "Replace with: " replace

git config --global "filter.${filter}.clean" "sed -e 's/${pass}/${replace}/g'"
git config --global "filter.${filter}.smudge" "sed -e 's/${replace}/${pass}/g'"
