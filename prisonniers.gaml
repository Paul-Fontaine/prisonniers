/**
* Name: prisonniers
* Based on the internal skeleton template. 
* Author: Utilisateur
* Tags: 
*/

model prisonniers

global {
	/** Insert the global definitions, variables and actions here */
	geometry shape <- square(200#m);
	
	init {
		create traitre number:1;
		create cooperateur number:1;
	}
}

species prisonnier skills: [moving] {
	rgb color;
	reflex deplacement {
		do wander;
	}
	
	aspect base {
		draw circle(2) color: color;
	}
}

species traitre parent: prisonnier {
	init {
		color <- #red;
		speed <- 0.1;
	}
}

species cooperateur parent: prisonnier {
	init {
		color <- #blue;
		speed <- 1.0;
	}
}

experiment prisonniers type: gui {
	/** Insert here the definition of the input and output of the model */
	output {
		display main_display type:2d{
			species traitre aspect:base;
			species cooperateur aspect:base;
		}
	}
}
