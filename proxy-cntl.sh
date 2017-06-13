#!/bin/bash
# NOTE: This requires GNU getopt.  On Mac OS X and FreeBSD, you have to install this
# separately; see: http://stackoverflow.com/questions/402377/using-getopts-in-bash-shell-script-to-get-long-and-short-command-line-options/7948533#7948533
CNTLM_PORT="3128";
CNTLM_HOST="localhost";

start() {  
    if [ $(status) != "RUNNING" ]
    then
	`cygstart --action=runas net start cntlm; sleep 3;`;
    fi
    echo "$CNTLM_HOST:$CNTLM_PORT";
}

stop() {
    if [ $(status) != "STOPPED" ]
    then
	`cygstart --action=runas net stop cntlm; sleep 3;`
    fi;
    echo "";
}

status(){
    echo `sc query cntlm| grep STATE | cut -d':' -f2 | cut -d' ' -f4`;
}

OPTS=`getopt -o v -l verbose,start,stop,status,dont-source-bashrc -- "$@"`

if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

# Note the quotes around `$TEMP': they are essential!
eval set -- "$OPTS"
VERBOSE=false;
SOURCE_BASHRC=true;
while true; do
    case "$1" in
	--dont-source-bashrc ) SOURCE_BASHRC=false; shift;;
	-v | --verbose ) VERBOSE=true;    shift ;;
	--start )  CNTLM_PROXY=$(start);  shift ;;
	--stop )   CNTLM_PROXY=$(stop);   shift ;;
	--status )  shift ; break;;
	-- ) shift; break ;;
	* ) break ;;
    esac
done
if [ "$VERBOSE" == "true" ]; then echo "proxy-cntl $OPTS"; fi;
CNTLM_STATUS=$(status);
if [ "$CNTLM_PROXY" != "" ]
then
    CNTLM_STATUS="$CNTLM_STATUS on $CNTLM_PROXY";
fi;
echo "CNTLM is $CNTLM_STATUS";
export CNTLM_PROXY="$CNTLM_PROXY";

#if this cmd is being called by bashrc, we don't want to re-source it which would create an infinite loop
if [ "$SOURCE_BASHRC" == "true" ]
then
    if [ "$VERBOSE" == "true" ]; then echo "sourcing bashrc file"; fi;
    . ~/.bashrc;
else
    if [ "$VERBOSE" == "true" ]; then echo "not sourcing bashrc file"; fi;
fi;
