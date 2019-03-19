package fr.gouv.culture.an.eaccpf2rico.convert;

import java.io.File;

import fr.gouv.culture.an.eaccpf2rico.Eac2RicoConverterListenerException;

public interface Eac2RicoConverterListener {

	public void handleStart(File inputFile) throws Eac2RicoConverterListenerException;
	
	public void handleStop() throws Eac2RicoConverterListenerException;
	
	public void handleBeginProcessing(File inputFile) throws Eac2RicoConverterListenerException;
	
	public void handleEndProcessing(File inputFile) throws Eac2RicoConverterListenerException;
	
	public void handleError(File inputFile) throws Eac2RicoConverterListenerException;
	
}
