# EAC2RDF Tool For the Archives nationales de France

## Previous XSL library, authored by the Archives nationales ##


_History note_  : first version written for the PIAAF project (processing about 280 authority records coming from ANF, BnF and MCC, + about 40 findings aids and 2 common draft vocabularies), last updates dated February 2018 ; latest version written in December 2018 for the ANF Hackathon -  processing 5019 authority records authored by the ANF, + 4 vocabularies used for indexing the records and finding aids at the ANF + all the gazetteers).
In March 2019 : XSLs reviewed (debugged, cleaned, rewritten for a few parts, + a few lines of documentation added).


_Author_ : Florence Clavaud (Mission référentiels, Archives nationales de France)


_License_ : well we'll see if they are worth having a free open source license. For now they are not public. 


### Content ###

_the XSLs_ :
Come with a small params.xml file and a vide.xml file, that is used as a starting point (input file) for many of them.
The file names begin with a number, which specifies the processing order. 
The XSLs whose names begin with '0' are provided here but at this stage we don't think that they should be part of the future tool library. They are used for processing the vocabularies and places, but the RDF output may be considered as input files for the conversion tool. Besides, the XSLs used for places may change a lot (or even be replaced) since our vocabularies will also change a lot. This has to be discussed.
Though the XSL set should in the future be handled through a pipeline, these XSLs have been written so that each of them is autonomous, because we needed to check the output carefully at this stage of development.
The XSLs work well but of course they can be enhanced : some source elements or attributes may not be processed; some of them can be processed more accurately; the method followed can be questioned (for example for identifying the resources); the instructions only take into account the current state of the source authority records - and a lot of things will change quite soon, e.g. the relations between agents will have sub-categories allowing to process them better (like in the PIAAF project)  ; and they only take into account the EAC CPF application profile implemeted in this information system, which is a (large) subset of the EAC CPF model.
For now, the XSL library does not include the XSLs for processing finding aids. We will commit what we have later on.


_Several subfolders_:

* **src**  folder: the XML source files (NP : the 5019 EAC-CPF authority records, as they were exported from the ANF information system in November 2018, + the W3C EAC-CPF schema and a CSV list ; RI : the vocabularies and gazetteers, + some files containing some SPARQL query results used for enriching the gazetteers from INSEE and IGN datasets 
* **src-2**  folder: the same 5019 authoriy records as in src/NP, to which @xml:id attributes have been added using the '1-generateIdentifiers.xsl' file. The conversion to RDF is in fact made from this src-2 version of the records
* **temp** folder : some  other XML files, left here, just in case they are useful. Most of them are temporary files (=variables generated during the conversion process, and serialized here just for checking. 
* **rdf** folder : the RDF/XML output, with some subfolders. Also includes :
  * in the **languages** folder: a first, very incomplete, version of RiC-O languages, authored by hand by Pauline Charbonnier for now (we have a languages vocabulary in the IS, and plan to convert it later)
  * in the **ontology** folder, the version of RiC-O that has been  used.
  * in the **places-step-1** folder : the first temporary output from the gazetteers fo the French contemporary districts (generated using the '0b1-convertANPlacesVocabs-FrenchContempDistricts.xsl')
  * in the **rules** folder: a first, very incomplete, version of RiC-O rules ('referentiel_rules.xml' file). Authored by hand by Pauline Charbonnier, so that the XSL tool can take into account the possibility of handling such a reference list. The ANF information system not have yet such a reference list, but may have one later
  * in the **vocabularies** folder : apart from the SKOS versions of the 4 source vocabularies, a  'FRAN_RI_104_Ginco_legalStatuses.rdf' file (authored directly in Ginco by Pauline Charbonnier)