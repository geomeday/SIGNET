#!/bin/bash

file_purge(){
file=$1
forcerm=$2

qyn=0

if [[ $forcerm == T* || $forcerm == t* || $forcerm == Y* || $forcerm == y* ]]; then
echo -e "Please note that the temporary file was force removed"
qyn=1
rm -rf $file
fi

while [[ qyn -eq 0 ]]; do

qyn=1

if [[ -d $file ]]; then
read -p "$file alreay exists, you could back them up or overwriting them. Overwriting them? Enter Y to overwrite, N to exit. [Y/N]: "  yn

case $yn in
Y|Yes|y|yes ) rm -rf $file;;
N|No|n|no ) exit -1;;
* ) qyn=0
    echo -n "Please choose between Y or N: "
    read yn;;
esac
fi

done

mkdir $file

echo -e "\n"
}

# Input a directory with prefix, check whether it exists

dir_check(){
##Check if the directory exists

if [[ "$1" == *\/* ]];then DIR=${1%/*};else DIR=$(pwd); fi

##Handle the case when it's empty
if [[ -z $DIR ]]; then DIR=$(pwd); fi

FILE=${1#$DIR/}

if [[ ! -d $DIR ]]; then
echo "The directory $DIR doesn't exist, note that prefix applies"
exit -1
else
FDIR=$(readlink -f $DIR)
echo ${FDIR}/${FILE}
fi

}

# Input a file name, check whether it exists

file_check(){

## Check if the file exists or empty

if [[ ! -f $1 ]]; then 
echo "The file $1 doesn't exist"
exit -1 
elif [[ -z $1 ]]; then 
echo "The file $1 exists but empty"
exit -1 
fi

}

# First value, followed by LB, UB, output name

numeric_check(){

## Check range

if [[ $1 -lt $2 || $1 -gt $3 ]]; then
echo "Value $4 out of Bound"
exit -1 
fi 

}

# input: email, job name, status
email_note(){
email=$1
job_name=$2
status=$3

if [[ $email != "*@*" ]]
then
  if [[ $(which mail) != "" ]]
  then
  echo -e "Your $job_name using SIGNET is $status " | mail -s "SIGNET NOTIFICATION" $email 
  fi
fi
}

# To show the interactive progress bar
# input: walltime, number of checks, bar_length, prefix for search, total number of files, prefix of slurm jobs

progress_bar(){
time=$1
ncheck=$2
bar_len=$3
prefix=$4
N=$5
slurm=${6:slurm}

time_lap=$(($1/$2))

N_record=0

while true
do

N_finished=$(cat $prefix[0-9]*.completed | wc  -l | tail -1)

if [[ $N_finished -gt $N_record ]]; then
for i in $(seq 1 $(($N_finished * $bar_len / $N)))
do
printf "#"
done
printf "  [$(($N_finished * 100 / $N)) %%]\r"
fi

N_record=$N_finished

if [[ $N_finished -ge $N ]]; then
break
fi

if [[ $(ls $slurm*.out 2>/dev/null | wc -l) -gt 0 && $(cat $slurm*.out |grep CANCEL|head -1) != "" ]];then
break
fi

sleep $time_lap

done

}

export -f file_purge dir_check file_check numeric_check email_note progress_bar
