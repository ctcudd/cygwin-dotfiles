#!/bin/bash

export https_proxy="";
export http_proxy="";
credentials="usruoc:GaiaD099";
base_path="https://svn.sec.tds.net/na/";

if [ "$1" == "" ]
then
   app_list=`svn ls $base_path`;
   app_list=`echo $app_list | tr '\r' ' '`;
else
   app_list="$1"; 
fi;

if [ "$2" == "" ]
then
    env_list="goldfinger moonraker sandbox skyfall thunderball prod";    
else
    env_list="$2";
fi;

if [ "$3" == "datasource-url" ]
then
    context="datasources/";
    file_context=".*\-ds.xml";
    line_context="URL\|jndi-name";
elif [ "$3" == "jndi-name" ]
then
    context="datasources/";
    file_context=".*\-ds.xml";
    line_context="jndi-name";
elif [ "$3" == "jms" ]
then
    context="properties/";
    file_context=".*\-app.properties";
    line_context="queue\.name\|topic\.name";
else   
    context="properties/";
    file_context=".*\-app.properties";
    line_context="endpoint=";
fi;
base_path="$base_path$context";

for app in $app_list; do
    for env in $env_list; do
	app_dir="$base_path$app$env/trunk/";
	echo "app_dir=$app_dir";
	app_files=`svn ls $app_dir 2>/dev/null`;
	if [ "$app_files" != "" ]
	then
	    echo "app_files=$app_files";
	    app_file=`echo $app_files | tr '\r' '\n' | grep $file_context | tr -d '[[:space:]]'`;
	    app_file_path="$app_dir$app_file";
	    if [ "$app_file_path" != "" ]
	    then
		echo "app_file_path=$app_file_path";
		lines=`curl -s -k -u $credentials $app_file_path | grep $line_context`;
		for line in $lines;do
		    echo "line for $app $env: $line";
		done;
	    else
		echo "$file_context not found for $app $env";
	    fi;
	else
	    echo "no files for $app $env";
	fi;
    done;
done;
