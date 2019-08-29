[_Home_](index.html) > Unit Tests

# Unit Tests

## Running unit tests

- To run unit tests, launch the batch with the command "test".
- The unit tests files are located under the subfolder "unit-tests".
- Each unit tests is a subfolder with the same structure :
	- input.xml is a small EAC-CPF file
	- expected.xml is the expected result of the stylesheet
	- result.xml will be generated when running the unit tests
- The console log shows a "success"/"FAILURE" message for each unit test

### Creating new unit tests

- To write new unit tests, add a subfolder under `ricoconverter/ricoconverter-convert/src/test/resources/eac2rico`, with an `input.xml` and an `expected.xml` file.

