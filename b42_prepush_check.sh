#!/bin/bash

git_root=$(git rev-parse --show-toplevel)

pushd "$git_root"
echo "== NORM"
norminette
norminette_status=$?

echo "== CC"
cc -Wall -Wextra -Werror -c */*.c
cc_status=$?

echo "== Files in repo"
git ls-files
echo $?

echo "== Git uncommited"
git status --short --untracked-files=no
uncommited_status=$(git status --short --untracked-files=no | wc -l)

RED='\033[0;91m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
if [ "$norminette_status" -ne 0 -o "$cc_status" -ne 0 -o "$uncommited_status" -ne 0 ];
then
	echo -e "$RED## SOME STEPS CAN BE IMPROVED."
	echo -e "Do you mind to take a deeper look there?$NC"
else
	echo -e "$GREEN## I THINK ALL GOOD HERE AT $git_root."
	echo -e "Good luck with evaluations!$NC"
fi
popd
