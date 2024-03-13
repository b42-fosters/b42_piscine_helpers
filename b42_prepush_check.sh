#!/bin/bash

git_root=$(git rev-parse --show-toplevel)

summary_status=""

pushd "$git_root"
echo "== NORM"
norminette
norminette_status=$?
summary_status="${summary_status}.${norminette_status}"

echo "== CC"
cc -Wall -Wextra -Werror -c */*.c
cc_status=$?
summary_status="${summary_status}.${cc_status}"

echo "== Files in repo"
git ls-files
echo $?

echo "== Git uncommited"
git status --short --untracked-files=no
uncommited_status=$(git status --short --untracked-files=no | wc -l | tr -d ' ')
summary_status="${summary_status}.${uncommited_status}"

echo "== Filename to function name"
not_found=0
for fname in $(find . -name 'ft_*.c'); do
	func_name=$(basename -s .c $fname);
	# grep "^/.*$func_name" "$fname"	# Check for fname in header
	egrep -H "^(char|int|void)\s+\*?$func_name\(" $fname # Check for the function declaration
	not_found=$((not_found + $?))
done
summary_status="${summary_status}.${not_found}"

summary_status="${summary_status}."
summary_status_filtered=$(echo "$summary_status" | tr -d '.0')
RED='\033[0;91m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
echo "Checks summary code: ${summary_status}"
if [ "$summary_status_filtered" != "" ];
then
	echo -e "$RED## SOME STEPS CAN BE IMPROVED."
	echo -e "Do you mind to take a deeper look there?$NC"
else
	echo -e "$GREEN## I THINK ALL GOOD HERE AT $git_root."
	echo -e "Good luck with evaluations!$NC"
fi
popd
