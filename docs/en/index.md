_Home_

# RiC-O Converter

Welcome to the **RiC-O converter documentation** ! RiC-O converter is a command-line tool to convert EAD and EAC files to RDF files expressed using [Records in Contexts ontology](https://www.ica.org/standards/RiC/ontology).

The tool can be downloaded from the [release section](https://github.com/ArchivesNationalesFR/rico-converter/releases) of the [Github repository of the converter](https://github.com/ArchivesNationalesFR/rico-converter/).

## Table of Contents

The documentation is divided in these sections :


### About RiC-CM, RiC-O

- [RiC-CM and RiC-O](RecordsInContexts.md): start here to learn more about Records in Contexts - Conceptual Model and Ontology ;
- [About the RiC-O converter project](About.md): get an understanding of the RiC-O converter project;
- [Mappings](Mappings.md): learn how EAD and EAC files are mapped to Records in Contexts Ontology by this conversion tool.

### Technical documentation of RiC-O converter

- [Getting Started](GettingStarted.md): start here to test drive the converter, understand the directory structure, learn how to print help message and adjust the command parameters;
- [Conversion](Conversion.md): main documentation for the EAD and EAC conversion process;
- [Running unit tests](UnitTests.md): explains how to run the unit tests of the converter;
- [Customize the conversion](Customize.md): explains how to customize the conversion for your own files;
- [Common Problems](CommonProblems.md): give answers to common problems;
- [Compile ricoconverter](Compile.md): if you need to adjust something in the Java code and recompile, read this.


### Reference lists of error codes

- [Error Codes](ErrorCodes.md): reference list of the error codes of the application;
- [EAC XSLT Error Codes](ErrorCodesXsltEac.md): reference list of the possible error codes during EAC conversion;
- [EAD XSLT Error Codes](ErrorCodesXsltEad.md): reference list of the possible error codes during EAD conversion.


## Licence

This project is licensed under the terms of the CeCILL-B license (equivalent to MIT license and close to a public domain license) (see the [license file in english](license.txt) or [in french](../fr/licence.txt)).


## Contact

If you have questions on RiC-O converter, you can contact :

- [Florence Clavaud](mailto:florence.clavaud@culture.gouv.fr), head of the Lab at the [Archives nationales de France](http://www.archives-nationales.culture.gouv.fr/), who also leads the development of RiC-O ontology;
- [Thomas Francart](mailto:thomas.francart@sparna.fr) at [Sparna](http://sparna.fr), developer of RiC-O converter ([blog](http://blog.sparna.fr)).
