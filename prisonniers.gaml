/**
* Name: prisonniers
* Based on the internal skeleton template. 
* Author: Utilisateur
* Tags: 
*/

model prisonniers

global {
	/** Insert the global definitions, variables and actions here */
	
	int taille_carre <- 200;
	int taille_prisonniers <- 2;
	
	int nb_traitres <- 10;
	rgb color_traitres <- #red;
	float speed_traitres <- 1.0;
	float amplitude_traitres <- 40.0;
	
	int nb_cooperateurs <- 10;
	rgb color_cooperateurs <- #blue;
	float speed_cooperateurs <- 1.0;
	float amplitude_cooperateurs <- 40.0;
	
	geometry shape <- square(taille_carre);
	
	init {
		create traitre number:nb_traitres;
		create cooperateur number:nb_cooperateurs;
	}
}

species prisonnier skills: [moving] {
	rgb color;
	float amplitude <- 30.0;
	
	reflex deplacement {
		do wander amplitude: amplitude;
	}
	
	aspect base {
		draw circle(2) color: color;
	}
}

species traitre parent: prisonnier {
	init {
		color <- color_traitres;
		speed <- speed_traitres;
		amplitude <- amplitude_traitres;
	}
}

species cooperateur parent: prisonnier {
	init {
		color <- color_cooperateurs;
		speed <- speed_cooperateurs;
		amplitude <- amplitude_cooperateurs;
	}
}

experiment prisonniers type: gui {
	/** Insert here the definition of the input and output of the model */
	float minimum_cycle_duration <- 0.05#s;
	
	output {
		display main_display type:2d{
			species traitre aspect:base;
			species cooperateur aspect:base;
		}
	}
	
	// --- General Parameters ---
	parameter "Taille Carré" 
		var: taille_carre <- 200
		type: int 
		min: 50 
		max: 500 
		category: "1. Global Environment";
		
	parameter "Taille Prisonniers" 
		var: taille_prisonniers <- 2
		type: int 
		min: 1 
		max: 10 
		category: "1. Global Environment";


	// --- Traitors (Traitres) Parameters ---
	parameter "Nombre" 
		var: nb_traitres <- 10
		type: int 
		min: 0 
		max: 100 
		category: "2. Traîtres";
		
	parameter "Couleur" 
		var: color_traitres <- #red
		type: rgb 
		category: "2. Traîtres";
		
	parameter "Vitesse" 
		var: speed_traitres <- 1.0
		type: float 
		min: 0.1 
		max: 5.0 
		category: "2. Traîtres";
		
	parameter "Amplitude" 
		var: amplitude_traitres <- 40.0
		type: float 
		min: 1.0 
		max: 100.0 
		category: "2. Traîtres";


	// --- Cooperators (Coopérateurs) Parameters ---
	parameter "Nombre " 
		var: nb_cooperateurs <- 10
		type: int 
		min: 0 
		max: 100 
		category: "3. Coopérateurs";
		
	parameter "Couleur " 
		var: color_cooperateurs <- #blue
		type: rgb 
		category: "3. Coopérateurs";
		
	parameter "Vitesse " 
		var: speed_cooperateurs <- 1.0
		type: float 
		min: 0.1 
		max: 5.0 
		category: "3. Coopérateurs";
		
	parameter "Amplitude " 
		var: amplitude_cooperateurs <- 40.0
		type: float 
		min: 1.0 
		max: 100.0 
		category: "3. Coopérateurs";
}
