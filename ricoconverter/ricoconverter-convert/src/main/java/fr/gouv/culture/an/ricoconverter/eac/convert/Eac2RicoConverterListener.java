package fr.gouv.culture.an.ricoconverter.eac.convert;

import java.io.File;

import fr.gouv.culture.an.ricoconverter.RicoConverterListenerException;

public interface Eac2RicoConverterListener {

	public void handleStart(File inputFile) throws RicoConverterListenerException;
	
	public void handleStartArrange() throws RicoConverterListenerException;
	
	public void handleStartDeduplicating() throws RicoConverterListenerException;
	
	public void handleStop() throws RicoConverterListenerException;
	
	public void handleBeginProcessing(File inputFile) throws RicoConverterListenerException;
	
	public void handleEndProcessing(File inputFile) throws RicoConverterListenerException;
	
	public void handleError(File inputFile) throws RicoConverterListenerException;
	
}
