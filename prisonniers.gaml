/**
* Name: prisonniers
* Based on the internal skeleton template. 
* Author: Utilisateur
* Tags: 
*/

model prisonniers

global {
	/** Insert the global definitions, variables and actions here */
	string COOPERATEURS <- "cooperateurs";
	string TRAITRES <- "traitres";
	list<string> strategies <- [COOPERATEURS, TRAITRES];
	
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
	
	map<string, rgb> color_par_strategie <- [
		TRAITRES::color_traitres,
		COOPERATEURS::color_cooperateurs
	];
	
	int nb_duels;
	
	map<string, map> metrics <- [
		TRAITRES:: [
			"points"::0,
			"nb_duels"::0,
			"gain_moyen"::0.0
		],
		COOPERATEURS:: [
			"points"::0,
			"nb_duels"::0,
			"gain_moyen"::0.0
		]
	];
	
	geometry shape <- square(taille_carre);

	reflex compute_metrics {
		nb_duels <- 0;	
		loop classe over: strategies {
			metrics[classe]['gain_moyen'] <- (int(metrics[classe]['nb_duels']) > 0) ? 
			    int(metrics[classe]['points']) / int(metrics[classe]['nb_duels']) : 
			    0;
			nb_duels <- nb_duels + int(metrics[classe]['nb_duels']);
		}		
		
		if nb_duels >= 2000 {
			do pause;
		}
	}
	
	init {
		create traitre number:nb_traitres;
		create cooperateur number:nb_cooperateurs;
	}
}

species prisonnier skills: [moving] {
	string classe;
	rgb color;
	float amplitude <- 30.0;
	int cooldown <- 0 min: 0 max: cooldown_duration;
	bool can_duel <- true;
	list<prisonnier> adversaires_potentiels <- [];
	int points <- 0;
		
	aspect base {
		float taille <- min(2.0, distance_perception);
		rgb color_used;
		if can_duel {color_used <- color;} else {color_used <- #black;}
		
		draw circle(distance_perception) color: rgb(color, 45);
		draw circle(taille) color: color_used;
	}
	
	reflex deplacement {
		do wander amplitude: amplitude;
		adversaires_potentiels <- agents_at_distance(distance_perception);
		adversaires_potentiels <- adversaires_potentiels where (each.can_duel);
		cooldown <- cooldown - 1;
		can_duel <- cooldown = 0;
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
	        
	    do duel_with(adversaire);
	    
	    cooldown <- cooldown_duration;
	    can_duel <- false;
	    ask adversaire {
	    	cooldown <- cooldown_duration;
	    	can_duel <- false;
	    }
	}
	
	action duel_with(prisonnier adversaire) {
		bool self_coopere <- true; 
        bool adversaire_coopere <- true;
        int gain_self <- 0;
        int gain_adversaire <- 0;
        
        // strategies
        if self is traitre {self_coopere <- false;}
        
        if adversaire is traitre {adversaire_coopere <- false;}
        
        // résultats
        if self_coopere and adversaire_coopere {
        	gain_self <- 3;
        	gain_adversaire <- 3;
        }
        if self_coopere and not adversaire_coopere {
        	gain_adversaire <- 5;
        }
        if not self_coopere and adversaire_coopere {
        	gain_self <- 5;
        }
        self.points <- self.points + gain_self;
        adversaire.points <- adversaire.points + gain_adversaire;
        
        // mise à jour des metrics
        metrics[self.classe]['points'] <- int(metrics[self.classe]['points']) + gain_self;
        metrics[self.classe]['nb_duels'] <- int(metrics[self.classe]['nb_duels']) + 1;
        
        metrics[adversaire.classe]['points'] <- int(metrics[adversaire.classe]['points']) + gain_adversaire;
        metrics[adversaire.classe]['nb_duels'] <- int(metrics[adversaire.classe]['nb_duels']) + 1;
	}
}

species traitre parent: prisonnier {
	init {
		classe <- TRAITRES;
		color <- color_traitres;
		speed <- speed_traitres;
		amplitude <- amplitude_traitres;
	}
}

species cooperateur parent: prisonnier {
	init {
		classe <- COOPERATEURS;
		color <- color_cooperateurs;
		speed <- speed_cooperateurs;
		amplitude <- amplitude_cooperateurs;
	}
}

experiment prisonniers type: gui {
	/** Insert here the definition of the input and output of the model */
	float minimum_cycle_duration <- 0.005#s;
	
	output {
		display main_display type: 2d {
			species traitre aspect: base;
			species cooperateur aspect: base;
		}
		
		monitor "nombre de duels" value: nb_duels refresh: every(1#cycle);
		monitor "nombre de duels (traitres)" value: int(metrics['traitres']['nb_duels']) refresh: every(1#cycle);
		monitor "nombre de duels (coopérateurs)" value: int(metrics['cooperateurs']['nb_duels']) refresh: every(1#cycle);
		
		display line_chart type: 2d {
			chart "gain moyen par duel" type: series {
				loop classe over: strategies {
					data classe value: float(metrics[classe]['gain_moyen']) color: color_par_strategie[classe] marker: false;
				}
			}
		}
		
		display pie_chart type: 2d {
			chart "points par classe" type: pie {
				loop classe over: strategies {
					data classe value: int(metrics[classe]['points']) color: color_par_strategie[classe];
				}
			}
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
