#!/bin/bash
#
# Use GIT's Smudge and Clean filters to replace embedded passwords in selected files in the GIt repo.
# - https://developers.redhat.com/articles/2022/02/02/protect-secrets-git-cleansmudge-filter

## Add file filters to .gitattributes file

read -p "Filter name: " filter
read -s -p "Password: " pass

echo
echo "Appending to .gitattributes ..."

grep -l "$pass" | grep -v '\.exe$' | sed "s/.*/\0 filter=$filter/" | tee -a .gitattributes

echo "Check files added toend of .gitattributes file" >&2
echo "Recommit these files and change password" >&2
