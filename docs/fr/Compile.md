[Accueil](index.md) > Compiler RiC-O Converter

# Compiler RiC-O Converter

Si vous avez simplement besoin d’ajuster le contenu des feuilles de style XSLT 
de conversion, vous pouvez le faire sans avoir besoin de recompiler, car ces fichiers ne 
sont pas inclus dans le convertisseur. Consultez 
[Comment personnaliser la conversion](Customize.md) pour cela.
Cependant, vous souhaiterez peut-être modifier le comportement du Wrapper Java des XSLT. 
Cela est nécessaire uniquement si vous souhaitez ajouter de nouvelles commandes au 
convertisseur ou ajouter de nouveaux paramètres aux commandes. Cette documentation explique 
comment procéder.

## Obtenir le code source du convertisseur

Pour compiler, vous devez obtenir les fichiers sources du projet.

## Prérequis : Java et Maven

Vous avez besoin d’un [JDK](https://jdk.java.net/) installé, 
de la version 1.8 ou une version plus récente, sur la machine sur laquelle vous 
souhaitez compiler le convertisseur, ainsi que de [Maven](https://maven.apache.org/).

## Comment compiler

Exécutez simplement les commandes suivantes :

    > cd ricoconverter
    > mvn clean install


Le résultat de la compilation est généré sous 
`ricoconverter-release/target/ricoconverter-release-{version}.zip`.

Notez que la compilation exécute également les tests unitaires. 
Pour les ignorer, exécutez `mvn -DskipTests clean install` au lieu 
de `mvn clean install`.
