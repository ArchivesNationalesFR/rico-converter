[_Home_](index.html) > Customize the conversion

# Customize the conversion

Both the EAC  and EAD conversion can be customized by adjusting the provided XSLT files.

### Customize EAC/CPF conversion

The EAC to RiC-O conversion is driven by the XSLTs in the folder `xslt_eac`. To customize the EAC/CPF conversion, edit in this folder :

1. The main XSLT file under `eac2rico.xslt`;
2. Adjust the URI policy in `eac2rico-uris.xslt` to customize how URIs are generated;
3. Optionnally, if you need to adjust something in the relations processing, you may need to adjust `eac2rico-relations.xslt` and `eac2rico-keywords.xml`;

`ead2rico-arrange.xslt` and `ead2rico-deduplicate.xslt` are use to group entities of the same type in the same file and are applied after the conversion itself. You should not have to modify these files, unless you need a different grouping of entities. You can always skip the grouping and deduplication by using the `convert_eac_raw` command.

### Customize EAD conversion

The EAC to RiC-O conversion is driven by the XSLTs in the folder `xslt_ead`. To customize the EAD conversion, edit in this folder :

1. The main XSLT file under `ead2rico.xslt`;
2. Adjust the URI policy in `ead2rico-uris.xslt` to customize how URIs are generated;