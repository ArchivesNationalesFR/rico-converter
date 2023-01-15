[_Home_](index.html) > Customize the conversion

# Customize the conversion

Both the EAC  and EAD conversion can be customized by adjusting the provided XSLT files.

## Customize EAC/CPF conversion

### Adjust base URI and URI generation

Adjust the input parameter `xslt.BASE_URI` (in `parameters/convert_eac.properties`) to customise the root URI of all identifiers.

Adjust the URI policy in `xslt_eac/eac2rico-uris.xslt` to customize how URIs are generated.

### Adjust conversion logic

The EAC to RiC-O conversion is driven by the XSLTs in the folder `xslt_eac`. To customize the EAC/CPF conversion, edit in this folder the main XSLT file under `main.xslt`; this XSLT does nothing by itself and allows you to overwrite the behavior of `eac2rico.xslt`; in addition, if you need to adjust something in the relations processing, you may need to adjust `eac2rico-relations.xslt` and `eac2rico-keywords.xml`.

When you adjust something in the XSLT, add new unit tests under `unit-tests/eac2rico`, or adjust existing unit tests, and [run the unit tests command](UnitTests.html) to validate your modification and check nothing is broken.

`ead2rico-arrange.xslt` and `ead2rico-deduplicate.xslt` are used to group entities of the same type in the same file and are applied after the conversion itself. You should not have to modify these files, unless you need a different grouping of entities. You can always skip the grouping and deduplication by using the `convert_eac_raw` command.



## Customize EAD conversion

### Adjust base URI and URI generation

Adjust the input parameter `xslt.BASE_URI` (in `parameters/convert_ead.properties`) to customise the root URI of all identifiers.

Adjust the URI policy in `xslt_ead/ead2rico-uris.xslt` to customize how URIs are generated.

### Adjust conversion logic

The EAC to RiC-O conversion is driven by the XSLTs in the folder `xslt_ead`. To customize the EAD conversion, edit in this folder the main XSLT file under `main.xslt`. This XSLT does nothing by itself and allows you to overwrite the behavior of `ead2rico.xslt`

When you adjust something in the XSLT, add new unit tests under `unit-tests/ead2rico`, or adjust existing unit tests, and [run the unit tests command](UnitTests.html) to validate your modification and check nothing is broken.
