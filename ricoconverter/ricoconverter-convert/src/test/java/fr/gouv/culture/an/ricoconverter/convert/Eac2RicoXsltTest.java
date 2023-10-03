package fr.gouv.culture.an.ricoconverter.convert;

import java.io.File;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import org.junit.runner.RunWith;
import org.junit.runners.AllTests;

import junit.framework.TestSuite;

/**
 * Don't rename this class , it has to end with *Test to be picked up my Maven surfefire plugin
 *
 */
@RunWith(AllTests.class)
public class Eac2RicoXsltTest {
	
    public static TestSuite suite() {
        TestSuite ts = new TestSuite();

        File testDir = new File("src/test/resources/eac2rico");
        List<File> sortedList = Arrays.asList(testDir.listFiles());
        Collections.sort(sortedList);
		String testParameter = System.getProperty("testDir");
		if(testParameter != null) {
			System.out.println("test parameter detected : '"+testParameter+"'");
		}
        for (File aDir : sortedList) {
        	if(
        			aDir.isDirectory()
        			&&
        			(
        					testParameter == null
        					||
        					testParameter.equals(aDir.getName())
        			)
        	) {
        		ts.addTest(new Eac2RicoXsltTestExecution(aDir));
        	}
		}
        

        return ts;
    }

}
