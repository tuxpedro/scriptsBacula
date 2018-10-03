#!/bin/bash
:<< --Abount--

	This script cancel jobs not executed 
	@Author: Pedro
	@Date: 2018-06-02

--Abount--
rm -rf /tmp/jobsNotRunning.txt
rm -rf /tmp/resultsed.txt
 
# Conecte in the console of bacula get status 
bconsole -c ./bconsole.conf <<END_OF_DATA
@output /dev/null
messages
@output /tmp/jobsNotRunning.txt
status dir
@quit
END_OF_DATA

# Read file log of status get number position of the lines of the words Running and Terminated
lin1=$(grep -n Running /tmp/jobsNotRunning.txt)
lin2=$(grep -n Terminated /tmp/jobsNotRunning.txt)

# Clears the unwanted character variable
numLin1="${lin1%:*:}"
numLin2="${lin2%:*:}"

# corrects the position of line delimiters
cNumLin1="$(($numLin1 + 4))"
cNumLin2="$(($numLin2 - 3))"

# picks lines that are between the delimiters and storange in other file
sed -n "${cNumLin1},${cNumLin2}p" /tmp/jobsNotRunning.txt > /tmp/resultsed.txt
# count line of file resultsed.txt
qtdJobs=$(grep -c ".*" /tmp/resultsed.txt)

#removes spaces and unwanted characters from the file and stores it in a variable
jobsId=$(sed 's/^\s*//g; s/[^0-9]\{2\}\(.*\)//g' /tmp/resultsed.txt)

# convert variable jobsId for array
arrJobsId=($jobsId)

#runs the array connects to the bacula console and cancels jobs
for ((i=0; i<${#arrJobsId[@]}; i++))
do
bconsole -c ./bconsole.conf <<END_OF_DATA
@output /dev/null
cancel jobid=${arrJobsId[$i]}
@output /dev/null
@quit
END_OF_DATA
done

# Create file log end
echo "${qtdJobs} jobs foram cancelados. $(date)" >> /tmp/logend.txt
