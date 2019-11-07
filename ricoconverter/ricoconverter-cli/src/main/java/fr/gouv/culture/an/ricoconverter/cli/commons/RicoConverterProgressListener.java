package fr.gouv.culture.an.ricoconverter.cli.commons;

import java.io.File;

import org.apache.commons.io.FileUtils;

import fr.gouv.culture.an.ricoconverter.RicoConverterListenerException;
import fr.gouv.culture.an.ricoconverter.eac.convert.Eac2RicoConverterListener;
import fr.gouv.culture.an.ricoconverter.eac.convert.Eac2RicoConverterListenerBase;
import fr.gouv.culture.an.ricoconverter.ead.convert.Ead2RicoConverterListener;
import me.tongfei.progressbar.ProgressBar;
import me.tongfei.progressbar.ProgressBarStyle;

public class RicoConverterProgressListener extends Eac2RicoConverterListenerBase implements Eac2RicoConverterListener, Ead2RicoConverterListener {

	public long totalInputFiles;
	private ProgressBar progress;
	
	public RicoConverterProgressListener() {

	}
	
	@Override
	public void handleStart(File inputFile) throws RicoConverterListenerException {
		// Count recursively
		this.totalInputFiles = FileUtils.listFiles(inputFile, new String[] {"xml"}, true).size();
		this.progress = new ProgressBar("RiC-O Converter", totalInputFiles, ProgressBarStyle.ASCII);
	}

	@Override
	public void handleStop() throws RicoConverterListenerException {
		this.progress.close();
	}

	@Override
	public void handleError(File inputFile) throws RicoConverterListenerException {
		this.progress.step();
	}

	@Override
	public void handleBeginProcessing(File inputFile) throws RicoConverterListenerException {
		// nothing
	}

	@Override
	public void handleEndProcessing(File inputFile) throws RicoConverterListenerException {
		this.progress.step();
	}

	@Override
	public void handleStartArrange() throws RicoConverterListenerException {
		this.progress.close();
		System.out.println("Grouping relations...");
	}

	@Override
	public void handleStartDeduplicating() throws RicoConverterListenerException {
		System.out.println("Deduplicating relations...");
	}

}
