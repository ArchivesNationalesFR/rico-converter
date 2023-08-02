[_Home_](index.md) > Compile RiC-O converter

# Compile RiC-O converter

If you simply need to adjust the content of the conversion XSLT stylesheets, you can do so without the need to recompile, as these files are not bundled inside the converter. See [How to customize the conversion](Customize.md).
You may however want to change the way the Java wrapper of the XSLTs behave. This is needed only if you want to add new commands to the converter, or add new parameters to the commands. This documentation explain how to do so.

## Obtain the source of the converter

To compile you need to obtain the sources of the project.

## Prerequisites : Java and Maven

You need a [JDK](https://jdk.java.net/) installed, at least version 1.8, on the machine you need to compile the converter, as well as [Maven](https://maven.apache.org/).

## How to compile

Simply run the following commands :


	> cd ricoconverter
	> mvn clean install


The result of the compilation is generated under `ricoconverter-release/target/ricoconverter-release-{version}.zip`.

Note that the compilation also runs the unit tests. To skip them, run `mvn -DskipTests clean install` instead of `mvn clean install`.