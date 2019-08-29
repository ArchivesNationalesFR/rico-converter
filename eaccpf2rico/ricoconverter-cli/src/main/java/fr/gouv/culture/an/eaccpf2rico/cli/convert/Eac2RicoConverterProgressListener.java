package fr.gouv.culture.an.eaccpf2rico.cli.convert;

import java.io.File;

import org.apache.commons.io.FileUtils;
import org.apache.commons.io.filefilter.TrueFileFilter;

import fr.gouv.culture.an.ricoconverter.RicoConverterListenerException;
import fr.gouv.culture.an.ricoconverter.eac.convert.Eac2RicoConverterListener;
import fr.gouv.culture.an.ricoconverter.eac.convert.Eac2RicoConverterListenerBase;
import me.tongfei.progressbar.ProgressBar;
import me.tongfei.progressbar.ProgressBarStyle;

public class Eac2RicoConverterProgressListener extends Eac2RicoConverterListenerBase implements Eac2RicoConverterListener {

	public long totalInputFiles;
	private ProgressBar progress;
	
	public Eac2RicoConverterProgressListener() {

	}
	
	@Override
	public void handleStart(File inputFile) throws RicoConverterListenerException {
		// Count recursively
		this.totalInputFiles = FileUtils.listFiles(inputFile, TrueFileFilter.INSTANCE, TrueFileFilter.INSTANCE).size();
		this.progress = new ProgressBar("EAC2RiC-O", totalInputFiles, ProgressBarStyle.ASCII);
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
