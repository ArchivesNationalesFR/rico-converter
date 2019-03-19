package fr.gouv.culture.an.eaccpf2rico;

import static java.lang.annotation.ElementType.FIELD;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

@Retention(RetentionPolicy.RUNTIME)
@Target(FIELD)
public @interface Description {

	public int notation();
	public String definition();
}
