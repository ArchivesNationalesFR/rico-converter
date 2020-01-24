[_Home_](index.html) > Compile RiC-O converter

# Compile RiC-O converter

If you simply need to adjust the content of the conversion stylesheets, you can do so without the need to recompile. See [How to customize the conversion](Customize.html).
You may however want to change the way the Java wrapper of the XSLTs behave. This documentation explain how to do so.

## Obtain the source of the converter

To compile you need to obtain the sources of the project.

## Prerequisites : Java and Maven

You need a JDK 1.8 installed on the machine you need to compile the converter, as well as [Maven](https://maven.apache.org/).

## How to compile

```
cd ricoconverter
mvn clean install
```

The result of the compilation is under `ricoconverter-release/target/ricoconverter-release.zip`.

Note that the compilation runs the unit tests. To skip them, run `mvn -DskipTests clean install`.