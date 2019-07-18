[_Home_](index.html) > Getting Started

# Getting Started

## Test drive the converter

To run your first conversion :

1. double-click on `eaccpf2rico.bat` (or `eaccpf2rico.sh` on Linux or Mac - make sure it is executable),
2. hit `Enter` to leave the default values for the input parameters of the script;
3. wait a couple of seconds for the conversion to finish, and look in the generated output folder `output-<date_of_day>` for the result of the conversion;

The few sample files provided by default in the `input` folder have been converted to RiC-O.


## Display the Help message

To print the help message and get the details of all the possible commands and options, run  `eaccpf2rico.bat` and type "help" at the prompt for the command :

```
:: Welcome to EAC-CPF 2 Ric-O Converter 20190604 ::

Enter command to execute (convert_arrange, convert, validate, test, version, help) [press enter for 'convert_arrange'] :help
```

## Script folder content

In the script folder you will find the following directories :

  - `documentation` : contains this documentation :-)
  - `input`, `input-50`, `input-500`, `input-5000` and `input-all` : contains samples EAC files to be converted with the `convert_arrange` and `convert` commands;
  - `input-validation` : the default input folder for validating data using the `validate` command;
  - `parameters` : contains the parameter files for each command; you need to modify these files if you want to adjust the options of a command;
  - `shapes` : contains the shapes definition file used by the `validate` command;
  - `unit-tests` : contains the unit test files used by the `test` command;
  - `vocabularies`
  - `xslt` : contains the XSLT files used by the `convert_arrange` and `convert` commands to convert EAC to RiC-O; the main one is `eac2rico.xslt`;

## Commands and parameters

The converter contains a few commands, the major ones are `convert_arrange`, `convert`,  and `validate`.

Each command is associated to a set of parameters, and these parameters are listed in a property file under the `parameters` subfolder, in a file with the same name as the command; e.g. the options for the command `convert_arrange` are in `parameters/convert_arrange.properties`.

These parameters are documented in the property file itself, and in the Help message.

Note that you can make a copy of a parameter file under a different name to save specific options for a given command that you need to run multiple times.

## Adjust the input and output folders (and other folders)

Probably the parameters you may want to adjust the more frequently and the input and output folders of the conversion; by default, the conversion script works with the following folders :

  - it reads the files to be converted in the `input` folder;
  - it outputs the result of the conversion in a folder named `output-<date_of_day>`, e.g. `output-20190718`;
  - it outputs files in error in a folder named `error-<date_of_day>`, e.g. `error-20190718`;
  - it generates log files in the folder `log`;
  - it generates temporary files in the folder `work`;

To adjust the input folder of the conversion :

  1. Edit the file `parameters/convert_arrange.properties`;
  2. Find the property `input`;
  3. Uncomment the line by removing the `#` character at the bebinning of the line;
  4. Set the input parameter to the desired value, e.g. `input=myOtherInputFolder`;