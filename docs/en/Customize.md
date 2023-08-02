[_Home_](index.md) > Customize the conversion

# Customize the conversion

Both the EAC and EAD conversion can be customized by passing some parameters and overriding the "driver" xslt `main.xslt`.

## Customize EAC/CPF conversion

### Adjust general parameters

You can adjust runtime parameters in `parameters/convert_eac.properties` to adjust e.g. input or output folders.

### Adjust XSLT parameters

The EAC to RiC-O conversion is driven by the XSLTs in the folder `xslt_eac`. A first step to adapt the conversion is to modify the XSLT parameters declared in `main.xslt`, such as the language code for generated literals, or the record author URI.

### Adjust conversion logic

The complete conversion logic is in `eac2rico.xslt`. To further customize the EAC/CPF conversion logic, you can override the templates of this XSLT by redeclaring them in `main.xslt` with a different behavior. Templates you write inside `main.xslt` have precedence over the templates from `eac2rico.xslt` with the same `match` attribute, allowing you to adapt some behavior more easily; in addition, if you need to adjust something in the relations processing, you may need to adjust `eac2rico-relations.xslt` and `eac2rico-keywords.xml`.

When you adjust something in the XSLT conversion logic, add new unit tests under `unit-tests/eac2rico`, or adjust existing unit tests, and [run the unit tests command](UnitTests.md) to validate your modification and check nothing is broken.

`ead2rico-arrange.xslt` and `ead2rico-deduplicate.xslt` are used to group entities of the same type in the same file and are applied after the conversion itself. You should not have to modify these files, unless you need a different grouping of entities. You can always skip the grouping and deduplication by using the `convert_eac_raw` command.



## Customize EAD conversion

### Adjust general parameters

You can adjust runtime parameters in `parameters/convert_ead.properties` to adjust e.g. input or output folders.

### Adjust XSLT parameters

The EAD to RiC-O conversion is driven by the XSLTs in the folder `xslt_ead`. A first step to adapt the conversion is to modify the XSLT parameters declared in `main.xslt`, such as the language code for generated literals, or the patterns to detect RecordSet or RecordParts in @otherlevel attributes.

### Adjust conversion logic

The complete conversion logic is in `ead2rico.xslt`. To further customize the EAD conversion logic, you can override the templates of this XSLT by redeclaring them in `main.xslt` with a different behavior. Templates you write inside `main.xslt` have precedence over the templates from `ead2rico.xslt` with the same `match` attribute, allowing you to adapt some behavior more easily.

When you adjust something in the XSLT, add new unit tests under `unit-tests/ead2rico`, or adjust existing unit tests, and [run the unit tests command](UnitTests.md) to validate your modification and check nothing is broken.
