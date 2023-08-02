[_Home_](index.html) > About

# À propos de RiC-O Converter

## Pourquoi RiC-O Converter?

Les Archives nationales de France ([ANF](http://www.archives-nationales.culture.gouv.fr/)) se sont intéressées aux modèles basés sur les entités et relations et aux 
technologies des graphes depuis 2013, l'une des raisons étant qu'elles ont déjà créé un nombre significatif et en 
constante augmentation de notices d'autorité (sur les organismes, les personnes et les familles qui ont créé ou accumulé les fonds
d'archives détenus par l'institution) qui sont interconnectées et liées aux descriptions des archives elles-mêmes. 
Cela constitue un graphe orienté dense, mais dont les relations ne sont pas visibles et ne 
peuvent pas être interrogées et traitées dans le système d'information actuel des ANF. Les ANF souhaitaient également 
connecter ces métadonnées à d'autres ensembles de métadonnées créés par d'autres institutions. Les technologies des 
données liées semblaient donc être une solution possible pour répondre à ces besoins.

Les ANF ont également été activement impliquées non seulement dans le développement du modèle conceptuel (RiC-CM) de la norme 
Records In Contexts (RiC) mais aussi de son implémentation OWL (RiC-O), et cela, depuis la formation du groupe ICA EGAD en 2012.
__Lorsque la première version de RiC-CM et les versions beta de RiC-O étaient en cours d'écriture, il était très important
de tester RiC et sa capacité à représenter les métadonnées existantes, et d'apprendre de ces tests, à la fois pour 
améliorer RiC et pour réfléchir aux futures mises en œuvre réelles__.

Pour ce faire, les ANF ont d'abord construit une __preuve de concept qualitative__, en collaboration avec deux autres 
institutions, la Bibliothèque nationale de France ([BnF](https://www.bnf.fr)) et un service de l'administration centrale du ministère français de la Culture 
(le Service ministériel des Archives de France, SIAF), ainsi qu'une société privée (Logilab). 
L'objectif était de démontrer qu'il est possible de convertir des ensembles de métadonnées d'archives existantes en 
ensembles de données RDF conformes à RiC-O (à l'époque, en 2017-2018, il s'agissait d'une version précoce de l'ontologie),
d'interconnecter les ensembles de données RDF provenant de plusieurs institutions et de les explorer et de les visualiser à 
l'aide de nouvelles méthodes. La __preuve de concept, appelée PIAAF (Pilote d'Interopérabilité pour les Autorités 
archivistiques françaises), a été publiée en février 2018 ([https://piaaf.demo.logilab.fr](https://piaaf.demo.logilab.fr))__, 
accompagnée d'un [tutoriel](https://piaaf.demo.logilab.fr/editorial/help) et d'[un rapport sur la méthodologie suivie et 
les résultats obtenus](https://piaaf.demo.logilab.fr/editorial/contexte-technique). Non seulement les résultats se sont avérées de bonne  
qualité, mais les partenaires ont également pu évaluer les améliorations que cette solution offre en termes de précision et 
de possibilités de recherche.

Cependant, __la preuve de concept PIAAF ne prenait pas en compte l'énorme quantité de métadonnées d'archives créées et 
gérées par les ANF__ (environ 32 000 instruments de recherche au format EAD 2002 et 16 000 notices d'autorité EAC-CPF), 
ni la variété de leur structure et de leur contenu. Les ensembles de données sélectionnés pour le projet 
étaient de taille limitée (276 notices d'autorité et 38 instruments de recherche), provenant de trois institutions, 
et avaient été soigneusement vérifiés afin de se conformer à certaines règles communes, ce qui avait produit un corpus assez 
homogène. De plus, __l'ontologie de référence, RiC-O, a beaucoup changé depuis la fin de 2017,__ et sa première version 
publique, datée de décembre 2019, est très différente de la version utilisée deux ans plus tôt.

## Les principales caractéristiques du convertisseur RiC-O

Afin de passer à une échelle beaucoup plus grande, les ANF ont décidé en 2018 de développer un outil pour convertir 
l'ensemble de leurs métadonnées d'archives, qui aurait, une fois terminé (donc début 2020), 
les fonctionnalités suivantes :

* produire des __ensembles de données RDF conformes à la dernière version officielle de RiC-O__ ;
* être __efficace__ (prendre en compte tous les composants des fichiers XML des ANF, de la meilleure façon possible) 
et __rapide__ (le processus de conversion ne devrait pas durer plus de quelques minutes) ;
* être autonome, indépendant du système d'information archivistique des ANF, __facile à installer et à utiliser__ 
par tout archiviste sur un ordinateur personnel ;
* être __configurable__ ;
* être __convenablement documenté__ ;
* être __open source et publié sous une licence libre__, 
afin qu'il puisse être modifié par toute institution ou personne qui en aurait besoin.

Pour cela, les ANF ont collaboré pendant un an avec l'entreprise privée __[Sparna](http://www.sparna.fr/)__, spécialisée dans le web sémantique, 
la gestion de l'information et l'ingénierie des connaissances. __RiC-O Converter est le résultat de ce projet__. 
__Le Département de l'innovation numérique du ministère français de la Culture__ a financé et soutenu ce projet (retrouver le nom exact), dans le 
cadre de [la feuille de route sémantique](https://www.enssib.fr/bibliotheque-numerique/documents/64776-feuille-de-route-strategique-metadonnees-culturelles-et-transition-web-3-0.pdf) du ministère dont il a la responsabilité.

Les ANF ont désormais converti toutes leurs métadonnées de fichiers EAD et EAC-CPF en RDF ; et elles mettent à jour et 
améliorent les fichiers RDF résultants. Elles ont également converti en RDF (les principaux modèles de référence étant
RiC-O et SKOS) l'ensemble de leurs vocabulaires contrôlés et listes de lieux. Les ensembles de données RDF produits 
(notices d'autorité et vocabulaires) sont déjà disponibles dans un [dépôt public sur GitHub](https://github.com/ArchivesNationalesFR/Referentiels) 
et continuent d'évoluer. 
Comme les ANF souhaitent ajouter des composants sémantiques à leur système d'information archivistique, elles explorent 
d'autres pistes à travers plusieurs projets, afin de définir une stratégie globale de données liées ouvertes.

RiC-O Converter a été développé en collaboration avec et pour les ANF et n'a pas vocation à être un outil 
générique. Il a donc certaines limites. Cependant, avec les fonctionnalités énumérées ci-dessus, __il peut être un bon 
point de départ pour tout projet ayant besoin d'obtenir des ensembles de données RDF/RiC-O de bonne qualité à partir 
de fichiers EAD ou EAC-CPF existants__.

Bien sûr, les services d'archives français, qui ont des pratiques d'encodage proches de celles des ANF, pourraient être 
les premières institutions intéressées. Cependant, les formats EAD 2002 et EAC-CPF sont désormais largement utilisés 
dans le monde entier, par de nombreux services d'archives et par des portails ou agrégateurs, en tant que formats de 
stockage et d'échange. Même si différentes pratiques peuvent être observées, ces institutions partagent au moins les 
mêmes modèles de référence, au sein desquels certains éléments ou attributs sont systématiquement utilisés. Nous 
pensons donc que le convertisseur RiC-O peut être utile à de nombreuses institutions autres que les ANF. À Noter que __la 
conversion des fichiers EAD est effectuée séparément de celle des fichiers EAC-CPF__. Ainsi, si vous disposez uniquement de 
fichiers EAD ou seulement de fichiers EAC-CPF, vous pouvez l'utiliser. De plus, __le logiciel, placé sous licence 
CeCILL-B (équivalent à la licence MIT), et peut ainsi être modifié pour s'adapter à un projet spécifique, et également 
largement redistribué__. La documentation disponible en anglais et français (voir les [mappings](https://archivesnationalesfr.github.io/rico-converter/Mappings.html) EAD vers RiC-O et EAC-CPF vers 
RiC-O, ainsi que les [tests unitaires](https://archivesnationalesfr.github.io/rico-converter/UnitTests.html)) a été pensée pour faciliter ces adaptations. Un bon développeur XSLT, connaissant les formats 
des métadonnées sources et ayant pris un peu de temps pour comprendre les principes fondamentaux de RiC-O, __peut 
facilement adapter RiC-O Converter__. Enfin, les ANF et Sparna continuent de le développer. 
Après RiC-O Converter 2, ils travailleront très probablement sur une version 3 de l'outil, 
conforme à RiC-O 1.0 (la première version officielle et stable de l'ontologie, qui sera publiée avant octobre 2023). 
Nous espérons qu'une communauté plus large se formera pour poursuivre les développements.

## Informations supplémentaires 

Un __article en anglais sur RiC-O Converter a été accepté en janvier 2023 par le Journal on Computing and Cultural 
Heritage__ (JOCCH) et est maintenant disponible en ligne : voir [https://doi.org/10.1145/3583592](https://doi.org/10.1145/3583592). 
Cet article mentionne le [démonstrateur ANF Sparnatural](https://sparna-git.github.io/sparnatural-demonstrateur-an/), 
qui propose une interface conviviale pour explorer et visualiser un graphe de connaissances d'environ 59 millions 
de triplets RDF/RiC-O produits à l'aide de RiC-O Converter (les données sont disponibles [ici](https://github.com/ArchivesNationalesFR/Sparnatural_prototype_data)).

Vous pouvez aussi accéder à des diapositives (en français) sur RiC-O Converter (présentées le 28 janvier 2020), 
[ici](https://f.hypotheses.org/wp-content/blogs.dir/2167/files/2020/02/20200128_4_RiCOConverter.pdf).


Si vous ou votre institution êtes membre de l'ICA, vous pouvez également trouver un article sur RiC-O Converter dans le 
[Flash (the ICA biannual newspaper, dated April 2020) n° 39](https://www.ica.org/en/flash).

Concernant les projets des ANF : la présentation suivante, faite à Lausanne (Suisse) en décembre 2022, 
en français, donne une mise à jour sur tous les projets en cours : [diapositives](https://enc.hal.science/hal-03957469) ; 
[enregistrement vidéo](https://rec.unil.ch/videos/florence-clavaud-ric-aux-archives-nationales-de-france-enjeux-realisation-perspectives/). 
Vous pouvez également lire cet article (en français) écrit par Florence Clavaud : 
[Transformer les métadonnées des Archives nationales en graphe de données: enjeux et premières réalisations](https://www.persee.fr/doc/gazar_0016-5522_2019_num_254_2_5857), 
dans _Les Archives nationales, une refondation pour le XXIe siècle_, La Gazette des Archives, n°254 (2019-2), 
Association des Archivistes Français, 
Paris, 2019, p. 59-88.
