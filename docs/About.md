[_Home_](index.html) > About

# About RiC-O Converter

## Why RiC-O Converter?

The Archives nationales de France ([ANF](http://www.archives-nationales.culture.gouv.fr/)) have been interested in entity/relationships models and graph technologies since 2013, one of the reasons being that they already have authored a significant, and growing, number of authority records (on corporate bodies, persons and families that created or accumulated the archival fonds held by the institution) that were linked to each other and to the descriptions of the archives themselves. This in essence constitutes a very dense oriented graph, whose relations are not really displayed, and cannot be queried and processed in the ANF current information system. The ANF also wanted to connect these metadata with other metadata sets created by other institutions. Linked Data technologies thus seemed to be a possible solution to meet these needs.

The ANF also have been actively involved in the development of Records In Contexts standard (both the Conceptual Model and its OWL implementation, RiC-O) since the beginning, when the ICA EGAD group was formed. __As the first version of RiC-CM and beta versions of RiC-O were being written, it was very important to test RiC and its ability to represent existing metadata, and to learn from these tests, both for improving RiC and for thinking of future real world implementations__.

The ANF first built a __qualitative proof of concept__, with two other institutions, the French National Libray ([BnF](https://www.bnf.fr)) and a subdivision of the French ministry of Culture (the Service ministériel des Archives de France, [SIAF](https://francearchives.fr/article/26287441)), and a private company ([Logilab](https://www.logilab.fr/)). The target was to demonstrate that it is possible to convert existing archival metadata sets into RDF datasets conforming to RiC-O (in 2017-2018 it was an early version of the ontology), to interconnect the RDF datasets coming from several institutions and to explore and visualize them using new methods. The __proof of concept, named PIAAF (Pilote d’Interopérabilité pour les Autorités archivistiques françaises) was released in February 2018 ([https://piaaf.demo.logilab.fr](https://piaaf.demo.logilab.fr))__, with a [tutorial](https://piaaf.demo.logilab.fr/editorial/help), and [a report on the methodology followed and outcomes](https://piaaf.demo.logilab.fr/editorial/contexte-technique). Not only were the results obtained of high quality but the partners were also able to assess the improvement this solution offers in terms of accuracy and search possibilities.

However, __PIAAF proof of concept did not take into account the huge quantity of archival metadata created and maintained by the ANF__ (about 28.000 EAD 2002 finding aids and 15.000 EAC-CPF authority records for now), nor the variety of their structure and content. The datasets that had been selected for the project were small (276 authority records and 38 finding aids), came from three institutions, and had been very carefully checked, so that they conformed to some common rules, which resulted to a quite homogeneous corpus. Besides, __the reference ontology, RiC-O, changed a lot since the end of 2017__, and its first public release, dated December 2019, is very different from the version used two years earlier.


## RiC-O Converter main features

In order to move forward to a far larger scale, the ANF decided in 2018 to __develop a tool for converting the whole of their archival metadata__, that would have, when finished (thus by the beginning of 2020) the following features:

- output __RDF datasets conforming to the latest official version of RiC-O__;
- be __efficient__(take into account any component of the ANF XML files, in the best possible way) and __fast__(the conversion process should last not more than a few minutes);
- be autonomous, independent from the ANF archival information system, __easy to install and process__ by any archivist on a personal computer;
- be __configurable__;
- be __precisely documented__;
- be __open source and released under a free license__, to that it can be modified by any institution or person which would need to do so.


The ANF therefore worked for a year with a small private company specializing in semantic web, information management and knowledge engineering, __[Sparna](http://www.sparna.fr/)__. __RiC-O Converter is the result of this project__. __The Department of digital innovation of the French Ministry of Culture funded and supported this project__, as part of the [semantic roadmap of the ministry](https://www.enssib.fr/bibliotheque-numerique/documents/64776-feuille-de-route-strategique-metadonnees-culturelles-et-transition-web-3-0.pdf) for which it is responsible.

The ANF now have converted all their EAD and EAC-CPF files metadata to RDF; and they are updating and enhancing the RDF resulting files. They also have converted to RDF (the main reference models being RiC-O and SKOS) the whole of their controlled vocabularies and lists of places. As they wish to add some semantic modules to their archival information system, they are  now exploring some leads through several projects, in order to define a global Linked Open Data strategy.

RiC-O Converter was developed with and for the ANF and does not aim to be a generic tool. It therefore has some limits. However, as it has the features listed above, __it may be a good starting point for any project that would need to get good quality RDF/RiC-O datasets from existing EAD or EAC-CPF files__.

Of course, French archives, which have encoding practices quite similar to those of the ANF, could be the first institutions interested. However, EAD 2002 and EAC-CPF are now widely used worldwide, by many archive services and by portals or aggregators, as storage and exchange formats. If different practices can be observed there, these institutions share at least the same XML reference models, within which certain elements or attributes are systematically used. We therefore believe that RiC-O Converter can be useful to many institutions other than the ANF. Note that __the conversion of EAD files is done separately from that of EAC-CPF files__. So if you have 'only' EAD files or 'only' EAC-CPF files, you can use it. In addition, __the software, placed under CeCILL-B license (equivalent to MIT license), can be modified to be adapted to a specific project, and also widely redistributed__. It has been precisely documented in English (see the EAD to RiC-O and EAC-CPF to RiC-O [mappings](Mappings.html), and the [unit tests](UnitTests.html)) to facilitate these adaptations. __A good XSLT developer__, knowing the formats of the source metadata, and having taken a little time to understand the essentials of RiC-O, __can easily adapt RiC-O Converter__. Finally, the ANF will continue to develop it, and we can hope that a larger community will be formed to continue the developments.


## More information

You can access some slides (in French) on RiC-O Converter (presented on January 28, 2020), [here](https://f.hypotheses.org/wp-content/blogs.dir/2167/files/2020/02/20200128_4_RiCOConverter.pdf).

If you or your institution are a member of ICA, you also can find an article on RiC-O Converter in [Flash (the ICA biannual newspaper, dated April 2020) n° 39](https://www.ica.org/en/flash).

About the ANF projects: you can get more information (in French) [here](https://f.hypotheses.org/wp-content/blogs.dir/2167/files/2020/02/20200128_3_RiCauxAN_EnjeuxPremieresRealisations.pdf). You can also read this article (in French) written by Florence Clavaud: Transformer les métadonnées des Archives nationales en graphe de données : enjeux et premières réalisations, in _Les Archives nationales, une refondation pour le XXIe siècle, La Gazette des Archives_, n°254 (2019-2), Association des Archivistes Français, Paris, 2019, p. 59-88.
