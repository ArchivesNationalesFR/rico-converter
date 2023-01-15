[_Home_](index.html) > Conversion

# Conversion

## EAC to RiC-O conversion

The EAC to RiC-O conversion is driven by a set of XSLT under the `xslt_eac` folder. The conversion steps are as follow :

1. **Main Conversion** :  the main conversion is implemented in `main.xslt` which does nothing by itself and imports `eac2rico.xslt`. It calls in turn the following other files :
	1. `eac2rico-uris.xslt` : defines how URIs are generated;
	1. `eac2rico-relations.xslt` : everything related to the conversion of relations; this in turns relies on `eac2rico-keywords.xml` that defines keywords to be matched in the input files to determine the type of the relation in some cases;
	1. `eac2rico-codes.xml` : defines error codes used for EAC conversion;
	1. `eac2rico-builtins.xslt` : a rewrite and extension of builtins XSLT template for EAC conversion;
2. **Arrange output files** : The main conversion of the first step generates one output file for each input file. This step will group the relations entities into one output file per relation type, and reorganise the hierarchy of the output folder; The final output folder looks like this :
	- `agents` : contains Agents descriptions, without their relations;
	- `places` : contains Places;
	- `relations` : contains relations, in the following files :
		- `agentHierarchicalRelations`
		- `agentOriginationRelations`
		- `agentTemporalRelations`
		- `agentToAgentRelations`
		- `familyRelations`
		- `membershipRelations`
		- `workRelations`

	_Note that, even when no relations of a given type are generated, the corresponding file is still generated, with an empty RDF content._

3. **Deduplicate relations** :  once relations of the same type are grouped in the same file, the XSLT `eac2rico-deduplicate.xslt` is in charge of removing duplicated relations in this file (based on their URI), so that the same relation appears only once;

The entry point `main.xslt` can be used to overwrite certain templates from the conversion with your own logic.

### EAC to RiC-O conversion without grouping and deduplication

It is possible to run only the main EAC to RiC-O conversion (first step) but avoid the grouping of relations and their deduplications. To do this, use the `convert_eac_raw` command.

This can be useful to debug precise output of a given input EAC file.

## EAD to RiC-O conversion

The EAD to RiC-O conversion is driven by a set of XSLT under the `xslt_ead` folder. The conversion steps are as follow :

1. **EAD preprocessing (audience filtering)** : if a filtering on the @audience property is required (it is by default), the XSLT `ead2rico-preprocessing.xslt` is applied on the input file; otherwise, the original file is directly processed;
2. **Main conversion** : the main conversion is implemented in `main.xslt` which does onthing by itself and imports `ead2rico.xslt`. It calls in turn the following other files :
	- `ead2rico-uris.xslt` : defines how URIs are generated;
	- `ead2rico-codes.xml` : defines error codes used for EAD conversion;
	- `ead2rico-builtins.xslt` : a rewrite and extension of builtins XSLT template for EAD conversion;
3. **Splitting of output files** : if required (by default it is not), the result of the conversion is splitted using `ead2rico-split.xslt`. The main Record and the top RecordResource of each file are output in one file, and each "branch" of the finding aid is output in a separate file;

The entry point `main.xslt` can be used to overwrite certain templates from the conversion with your own logic.