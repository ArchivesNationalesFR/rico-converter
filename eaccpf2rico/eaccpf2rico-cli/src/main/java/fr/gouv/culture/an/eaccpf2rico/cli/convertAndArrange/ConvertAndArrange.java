package fr.gouv.culture.an.eaccpf2rico.cli.convertAndArrange;

import java.io.IOException;

import org.apache.commons.io.FileUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import fr.gouv.culture.an.eaccpf2rico.Eac2RicoConverterException;
import fr.gouv.culture.an.eaccpf2rico.ErrorCode;
import fr.gouv.culture.an.eaccpf2rico.arrange.Eac2RicoArranger;
import fr.gouv.culture.an.eaccpf2rico.cli.CommandIfc;
import fr.gouv.culture.an.eaccpf2rico.cli.convert.Convert;

public class ConvertAndArrange implements CommandIfc {

	private Logger log = LoggerFactory.getLogger(this.getClass().getName());

	@Override
	public void execute(Object o) {
		log.info("Running command : "+this.getClass().getSimpleName());
		long start = System.currentTimeMillis();
		ArgumentsConvertAndArrange args = (ArgumentsConvertAndArrange)o;
		log.info("  Input folder : {}", args.getInput().getAbsolutePath());
		log.info("  Output folder : {}", args.getOutput().getAbsolutePath());
		log.info("  Error folder : {}", args.getError().getAbsolutePath());
		log.info("  Work folder : {}", args.getWork().getAbsolutePath());
		
		try {
			try {
				log.info("Cleaning work folder...");
				FileUtils.deleteDirectory(args.getWork());
				args.getWork().mkdirs();
			} catch (IOException e) {
				throw new Eac2RicoConverterException(ErrorCode.DIRECTORY_OR_FILE_HANDLING_EXCEPTION, e);
			}
			
			log.info("Running conversion ...");
			long startConvert = System.currentTimeMillis();
			ArgumentsConvertAndArrange argsCopy = new ArgumentsConvertAndArrange(args);
			// make sure we call the conversion with the work folder as output
			argsCopy.setOutput(args.getWork());
			new Convert().doConvert(argsCopy);
			log.info("Cone conversoin in {} ms", (System.currentTimeMillis() - startConvert));	
			
			log.info("Arranging output files ...");
			long startArrange = System.currentTimeMillis();
			Eac2RicoArrangerFactory af = new Eac2RicoArrangerFactory();
			Eac2RicoArranger arranger = af.createArranger(
					args.getXsltArrange(),
					// output is final output directory
					args.getOutput(),
					args.getError()
			);
			// input is work directory
			arranger.processDirectory(args.getWork());
			log.info("Done arranging in {} ms", (System.currentTimeMillis() - startArrange));	
			
			log.info("Command : "+this.getClass().getSimpleName()+" finished successfully in {} ms", (System.currentTimeMillis() - start));
		} catch (Eac2RicoConverterException e) {
			log.error("Exception "+e.getCode().name()+" (code "+e.getCode().getCode()+") : ", e.getMessage(), e);
		}	
	}

}
