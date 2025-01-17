[_Home_](index.md) > Mappings

# Mappings of EAD to RiC-O and EAC to RiC-O


## EAD to RiC-O

A documentation of how the ricoconverter maps EAD 2002 files to RiC-O v1.0.2 can be read in the Excel file [EAD_to_RiC-O_1.0.2_documentation.xlsx](../EAD_to_RiC-O_1.0.2_documentation.xlsx). This mapping table is useful to transition from EAD to RiC-O, but this is not a formal specification and does not document all precise cases. Previous mappings to RiC-0 0.2 remain available in the [previous mappings table](../previous-mappings-RiC-O-0.2/EAD_to_RiC-O_0.2_documentation.xlsx).

The precise and formal specifications are given in the form of unit tests in the [Unit Tests](UnitTests.md), under `unit-tests/ead2rico`.

The following is a list of EAD 2002 elements that RiC-O Converter does not process, because this was considered irrelevant in the RDF world:

- `frontmatter`;
- `runner`;
- `titlepage`.

The following is a list of EAD 2002 elements that RiC-O converter does not process for now, because the Archives nationales de France (ANF) do not use them in their finding aids, or use them very rarely:

- `abbr` and `expan`;
- `abstract`;
- `address` (in `publicationstmt`);
- `bioghist` (the ANF most often use EAC-CPF files for encoding the biography and history of the agents that created or accumulated the archival fonds);
- `blockquote`;
- `chronlist`;
- `dao`;
- `fileplan`;
- `listhead`;
- `materialspec`;
- `name`;
- `phystech`;
- `prefercite`;
- `sponsor` (in `titlestmt`);
- `table` (and its subelements);
- `title`.

## EAC to RiC-O

A documentation of how the ricoconverter maps EAC-CPF files to RiC-O v1.0.2 can be read in the Excel file [EAC_to_Ric-O_1.0.2_documentation.xlsx](../EAC_to_RiC-O_1.0.2_documentation.xlsx). This mapping table is useful to transition from EAC to RiC-O, but this is not a formal specification and does not document all precise cases. Previous mappings to RiC-0 0.2 remain available in the [previous mappings table](../previous-mappings-RiC-O-0.2/EAC_to_RiC-O_0.2_documentation.xlsx).

The precise and formal specifications are given in the form of unit tests in the [Unit Tests](UnitTests.md), under `unit-tests/eac2rico`.

The ANF use almost all the EAC-CPF elements. However a few elements are not mapped to RiC-O, and not processed by the current version of RiC-O Converter. Let us quote the following ones, that the ANF do not use for now:

- the subelements of [nameEntry](https://eac.staatsbibliothek-berlin.de/schema/taglibrary/cpfTagLibrary2019_EN.html#elem-nameEntry) (except part and useDates);
- [nameEntryParallel](https://eac.staatsbibliothek-berlin.de/schema/taglibrary/cpfTagLibrary2019_EN.html#elem-nameEntryParallel);
- [languageUsed](https://eac.staatsbibliothek-berlin.de/schema/taglibrary/cpfTagLibrary2019_EN.html#elem-languageUsed);
- [localDescription](https://eac.staatsbibliothek-berlin.de/schema/taglibrary/cpfTagLibrary2019_EN.html#elem-localDescription);
- [abstract](https://eac.staatsbibliothek-berlin.de/schema/taglibrary/cpfTagLibrary2019_EN.html#elem-abstract) and [chronList](https://eac.staatsbibliothek-berlin.de/schema/taglibrary/cpfTagLibrary2019_EN.html#elem-chronList) (subelements of biogHist);
- [address](https://eac.staatsbibliothek-berlin.de/schema/taglibrary/cpfTagLibrary2019_EN.html#elem-address) (subelement of place);
- [objectBinWrap](https://eac.staatsbibliothek-berlin.de/schema/taglibrary/cpfTagLibrary2019_EN.html#elem-objectBinWrap),  [objectXMLWrap](https://eac.staatsbibliothek-berlin.de/schema/taglibrary/cpfTagLibrary2019_EN.html#elem-objectXMLWrap);
- [functionRelation](https://eac.staatsbibliothek-berlin.de/schema/taglibrary/cpfTagLibrary2019_EN.html#elem-functionRelation).

## Examples

Input (XML) example files can be found under `input-ead` ([here](https://github.com/ArchivesNationalesFR/rico-converter/tree/master/ricoconverter/ricoconverter-release/src/main/resources/input-ead) in the source) and `input-eac` ([here](https://github.com/ArchivesNationalesFR/rico-converter/tree/master/ricoconverter/ricoconverter-release/src/main/resources/input-eac) in the source).

