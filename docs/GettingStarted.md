[_Home_](index.html) > Getting Started

# Getting Started

## Test drive the converter

To run your first conversion :

1. double-click on `ricoconverter.bat` (or `ricoconverter.sh` on Linux or Mac - make sure it is executable),
2. hit `Enter` to run a default EAC to RiC-O conversion that will convert the content of a few EAC test files contained in the `input-eac` directory.
3. hit `Enter` again to leave the default values for the parameters of the script;
4. wait a couple of seconds for the conversion to finish, and look in the generated output folder `output-eac-<date_of_day>` for the result of the conversion;

The few EAC sample files provided by default in the `input-eac` folder have been converted to RiC-O.


## Display the Help message

To print the help message and get the details of all the possible commands and options, run  `ricoconverter.bat` and type "help" at the prompt for the command :


	> :: Welcome to Ric-O Converter ::
	>
	> Enter command to execute (convert_eac, convert_eac_raw, convert_ead, test_eac, test_ead, version, help)
	> [press Enter for 'convert_eac'] :help


## Converter release folder content

In the converter release folder you will find the following directories :

  - `documentation` : contains this documentation :-)
  - `input-eac` : the default folder that contains the EAC files to be converted with the `convert_eac` (or `convert_eac_raw`) command;
  - `input_ead` : the default folder that contains the EAD files to be converted with the `convert_ead` command;
  - `parameters` : contains the parameter files for each command; you need to modify these files if you want to adjust the options of a command;
  - `unit-tests` : contains the unit test files used by the `test_eac` and `test_ead` commands;
  - `vocabularies` : contains a few controlled vocabularies needed by the conversion process : languages, rules and legal statuses;
  - `xslt_eac` : contains the XSLT files used by the `convert_eac` and `convert_eac_raw` commands to convert EAC to RiC-O; the main one is `eac2rico.xslt`;
  - `xslt_ead` : contains the XSLT files used by the `convert_ead` command to convert EAC to RiC-O; the main one is `ead2rico.xslt`;

## Commands and parameters

The converter contains a few commands, the main ones are `convert_eac` and  `convert_ead` to convert, as their name suggest, EAC and EAD files to RiC-O.

Each command is associated to a set of parameters, and these parameters are listed inside the `parameters` subfolder, in a file with the same name as the command; e.g. the options for the command `convert_eac` are in `parameters/convert_eac.properties`.

These parameters are documented in the property file itself, and in the Help message. Open a parameter file in a text editor to read the documentation of each parameter.

Note that you can make a copy of a parameter file under a different name to save specific options for a given command that you need to run multiple times.

## Adjust the input and output folders (and other folders)

Probably the parameters you may want to adjust the more frequently are the input and output folders of the conversion commands; by default, the conversion commands works with the following folders :

  - EAD conversion (command `convert_ead`) reads the files to be converted from the `input-ead` folder and outputs the result of the conversion in a folder named `output-ead-<date_of_day>`, e.g. `output-ead-20190718`;
  - EAC conversion (command `convert_eac`) reads the files to be converted from the `input-eac` folder and outputs the result of the conversion in a folder named `output-eac-<date_of_day>`, e.g. `output-eac-20190718`;
  - both of these command outputs files in error in a folder named `error-<date_of_day>`, e.g. `error-20190718`;
  - both of the commands generate log files in the folder `log`;
  - both of the commands might create files in the folder `work`;

To adjust the input folder of the conversion :

  1. Edit the file `parameters/convert_eac.properties` or `parameters/convert_ead.properties`, depending on the command you are interested in;
  2. Find the property `input`;
  3. Uncomment the line by removing the `#` character at the beginning of the line;
  4. Set the input parameter to the desired value, e.g. `input=myOtherInputFolder`;
