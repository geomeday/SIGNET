#!/bin/bash

cmdprefix="$SIGNET_ROOT/signet -s --"
loc=$(${cmdprefix}cis.loc | sed -r '/^\s*$/d'|xargs readlink -f);
cor=$(${cmdprefix}cor);
nboots=$(${cmdprefix}nboots);
ncores=$(${cmdprefix}ncores);
queue=$(${cmdprefix}queue);
memory=$(${cmdprefix}memory);
walltime=$(${cmdprefix}walltime)
cwd=$(pwd)
tmpn=$($SIGNET_ROOT/signet -s --tmpn)
resn=$($SIGNET_ROOT/signet -s --resn)

ARGS=`getopt -a -o r: -l loc:,l:,ncis:,r:,cor:,memory:,m:,queue:,q:,walltime:,:w:,nboots:,tmpn:,resn:,h:,help -- "$@"`

function usage() {
	echo 'Usage:'
	echo '  signet -s [OPTION VAL] ...'
	echo -e "\n"
	echo 'Description:'
	echo '  --loc CIS.LOC                 location of the result after the cis-eQTL analysis'
	echo '  --cor MAX_COR 		maximum corr. coeff. b/w cis-eQTL of same gene'
        echo '  --ncores N_CORE		number of cores in each node'
	echo '  --memory MEMEORY	        memory in each node in GB'
	echo '  --queue QUEUE                 queue name'
        echo '  --walltime WALLTIME		maximum walltime of the server in seconds'
	echo '  --nboots NBOOTS               number of bootstraps datasets'                   
        echo "  --tmpn                        set the temporary file directory"
        echo "  --resn                        set the result file directory"
	exit -1 
}
[ $? -ne 0 ] && usage

eval set -- "${ARGS}"

while true
do
case "$1" in
	--loc)
                loc=$2
		loc=$(readlink -f $loc)
                ${cmdprefix}cis.loc $loc
                shift
              ;;
	--cor | --r)
		cor=$2
		${cmdprefix}cor $cor
                shift;;
	--nboots)
		nboots=$2
		${cmdprefix}nboots $nboots
                shift;;
	--ncores)
		ncores=$2
		${cmdprefix}ncores $ncores
                shift;;
	--memory | --m)
		memory=$2
                ${cmdprefix}memory $memory
		shift;;
	--queue | --q)
                queue=$2
                ${cmdprefix}queue $queue
                shift;;
        --walltime)
		walltime=$2
		${cmdprefix}walltime $walltime
                shift;;
	--tmpn)
                tmpn=$2
                $SIGNET_ROOT/signet -s --tmpn $tmpn
                shift;;
        --resn)
                resn=$2
                $SIGNET_ROOT/signet -s --resn $resn
                shift;;
	--h|--help)
		usage
		exit
              ;;
      --)
              shift
              break
              ;;
      esac
shift
done 

file_compare $tmpn $resn

## Do a file check
file_check $tmpn $SIGNET_TMP_ROOT/tmpn
file_check $resn $SIGNET_RESULT_ROOT/resn

mkdir -p $SIGNET_TMP_ROOT/tmpn
mkdir -p $SIGNET_RESULT_ROOT/resn
mkdir -p $SIGNET_DATA_ROOT/network

$SIGNET_SCRIPT_ROOT/network/network.sh $nboots $cor $queue $ncores $memory $walltime $loc

cd $SIGNET_TMP_ROOT/tmpn
file_prefix signet
cd $cwd
file_trans $SIGNET_TMP_ROOT/tmpn/signet $tmpn

cd $SIGNET_RESULT_ROOT/resn
file_prefix signet
cd $cwd
file_trans $SIGNET_RESULT_ROOT/resn/signet $resn
