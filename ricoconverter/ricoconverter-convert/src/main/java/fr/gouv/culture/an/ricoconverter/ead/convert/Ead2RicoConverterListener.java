package fr.gouv.culture.an.ricoconverter.ead.convert;

import java.io.File;

import fr.gouv.culture.an.ricoconverter.RicoConverterListenerException;

public interface Ead2RicoConverterListener {

	public void handleStart(File inputFile) throws RicoConverterListenerException;
	
	public void handleStop() throws RicoConverterListenerException;
	
	public void handleBeginProcessing(File inputFile) throws RicoConverterListenerException;
	
	public void handleEndProcessing(File inputFile) throws RicoConverterListenerException;
	
	public void handleError(File inputFile) throws RicoConverterListenerException;
	
}
