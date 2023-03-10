[_Home_](index.html) > Mappings

# Mappings of EAD to RiC-O and EAC to RiC-O


## EAD to RiC-O

An entry point and informal documentation of how the ricoconverter maps EAD 2002 files to RiC-O v0.1 can be read in the Excel file [EAD to Ric-O 0.1 documentation.xlsx](EAD_to_Ric-O_0.1_documentation.xlsx).

The precise and formal specifications are given in the [Unit Tests](UnitTests.html), under `unit-tests/ead2rico`.

The following is a list of EAD 2002 elements that RiC-O Converter does not process, because this was considered irrelevant in the RDF world:

- frontmatter;
- runner;
- titlepage.

The following is a list of EAD 2002 elements that RiC-O converter does not process for now, because the Archives nationales de France (ANF) do not use them in their finding aids, or use them very rarely:

- abbr and expan;
- abstract;
- bioghist (the ANF most often use EAC-CPF files for encoding the biography and history of the agents that created or accumulated the archival fonds);
- blockquote;
- chronlist;
- dao;
- fileplan;
- listhead;
- materialspec;
- phystech;
- prefercite;
- table.


## EAC to RiC-O

An entry point and informal documentation of how the ricoconverter maps EAC-CPF files to RiC-O v0.1 can be read in the Excel file [EAC to Ric-O 0.1 documentation.xlsx](EAC_to_Ric-O_0.1_documentation.xlsx).

The precise and formal specifications are given in the [Unit Tests](UnitTests.html), under `unit-tests/eac2rico`.

The ANF use almost all the EAC-CPF elements. However a few elements are not mapped to RiC-O, and not processed by the current version of RiC-O Converter. Let us quote the following ones, that the ANF do not use for now:

- the subelements of [nameEntry](https://eac.staatsbibliothek-berlin.de/schema/taglibrary/cpfTagLibrary2019_EN.html#elem-nameEntry) (except part and useDates);
- [abstract](https://eac.staatsbibliothek-berlin.de/schema/taglibrary/cpfTagLibrary2019_EN.html#elem-abstract) and [chronList](https://eac.staatsbibliothek-berlin.de/schema/taglibrary/cpfTagLibrary2019_EN.html#elem-chronList) (subelements of biogHist);
- [address](https://eac.staatsbibliothek-berlin.de/schema/taglibrary/cpfTagLibrary2019_EN.html#elem-address) (subelement of place);
- [objectBinWrap](https://eac.staatsbibliothek-berlin.de/schema/taglibrary/cpfTagLibrary2019_EN.html#elem-objectBinWrap),  [objectXMLWrap](https://eac.staatsbibliothek-berlin.de/schema/taglibrary/cpfTagLibrary2019_EN.html#elem-objectXMLWrap);
- [functionRelation](https://eac.staatsbibliothek-berlin.de/schema/taglibrary/cpfTagLibrary2019_EN.html#elem-functionRelation).

## Examples

Input (XML) example files can be found under `input-ead` and `input-eac`.

