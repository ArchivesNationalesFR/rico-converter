package fr.gouv.culture.an.eaccpf2rico.convert;

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
        for (File aDir : sortedList) {
        	if(aDir.isDirectory()) {
        		ts.addTest(new Eac2RicoXsltTestExecution(aDir));
        	}
		}
        

        return ts;
    }

}
