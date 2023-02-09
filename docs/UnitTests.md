[_Home_](index.html) > Unit Tests

# Unit Tests

## Running unit tests

- To run unit tests, launch the batch with the command `test_ead` or `test_eac` depending if you want to run EAD or EAC tests.
- The unit tests files are located under the subfolders `unit-tests/eac2rico` and `unit-tests/ead2rico`.
- Each unit tests is a subfolder with the same structure :
	- `input.xml` is a small EAC-CPF or EAD file
	- `expected.xml` is the expected result of the stylesheet
	- `result.xml` will be generated when running the unit tests
- The console log shows a "success"/"FAILURE" message for each unit test


### Some XML elements are ignored

As the XML elements under test represent a small fraction of the whole content of each XML documents, and to ease the maintenance of unit tests, some XML elements are _not checked_ for each unit tests. **This means the `expected.xml` file may slightly differ from the actual conversion results.** The XML elements that can differ are :

- rico:hasProvenance
- rico:heldBy
- rico:seeAlso
- rico:regulatedBy


### Creating new unit tests

- If you modify the stylesheets, you can add directly new folders under `unit-tests/eac2rico` or `unit-tests/ead2rico`, and run the tests command of the converter. New folders will be picked up automatically.
- To write new unit tests in the source code, once you have tested them, add a subfolder under `ricoconverter/ricoconverter-convert/src/test/resources/eac2rico`, with an `input.xml` and an `expected.xml` file.

