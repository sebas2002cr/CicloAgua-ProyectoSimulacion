class Agent3D {
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

  
  
  Agent3D(float x, float y, float z) {
    pos = new PVector(x, y, z);
    vel = new PVector(0, 0, 0);
    acc = new PVector(0, 0, 0);
    
    
    
    //COLOR BLANCO
    
    colorMode(RGB);
    c = color(255, 255, 255, 255); 

    
    maxSpeed = 20;
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
  
    if (isActive && targetNube != null) {  // Solo las partículas activas suben
        PVector directionToNube = PVector.sub(targetNube, pos).normalize().mult(0.5);
        applyForce(directionToNube);

        // Verifica si la partícula está suficientemente cerca de su posición en la nube
        float distanceToNube = PVector.dist(pos, targetNube);
        if (distanceToNube < 5) {
            vel.set(0, 0, 0);  // Detener la partícula completamente
            acc.set(0, 0, 0);
            isActive = false;  // Marcarla como estacionaria en su posición
        }
    }

    // Actualizar posición y velocidad
    vel.add(acc);
    pos.add(vel);
    acc.mult(0);
    
    //Amortiguación 
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

        
        //PUSE UN VIENTO PARA QUE FUESE MAS NATURAL 

        PVector viento = new PVector(random(-0.6, 0.6), 0, random(-0.6, 0.6)); 
        vel.add(viento); 
    }

    acc.mult(0);    
    

    
    if (mass < 0.1) {
        mass = 0.1; 
    }
}


// Verificar colisión con la nube y eliminar partícula
boolean checkCollisionWithNube() {
    if (isActive && targetNube != null) {
        float distanceToNube = PVector.dist(pos, targetNube);
        if (distanceToNube < 10) {
            return true;  // Señala que la partícula 
        }
    }
    return false;
}

void applyForce(PVector f) {
  
  if (onFloor || attracted) {
    
    PVector force = PVector.div(f, mass);  
    acc.add(force);  
  }
}


}
