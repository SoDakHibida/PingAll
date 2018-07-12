#!/bin/bash
# Program name: pingall.sh
# Author: SoDakHib
# Date: 07/11/2018
#
#------------------------------------------------------------------------------------------
#       __________.__                  _____  .__  .__   
#       \______   \__| ____    ____   /  _  \ |  | |  |  
#        |     ___/  |/    \  / ___\ /  /_\  \|  | |  |  
#        |    |   |  |   |  \/ /_/  >    |    \  |_|  |__
#        |____|   |__|___|  /\___  /\____|__  /____/____/
#                        \//_____/         \/SoDakHib 
#------------------------------------------------------------------------------------------
#
# Usage:
#	populate inputs file (hosts separated by commas):
#		X.X.X.X, X.X.X.X,
#		X.X.X.X-X, X.X.X.X,
#		X.X.X.X
#
# 	to run:
#		./pingall.sh
#
#	additional flags:
#		-f <file> (file input) ~ provide your own input txt file
#		-c (clean) ~ removes targets.txt and results.txt 
#
# targets separated by line in targets.txt
# results stored in results.txt
#
#------------------------------------------------------------------------------------------
#
#

# input file:
in="input.txt"

# temp middle file
temp="temp.txt"

# targets file (one per line)
db="targets.txt"

# output location:
o="results.txt"

# save original IFS (Internal Field Separator)
OLDIFS=$IFS

# set IFS to comma (Nessus format)
IFS=','

# reading provided flag (-c or -f)
while getopts "cf:" OPTION
do
	case $OPTION in
		c)
		# Clean
			echo "--- Removed Files ---"
			echo "targets.txt  results.txt"
			rm targets.txt
			rm results.txt
			echo "--- Updated Directory ---"
			ls
			exit
			;;
		f)
		# File Input
			in=$OPTARG
			echo "input file: $OPTARG"
			;;
		\?)
		# Illegal Flag
			echo "Either run without a flag, or try:"
			echo "-f <input text file>"
			echo "-c (to clean your directory of PingAll files)"
			exit
			;;
	esac
done

# if file exists
if [ -f $in ]; then
	echo "input file found"
	
	tr -d '[:space:]' < $in > $temp

	# replaces commas with newlines
	tr , '\n' < $temp > $db

	rm temp.txt

	echo "targets file updated"
	echo "--- Commencing Pinging ---"

	# read it
	while read -r host || [[ -n $host ]]; do
		echo "Pinging Host(s) $host:" >> $o
		nmap -sn -PE -PP $host >> $o
	       	echo  >> $o	
	done < "$db"
else
	echo "no input file found"
fi

# revert to original IFS
IFS=$OLDIFS

# End
echo "--------------------- PingAll Complete! -----------------------"
echo
# print results
cat $o
echo "---------------------- PingAll Goodbye! -----------------------"
