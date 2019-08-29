package fr.gouv.culture.an.eaccpf2rico.cli.version;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import fr.gouv.culture.an.eaccpf2rico.cli.CommandIfc;

public class Version implements CommandIfc {

	private Logger log = LoggerFactory.getLogger(this.getClass().getName());

	@Override
	public void execute(Object o) {
		System.out.println(this.getClass().getPackage().getImplementationTitle()+", version "+this.getClass().getPackage().getImplementationVersion());
	}

}
