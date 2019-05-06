package fr.gouv.culture.an.eaccpf2rico.cli.convertAndArrange;

import java.io.IOException;

import org.apache.commons.io.FileUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import fr.gouv.culture.an.eaccpf2rico.Eac2RicoConverterException;
import fr.gouv.culture.an.eaccpf2rico.ErrorCode;
import fr.gouv.culture.an.eaccpf2rico.cli.CommandIfc;
import fr.gouv.culture.an.eaccpf2rico.cli.convert.Eac2RicoConverterFactory;
import fr.gouv.culture.an.eaccpf2rico.convert.Eac2RicoConverter;

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
			
			log.info("Running conversion and arranging output...");
			
			Eac2RicoConverterFactory factory = new Eac2RicoConverterFactory(args);
			// make sure we call the conversion with the work folder as output
			Eac2RicoConverter converter = factory.createConverter(args.getXslt(), args.getWork(), args.getError(), args.getInput());
			factory.adaptConverterForArrange(
					converter,
					args.getXsltArrange(),
					args.getOutput(),
					args.getError()
			);
			converter.convertDirectoryAndArrange(args.getInput());
			
			log.info("Command : "+this.getClass().getSimpleName()+" finished successfully in {} ms", (System.currentTimeMillis() - start));
		} catch (Eac2RicoConverterException e) {
			log.error("Exception "+e.getCode().name()+" (code "+e.getCode().getCode()+") : ", e.getMessage(), e);
		}	
	}

}
