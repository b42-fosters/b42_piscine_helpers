#!/usr/bin/env bash

# Needed for type builtin and globstar shell option
[ -z "$BASH_VERSION" ] && { echo "Script must be run with bash!"; exit 1; }

RED='\033[91m'
GREEN='\033[32m'
NC='\033[m' # No Color

git_root="$(git rev-parse --show-toplevel)"

summary_status=""

pushd "$git_root" >/dev/null || {  echo "Couldn't change directory!"; exit 2; }
echo "== NORM"
norminette
norminette_status=$?
summary_status="${summary_status}.${norminette_status}"

echo "== CC"
shopt -s globstar
cc -Wall -Wextra -Werror -c ./**/*.c
cc_status=$?
shopt -u globstar
summary_status="${summary_status}.${cc_status}"
# https://github.com/b42-fosters/b42_helpers/issues/3

echo "== Files in repo"
git ls-files

echo "== Git uncommited"
git status --short --untracked-files=no
uncommited_status=$(git status --short --untracked-files=no | wc -l | tr -d ' ')
summary_status="${summary_status}.${uncommited_status}"

echo "== Filename to function name"
not_found=0
OLDIFS="${IFS}"
IFS=$'\n'
for fname in $(find . -name 'ft_*.c'); do
	func_name="$(basename -s .c -- "$fname")"
	# grep "^/.*$func_name" "$fname"	# Check for fname in header
	grep -EH "^(char|int|void|long)\s+\**${func_name}\(" "$fname" # Check for the function declaration
	rc=$?
	not_found=$((not_found + rc))
	if [ $rc -ne 0 ]; then
		echo -e "${RED}${fname}${NC}: can't find declaration for the function ${GREEN}${func_name}${NC}"
	fi
done
IFS="${OLDIFS}"
summary_status="${summary_status}.${not_found}"

summary_status="${summary_status}."
summary_status_filtered=$(echo "$summary_status" | tr -d '.0')
echo "Checks summary code: ${summary_status}"
if [ "$summary_status_filtered" != "" ];
then
	echo -e "${RED}## SOME STEPS CAN BE IMPROVED."
	echo -e "Do you mind to take a deeper look there?${NC}"
else
	echo -e "${GREEN}## I THINK ALL GOOD HERE AT ${git_root}."
	echo -e "Good luck with evaluations!${NC}"
fi
popd >/dev/null || {  echo "Couldn't change directory!"; exit 3; }
