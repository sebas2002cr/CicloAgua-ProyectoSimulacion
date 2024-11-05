enum BorderBehaviour {
  NONE, WRAP, BOUNCE
}

class Agent3D {
  boolean isAffectedBySun = false;
  boolean isActive = false;
  PVector targetNube = null;
  PVector pos;
  PVector vel;
  PVector acc;
  color c;
  float maxSpeed;
  float mass;
  float massLoss;
  float angX;
  float angXVel;
  float angY;
  float angYVel;
  float angZ;
  float angZVel;
  boolean onFloor;
  boolean attracted;  
  boolean isDead;  
  float maxHeight = -300;
  float minHeight = -250;   


  float damp;
  
  //FLOCKING VARIABLES ----------
  float maxSteeringForce = 0.1;
  float arrivalRadius = 100;
  BorderBehaviour borderBehaviour;
  float wanderLookAhead = 50;
  float wanderRadius = 40;
  float wanderNoiseT;
  float wanderNoiseTInc = 0.001;

  float pathLookAhead = 50;
  float pathAhead = 50;

  float alignmentRadio = 80;
  float alignmentRatio = 1;

  float separationRadio = 30; 
  float separationRatio = 5;

  float cohesionRadio = 150;
  float cohesionRatio = 1;
  
  
  Agent3D(float x, float y, float z) {
    pos = new PVector(x, y, z);
    vel = new PVector(0, 0, 0);
    acc = new PVector(0, 0, 0);
    
    //COMPORTAMIENTOS PARA EL FLOCKING -------
    maxSteeringForce = 0.1;
    arrivalRadius = 100;
    wanderLookAhead = 50;
    wanderRadius = 40;
    wanderNoiseTInc = 0.001;
    pathLookAhead = 50;
    pathAhead = 50;
    alignmentRadio = 80;
    alignmentRatio = 1;
    separationRadio = 30; 
    separationRatio = 5;
    cohesionRadio = 150;
    cohesionRatio = 1;
    
    //COLOR BLANCO
    colorMode(RGB);
    c = color(255, 255, 255, 255); 

    
    maxSpeed = 5;
    mass = random(500, 800);
    massLoss = 0.8;
    angX = random(0, PI);
    angXVel = random(-0.2, 0.2);
    angY = random(0, PI);
    angYVel = random(-0.01, 0.01);
    angZ = random(0, PI);
    //angZVel = random(-0.1, 0.1);
    
    onFloor = false; 
    attracted = false;  
    isDead = false;  


  }
  
  private float r() {
    return pow(3 * mass / 4 / PI, 1.0/3.0);
  }
  boolean isDead() {
    return mass < 0.1;
  }
  
  
 void display() {
    if (!isDead) {  
      fill(c);
      noStroke();
      pushMatrix();
      translate(pos.x, pos.y, pos.z);
      box(r());
      popMatrix();
    }
  }
  
  
void update() {
    if (isActive) {
        if (pos.y > maxHeight) {
            PVector upwardForce = new PVector(0, -0.000001, 0); 
            applyForce(upwardForce);
        } else {
            vel.y = 0;  
            acc.y = 0;
            isActive = false;  
        }
    }

    vel.add(acc);
    pos.add(vel);
    acc.mult(0);

    // Lógica adicional para las paredes y el comportamiento en el suelo
    if (pos.y >= 300) {
        onFloor = true;
        pos.y = 300;
    }

    // Amortiguación 
    float damp = 0.5;

    if (!onFloor && !attracted) {
        acc.add(new PVector(0, 0.001, 0)); 
    }

    if (onFloor && attracted) {
        PVector viento = new PVector(random(-0.6, 0.6), -0.5, random(-0.6, 0.6)); // Cambiar dirección del viento hacia arriba
        vel.add(viento);
    }

    if (pos.x <= -800 || pos.x >= 800) {
        vel.x *= -1;  
        pos.x = constrain(pos.x, -800, 800);  
    }

    if (pos.z <= -800 || pos.z >= 800) {
        vel.z *= -1;  
        pos.z = constrain(pos.z, -800, 800); 
    }

    float dragCoefficient = 0.01;
    PVector drag = vel.copy();
    drag.mult(-dragCoefficient); 
    acc.add(drag);

    vel.add(acc);
    pos.add(vel);

    if (pos.y >= 300) {
        onFloor = true;
        pos.y = 300; 

        // Viento natural
        PVector viento = new PVector(random(-0.6, 0.6), 0, random(-0.6, 0.6)); 
        vel.add(viento); 
    }

    acc.mult(0);    

    if (mass < 0.1) {
        mass = 0.1; 
    }
    
    if (pos.y < maxHeight) {
    pos.y = maxHeight;
    vel.y = 0;  
}

}

void setAffectedBySun(boolean affected) {
    isAffectedBySun = affected;
    isActive = affected;
  }


    void attract() {
        // Obtener el attractor más cercano (si existe)
        Attractor closestAttractor = getClosestAttractor();
        if (closestAttractor != null) {
            PVector r = PVector.sub(closestAttractor.pos, pos);
            float d2 = constrain(r.magSq(), 1, 2000);  
            r.normalize();
            r.mult(closestAttractor.g * closestAttractor.mass * mass / d2);  // Ley de gravedad simplificada
            applyForce(r);
            attracted = true;
        }
    }


// Verificar colisión con la nube y eliminar partícula
boolean checkCollisionWithNube() {
    if (isActive && targetNube != null) {
        float distanceToNube = PVector.dist(pos, targetNube);
        if (distanceToNube < 10) {
            return true;   
        }
    }
    return false;
}

// Obtener el attractor más cercano
    Attractor getClosestAttractor() {
        float minDist = Float.MAX_VALUE;
        Attractor closest = null;

        for (Attractor attractor : attractors) {
            float dist = PVector.dist(pos, attractor.pos);
            if (dist < minDist) {
                minDist = dist;
                closest = attractor;
            }
        }

        return closest;
    }

void applyForce(PVector f) { 
    acc.add(f);  
}



//FLOCKING -------------
boolean debug = false;
void align(ArrayList<Agent3D> agents) {
  
  
    PVector result = new PVector(0, 0, 0);
    int n = 0;
    for (Agent3D a : agents) {
        if (this != a && pos.dist(a.pos) < alignmentRadio) {
            result.add(a.vel);
            n++;
        }
    }
    if (n > 0) {
        result.div(n);
        result.setMag(alignmentRatio);
        result.limit(maxSteeringForce);
        applyForce(result);
    }
}

void separate(ArrayList<Agent3D> agents) {
    PVector result = new PVector(0, 0, 0);
    int n = 0;
    for (Agent3D a : agents) {
        if (this != a && pos.dist(a.pos) < separationRadio) {
            PVector dif = PVector.sub(pos, a.pos);
            dif.normalize();
            dif.div(pos.dist(a.pos));
            result.add(dif);
            n++;
        }
    }
    if (n > 0) {
        result.div(n);
        result.setMag(separationRatio);
        result.limit(maxSteeringForce);
        applyForce(result);
    }
}

void cohere(ArrayList<Agent3D> agents) {
    PVector result = new PVector(0, 0, 0);
    int n = 0;
    for (Agent3D a : agents) {
        if (this != a && pos.dist(a.pos) < cohesionRadio) {
            result.add(a.pos);
            n++;
        }
    }
    if (n > 0) {
        result.div(n);
        PVector dif = PVector.sub(result, pos);
        dif.setMag(cohesionRatio);
        dif.limit(maxSteeringForce);
        applyForce(dif);
    }
}
}
