#!/bin/bash

COUNT=0

BLUE="\e[34m"
YELLOW="\e[33m"
GREEN="\e[32m"
MAGENTA="\e[35m"
ENDCOLOR="\e[0m"
CYAN="\e[36m"

barman list-backup all | egrep FAILED | awk 'BEGIN {OFS=" "; ORS="\n"} {print $1, $2}' | while read -r line
do
  array=($line)
  let COUNT=COUNT+1
  failedbackup="${array[0]} ${array[1]}"
  echo -e "${BLUE}$failedbackup${ENDCOLOR} ${GREEN}is failed or corrupt!${ENDCOLOR}"
  barman delete $failedbackup
  echo -e "${BLUE}$failedbackup${ENDCOLOR} ${MAGENTA}has been${ENDCOLOR} ${CYAN}clobberized!${ENDCOLOR}"
  echo -e "${YELLOW}$COUNT${ENDCOLOR} ${GREEN}failed backups deleted!${ENDCOLOR}"
done

