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
	float distance_perception <- 5.0;
	int cooldown_duration <- 20;
	
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
	int cooldown <- 0 min: 0 max: cooldown_duration;
	bool can_duel <- true;
	list<prisonnier> adversaires_potentiels <- [];
	int points <- 0;
	
	reflex deplacement {
		write(heading);
		do wander amplitude: amplitude;
		adversaires_potentiels <- agents_at_distance(distance_perception) where (each is prisonnier);
		adversaires_potentiels <- adversaires_potentiels where (each.can_duel);
		cooldown <- cooldown - 1;
		can_duel <- cooldown = 0;
	}
	
	aspect base {
		float taille <- min(2.0, distance_perception);
		rgb color_used;
		if can_duel {color_used <- color;} else {color_used <- #black;}
		
		draw circle(distance_perception) color: rgb(color, 45);
		draw circle(taille) color: color_used;
	}
	
	reflex duel when: can_duel and length(adversaires_potentiels) > 0 {
		prisonnier adversaire <- adversaires_potentiels[0];
		if adversaire.location.x < self.location.x {
			return;
		}
		if adversaire.location.x = self.location.x {
			if adversaire.location.y < self.location.y {
				return;
			}
		}
		
		write(""+self+ " creates a duel");
		int random_choice <- rnd(2);
		prisonnier gagnant;
		prisonnier perdant;
		if random_choice = 0 {gagnant <- self; perdant <- adversaire;} else {gagnant <- adversaire; perdant <- self;}

        gagnant.points <- gagnant.points + 1;
        write(""+gagnant + " won against " + perdant);
        
        ask gagnant {heading <- heading - 90;}
        ask perdant {heading <- heading + 90;}
	        
	    cooldown <- cooldown_duration;
	    can_duel <- false;
	    ask adversaire {
	    	cooldown <- cooldown_duration;
	    	can_duel <- false;
	    }
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
		display main_display type:2d {
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

	parameter "Distance de perception" 
		var: distance_perception <- 5.0
		type: float 
		min: 0.1 
		max: 10.0 
		category: "1. Global Environment";
	
	parameter "Durée cooldown (nb de cycles)" 
		var: cooldown_duration <- 20
		type: int 
		min: 1 
		max: 20 
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
