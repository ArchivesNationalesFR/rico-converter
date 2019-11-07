package fr.gouv.culture.an.ricoconverter.ead.convert;

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.Iterator;
import java.util.List;

import org.apache.commons.io.FileUtils;
import org.apache.commons.io.filefilter.TrueFileFilter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import fr.gouv.culture.an.ricoconverter.RicoConverterListenerException;

public class Ead2RicoConverterReportListener extends Ead2RicoConverterListenerBase implements Ead2RicoConverterListener {

	private Logger log = LoggerFactory.getLogger(this.getClass().getName());
	
	
	private Date startTime;
	private Date endTime;
	private long nbFilesInput;
	private long nbFilesProcessed = 0;
	private long nbFilesSuccessfull = 0;
	private long nbFilesErrors = 0;
	private List<String> errorFileNames = new ArrayList<String>();
	
	
	public Ead2RicoConverterReportListener() {

	}
	
	@Override
	public void handleStart(File inputFile) throws RicoConverterListenerException {
		this.nbFilesInput = FileUtils.listFiles(inputFile, new String[] {"xml"}, true).size();
		this.startTime = new Date();
	}

	@Override
	public void handleStop() throws RicoConverterListenerException {
		this.endTime = new Date();
		log.info(this.printReport());
	}

	@Override
	public void handleBeginProcessing(File inputFile) throws RicoConverterListenerException {
		nbFilesProcessed++;
	}

	@Override
	public void handleEndProcessing(File inputFile) throws RicoConverterListenerException {
		nbFilesSuccessfull++;
	}
	
	@Override
	public void handleError(File inputFile) throws RicoConverterListenerException {
		this.errorFileNames.add(inputFile.getName());
		nbFilesErrors++;
	}

	public long getNbFilesInput() {
		return nbFilesInput;
	}

	public Date getStartTime() {
		return startTime;
	}

	public Date getEndTime() {
		return endTime;
	}

	public long getNbFilesSuccessfull() {
		return nbFilesSuccessfull;
	}

	public long getNbFilesErrors() {
		return nbFilesErrors;
	}

	public long getNbFilesProcessed() {
		return nbFilesProcessed;
	}	
	
	public List<String> getErrorFileNames() {
		return errorFileNames;
	}

	public String printReport() {
		StringBuffer sb = new StringBuffer();
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd hh:mm:ss");
		long duration = this.endTime.getTime() - this.startTime.getTime();
		long durationInSeconds = duration / 1000;
		sb.append("\n");
		sb.append("\n");
		sb.append("--- EAD Conversion Report ---"+"\n");
		sb.append("- Number of files to process: "+this.nbFilesInput+"\n");
		sb.append("- Number of files in ERROR  : "+this.nbFilesErrors+"\n");
		sb.append("- Number of files in success: "+this.nbFilesSuccessfull+"\n");
		sb.append("\n");
		sb.append("List of files in errors: "+"\n");
		if(this.errorFileNames.isEmpty()) {
			sb.append("  None !"+"\n");
		} else {
			for (int j = 0; j < errorFileNames.size(); j++) {
				sb.append("  "+errorFileNames.get(j)+"\n");
				if(j == 100) {
					sb.append("  "+"... (showing only 100 values)"+"\n");
				}
			}
		}
		
		sb.append("\n");
		sb.append("Process took "+String.format("%d:%02d:%02d", durationInSeconds / 3600, (durationInSeconds % 3600) / 60, (durationInSeconds % 60))+" (started at "+sdf.format(this.startTime)+", ended at "+sdf.format(this.endTime)+")"+"\n");
		return sb.toString();
	}
}
