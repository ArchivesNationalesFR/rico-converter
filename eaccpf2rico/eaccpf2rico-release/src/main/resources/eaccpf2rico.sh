#!/bin/bash

echo ":: Welcome to EAC-CPF 2 Ric-O Converter 20190604 ::"

export command_default=convert_arrange
read -p "Enter command to execute (convert_arrange, convert, test, version) [press enter for '$command_default'] :" command
command=${command:-$command_default}

export parameterFile_default=parameters/$command.properties
read -p "Enter parameter file location [press enter for '$parameterFile_default']:" parameterFile
parameterFile=${parameterFile:-$parameterFile_default}

export fullCommandLine="java -Xmx1200M -Xms1200M -jar eaccpf2rico-cli-20190604-onejar.jar $command @$parameterFile"
echo $fullCommandLine
$fullCommandLine
read -p "Appuyer sur Entrée pour continuer ..."