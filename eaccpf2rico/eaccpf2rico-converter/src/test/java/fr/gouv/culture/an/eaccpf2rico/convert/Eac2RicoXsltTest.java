package fr.gouv.culture.an.eaccpf2rico.convert;

import java.io.File;

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
        for (File aDir : testDir.listFiles()) {
        	if(aDir.isDirectory()) {
        		ts.addTest(new Eac2RicoXsltTestExecution(aDir));
        	}
		}
        

        return ts;
    }

}
