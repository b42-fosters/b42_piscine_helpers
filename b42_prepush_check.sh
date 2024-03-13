#!/usr/bin/env bash

# Needed for type builtin and globstar shell option
[ -z "$BASH_VERSION" ] && { echo "Script must be run with bash!"; exit 1; }

git_root="$(git rev-parse --show-toplevel)"

pushd -- "$git_root" >/dev/null || {  echo "Couldn't change directory!"; exit 2; }
echo "== NORM"
"$(type -P norminette)"
norminette_status=$?

echo "== CC"
shopt -s globstar
cc -Wall -Wextra -Werror -c -- **/*.c
cc_status=$?
shopt -u globstar

echo "== Files in repo"
git ls-files
echo $?

echo "== Git uncommited"
git status --short --untracked-files=no
uncommited_status=$(git status --short --untracked-files=no | wc -l)

RED='\033[0;91m'
GREEN='\033[0;32m'
NC='\033[m' # No Color
if [ "$norminette_status" -ne 0 ] ||
        [ "$cc_status" -ne 0 ] ||
        [ "$uncommited_status" -ne 0 ];
then
        echo -e "${RED}## SOME STEPS CAN BE IMPROVED."
        echo -e "Do you mind to take a deeper look there?${NC}"
else
        echo -e "${GREEN}## I THINK ALL GOOD HERE AT ${git_root}."
        echo -e "Good luck with evaluations!${NC}"
fi
popd >/dev/null
