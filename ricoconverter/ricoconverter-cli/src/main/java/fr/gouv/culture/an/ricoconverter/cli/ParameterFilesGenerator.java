package fr.gouv.culture.an.ricoconverter.cli;

import java.io.File;
import java.io.IOException;
import java.lang.reflect.Field;

import org.apache.commons.io.FileUtils;

import com.beust.jcommander.Parameter;

import fr.gouv.culture.an.ricoconverter.cli.Main.COMMAND;

public class ParameterFilesGenerator {

	public static void main(String[] args) throws IOException {
		File outputDir = new File(args[0]);
		
		COMMAND[] commands = Main.COMMAND.values();
		for (COMMAND aCommand : commands) {
			File outputFile = new File(outputDir, aCommand.name().toLowerCase()+".properties");
			
			StringBuffer sb = new StringBuffer();
			Field[] fields = aCommand.getArguments().getClass().getDeclaredFields();
			
			for (Field aField : fields) {
				Parameter parameters = aField.getAnnotation(Parameter.class);
				if(parameters != null) {
					sb.append("#"+"\n");
					sb.append("# "+parameters.description().replaceAll("\n", "\n# ")+"\n");
					sb.append(parameters.required()?"# Required"+"\n":"# Optional"+"\n");
					sb.append("#"+"\n");
					sb.append((!parameters.required()?"#":"")+parameters.names()[0]+"="+"\n");
					sb.append("\n");
				}
			}
			
			if(aCommand.getArguments().getClass().getSuperclass() != null) {
				for (Field aField : aCommand.getArguments().getClass().getSuperclass().getDeclaredFields()) {
					Parameter parameters = aField.getAnnotation(Parameter.class);
					if(parameters != null) {
						sb.append("#"+"\n");
						sb.append("# "+parameters.description().replaceAll("\n", "\n# ")+"\n");
						sb.append(parameters.required()?"# Required"+"\n":"# Optional"+"\n");
						sb.append("#"+"\n");
						sb.append((!parameters.required()?"#":"")+parameters.names()[0]+"="+"\n");
						sb.append("\n");
					}
				}
			}
			
			FileUtils.write(outputFile, sb.toString(), "UTF-8");
		}
		
	}

}
