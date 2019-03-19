package fr.gouv.culture.an.eaccpf2rico.cli.convert;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import fr.gouv.culture.an.eaccpf2rico.Eac2RicoConverterException;
import fr.gouv.culture.an.eaccpf2rico.ErrorCode;
import fr.gouv.culture.an.eaccpf2rico.cli.CommandIfc;
import fr.gouv.culture.an.eaccpf2rico.convert.Eac2RicoConverter;

public class Convert implements CommandIfc {

	private Logger log = LoggerFactory.getLogger(this.getClass().getName());

	@Override
	public void execute(Object o) {
		log.info("Running command : "+this.getClass().getSimpleName());
		long start = System.currentTimeMillis();
		ArgumentsConvert args = (ArgumentsConvert)o;
		log.info("  Input folder : {}", args.getInput().getAbsolutePath());
		log.info("  Output folder : {}", args.getOutput().getAbsolutePath());
		
		try {
			// check that input is a directory
			if(!args.getInput().isDirectory()) {
				throw new Eac2RicoConverterException(ErrorCode.INPUT_IS_NOT_A_DIRECTORY, "Input parameter "+args.getInput()+" is not a directory.");
			}
			
			Eac2RicoConverterFactory factory = new Eac2RicoConverterFactory(args);			
			Eac2RicoConverter converter = factory.createConverter(args.getXslt(), args.getOutput(), args.getError(), args.getInput());
			converter.processDirectory(args.getInput());
			log.info("Command : "+this.getClass().getSimpleName()+" finished successfully in {} ms", (System.currentTimeMillis() - start));
		} catch (Eac2RicoConverterException e) {
			log.error("Exception "+e.getCode().name()+" (code "+e.getCode().getCode()+") : ", e.getMessage(), e);
		}		
		
		
	}

}
