#!/bin/bash

echo ":: Welcome to Ric-O Converter ${project.version} ::"

export command_default=convert_eac
read -p "Enter command to execute (convert_eac, convert_eac_raw, convert_ead, test_eac, test_ead, version, help) [press Enter for '$command_default'] :" command
command=${command:-$command_default}

export parameterFile_default=parameters/$command.properties

if [ $command != "help" ]
then
	read -p "Enter parameter file location [press Enter for '$parameterFile_default']:" parameterFile
	parameterFile=${parameterFile:-$parameterFile_default}
fi

parameterFileOption=""
if [ $parameterFile != "" ]
then
	parameterFileOption=@$parameterFile
fi

export fullCommandLine="java -Xmx1200M -Xms1200M -jar ricoconverter-cli-${project.version}-onejar.jar $command @$parameterFileOption"
echo $fullCommandLine
$fullCommandLine
read -p "Appuyer sur Entrée pour continuer ..."