#!/bin/bash
# Program name: pingall.sh
# Author: SoDakHib
# Last-Updated: 07/17/2018
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
#		X.X.X.X-X, X.X.X.X/X,
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
# pingable hosts (results) stored in able.txt
#
#------------------------------------------------------------------------------------------
#
#

# input file:
in="input.txt"

# temp middle file
temp="temp.txt"
temp2="temp2.txt"

# targets file (one per line)
db="targets.txt"

# output location:
o="results.txt"

# pingable hosts (results)
able="able.txt"
	
# string for compare
up="1 host up" 

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
			rm able.txt
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
	tr , '\n' < $temp > $temp2

	rm temp.txt

	# prettify (/)slash and (-)dash notations
	while IFS='' read -r line || [[ -n "$line" ]]; do 
		echo "Organizing target(s): $line"
		nmap -sL $line | grep "Nmap scan report" | awk '{print $NF}' >> $temp		
	done < "$temp2"

	cat $temp | tr -d ')(' > $db

	# clean up
	rm temp2.txt
	rm temp.txt

	echo "targets file updated"
	echo "--- Commencing Pinging ---"

	# read it
	while read -r host || [[ -n $host ]]; do
		echo "Ping Results for $host:" >> $o
		echo "Pinging Host $host" 
		nmap -sn -PE $host | sed '/Starting/d' | sed '/Note/d' > $temp
	        cat $temp >> $o	
	       	echo >> $o

		if grep -q $up "$temp"; then
			cat $temp >> $able
			echo >> $able	
		fi

	done < "$db"
else
	echo "no input file found"
fi

# more clean up
rm temp.txt

# revert to original IFS
IFS=$OLDIFS

# End
echo "--------------------- PingAll Complete! -----------------------"
echo
# print results
cat $o
echo "---------------------- PingAll Goodbye! -----------------------"
