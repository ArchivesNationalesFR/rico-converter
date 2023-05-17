package fr.gouv.culture.an.ricoconverter.cli.test_ead;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import fr.gouv.culture.an.ricoconverter.ErrorCode;
import fr.gouv.culture.an.ricoconverter.RicoConverterException;
import fr.gouv.culture.an.ricoconverter.cli.CommandIfc;
import fr.gouv.culture.an.ricoconverter.cli.convert_ead.ArgumentsConvertEad;
import fr.gouv.culture.an.ricoconverter.cli.convert_ead.Ead2RicoConverterFactory;
import fr.gouv.culture.an.ricoconverter.ead.convert.Ead2RicoConverter;

public class TestEad implements CommandIfc {

	private Logger log = LoggerFactory.getLogger(this.getClass().getName());

	@Override
	public void execute(Object o) {
		log.info("Running command : "+this.getClass().getSimpleName());
		long start = System.currentTimeMillis();
		ArgumentsTestEad args = (ArgumentsTestEad)o;
		log.info("  Unit tests folder : {}", args.getUnitTests().getAbsolutePath());
		
		try {
			// check that input is a directory
			if(!args.getUnitTests().isDirectory()) {
				throw new RicoConverterException(ErrorCode.INPUT_IS_NOT_A_DIRECTORY, "Unit tests parameter "+args.getUnitTests()+" is not a directory.");
			}
			
			ArgumentsConvertEad defaultArgs = new ArgumentsConvertEad();
			Ead2RicoConverterFactory factory = new Ead2RicoConverterFactory();			
			Ead2RicoConverter converter = factory.createConverter(
					args.getXslt(),
					defaultArgs.getOutput(),
					defaultArgs.getError(),
					defaultArgs.getInput(),
					// no splitting
					false,
					// filter @audience=internal
					true,
					// no filter @audience=external
					false
			);
			converter.unitTests(args.getUnitTests());			
			
			log.info("Command : "+this.getClass().getSimpleName()+" finished successfully in {} ms", (System.currentTimeMillis() - start));
		} catch (RicoConverterException e) {
			log.error("Exception "+e.getCode().name()+" (code "+e.getCode().getCode()+") : ", e.getMessage(), e);
		}		
		
		
	}

}
