[_Accueil_](index.md) > Tests unitaires

# Les tests unitaires

## Exécuter les tests unitaires

- Pour exécuter des tests unitaires, lancez le batch avec la commande `test_ead` ou `test_eac` selon que vous souhaitiez exécuter des tests EAD ou EAC.
- Les fichiers de tests unitaires sont situés dans les sous-dossiers `unit-tests/eac2rico` et `unit-tests/ead2rico`.
- Chaque test unitaire correspond à un sous-dossier qui présente la même structure :
	- `input.xml` est un petit fichier EAC-CPF ou EAD ;
	- `expected.xml` est le résultat attendu de la conversion par la feuille de style XSL ;
	- `result.xml` est généré lors de l’exécution des tests unitaires.
- Le journal de la console affiche un message "success"/"FAILURE" pour chaque test unitaire exécuté.


### Certains éléments XML sont ignorés

Comme les éléments XML testés représentent une petite fraction de l’ensemble du contenu de chaque document XML, et pour faciliter la maintenance des tests unitaires, certains éléments XML ne sont _pas vérifiés_ pour chaque test unitaire. **Cela signifie que le fichier `expected.xml` peut légèrement différer des résultats de conversion réels.** Les éléments XML qui peuvent différer sont les suivants :

- `rico:hasOrganicProvenance`
- `rico:hasOrHadHolder`
- `rdfs:seeAlso`
- `rico:isOrWasRegulatedBy`


### Créer de nouveaux tests unitaires

- Si vous modifiez les feuilles de style XSL, vous pouvez ajouter directement de nouveaux dossiers dans `unit-tests/eac2rico` ou `unit-tests/ead2rico`, et lancer la commande tests du convertisseur. Les nouveaux dossiers seront récupérés automatiquement.
- Pour écrire de nouveaux tests unitaires dans le code source, une fois que vous les avez testés, ajoutez un sous-dossier sous `ricoconverter/ricoconverter-convert/src/test/resources/eac2rico`, avec un fichier `input.xml` et un fichier `expected.xml`.