package fr.gouv.culture.an.eaccpf2rico.cli.test;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import fr.gouv.culture.an.eaccpf2rico.cli.CommandIfc;
import fr.gouv.culture.an.eaccpf2rico.cli.convert.ArgumentsConvert;
import fr.gouv.culture.an.eaccpf2rico.cli.convert.Eac2RicoConverterFactory;
import fr.gouv.culture.an.ricoconverter.RicoConverterException;
import fr.gouv.culture.an.ricoconverter.ErrorCode;
import fr.gouv.culture.an.ricoconverter.eac.convert.Eac2RicoConverter;

public class Test implements CommandIfc {

	private Logger log = LoggerFactory.getLogger(this.getClass().getName());

	@Override
	public void execute(Object o) {
		log.info("Running command : "+this.getClass().getSimpleName());
		long start = System.currentTimeMillis();
		ArgumentsTest args = (ArgumentsTest)o;
		log.info("  Unit tests folder : {}", args.getUnitTests().getAbsolutePath());
		
		try {
			// check that input is a directory
			if(!args.getUnitTests().isDirectory()) {
				throw new RicoConverterException(ErrorCode.INPUT_IS_NOT_A_DIRECTORY, "Unit tests parameter "+args.getUnitTests()+" is not a directory.");
			}
			
			ArgumentsConvert defaultArgs = new ArgumentsConvert();
			Eac2RicoConverterFactory factory = new Eac2RicoConverterFactory(defaultArgs);			
			Eac2RicoConverter converter = factory.createConverter(args.getXslt(), defaultArgs.getOutput(), defaultArgs.getError(), defaultArgs.getInput());
			converter.unitTests(args.getUnitTests());			
			
			log.info("Command : "+this.getClass().getSimpleName()+" finished successfully in {} ms", (System.currentTimeMillis() - start));
		} catch (RicoConverterException e) {
			log.error("Exception "+e.getCode().name()+" (code "+e.getCode().getCode()+") : ", e.getMessage(), e);
		}		
		
		
	}

}
