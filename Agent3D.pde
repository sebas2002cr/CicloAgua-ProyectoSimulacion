enum BorderBehaviour {
  NONE, WRAP, BOUNCE
}

class Agent3D {
  boolean isAffectedBySun = false;
  boolean isActive = false;
  boolean isFalling = false;
  PVector targetNube = null;
  boolean isReadyToFall = false;  
  float timeSinceActivated = 0; 
  PVector pos;
  PVector vel;
  PVector acc;
  color c;
  float mass;
  float massLoss;
  float angX;
  float angXVel;
  
  
  boolean isResting = false;  
  int restStartTime = 0;        
  int restDuration = 5000;      
  
  float angY;
  float angYVel;
  float angZ;
  float angZVel;
  boolean onFloor;
  boolean attracted;  
  boolean isDead;  
  float maxHeight = -300;
  float minHeight = -250;   
  boolean isRaining = false;
  float topHeight = -200; 

  float damp;
  float maxSpeed = 0.005;

  float maxSteeringForce = 0.005;
  float arrivalRadius = 100;
  BorderBehaviour borderBehaviour;


  float alignmentRadio = 80;
  float alignmentRatio = 0.2;

  float separationRadio = 15; 
  float separationRatio = 1.0;

  float cohesionRadio = 180;
  float cohesionRatio = 4;
  
  float fallDelay;
    int lastFallAttempt;
    
  Agent3D(float x, float y, float z) {
    
    
    
    pos = new PVector(x, y, z);
    vel = new PVector(0, 0, 0);
    acc = new PVector(0, 0, 0);
    
    colorMode(RGB);
    c = color(255, 255, 255, 255); 
    
    
    fallDelay = random(2000, 8000);
    lastFallAttempt = millis() + int(random(-1000, 1000)); 

    mass = random(500, 800);
    massLoss = 0.8;
    angX = random(0, PI);
    angXVel = random(-0.2, 0.2);
    angY = random(0, PI);
    angYVel = random(-0.01, 0.01);
    angZ = random(0, PI);
    
    onFloor = false; 
    attracted = false;  
    isDead = false;  
    fallDelay = random(3000, 8000);
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
      translate(pos.x, pos.y+25, pos.z);
      box(r());
      popMatrix();
    }
  }
  
  void update() {
    
      if (isResting) {
        if (millis() - restStartTime >= restDuration) {
            isResting = false;  
        }
        return;
    }
    
    
    
    if (isActive) {
        if (pos.y > maxHeight) {
            PVector upwardForce = new PVector(0, 0.00001, 0);
            applyForce(upwardForce);
        } else {
            vel.y = 0;
            acc.y = 0;
            isActive = false;
            isFalling = false;
            timeSinceActivated = millis();
        }
    }

    if (isFalling && !isReadyToFall && isRaining) {
        if (millis() - timeSinceActivated >= fallDelay) {
            isReadyToFall = true;
        }
    }

    if (isReadyToFall && isRaining) {
        applyGravity();
    }
    
    if (isFalling) {
    applyGravity();
    if (vel.mag() < 0.1) {
        vel.y = 0.05; 
    }
}


    if (pos.y >= 300) {
        pos.y = 300;
        isFalling = false;
        isReadyToFall = false;
        onFloor = true; // Marcar que está en el suelo

        int col = int(map(pos.x, -800, 800, 0, cols - 1));
        int row = int(map(pos.z, -800, 800, 0, rows - 1));

        int agentesEnElMismoLugar = contarAgentesEnCelda(row, col); 
        generarCuerpoDeAgua(row, col, agentesEnElMismoLugar);


        vel = new PVector(0, 0, 0);
    }

    vel.add(acc);
    pos.add(vel);
    acc.mult(0);
    
  
    
    float damp = 0.5;

    if (!onFloor && !attracted) {
        acc.add(new PVector(0, 0.001, 0));
    }

    if (onFloor && attracted) {
        PVector viento = new PVector(random(-0.6, 0.6), -0.5, random(-0.6, 0.6)); 
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
        isFalling = false; 
        isReadyToFall = false;

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
  
    boolean isEligibleToFall() {
        if (millis() - lastFallAttempt >= fallDelay) {
            lastFallAttempt = millis() + int(random(-1000, 1000)); 
            return true;
        }
        return false;
    }


  void setAffectedBySun(boolean affected) {
    isAffectedBySun = affected;
    isActive = affected;
  }

  void attract() {
    Attractor closestAttractor = getClosestAttractor();
    if (closestAttractor != null) {
      PVector r = PVector.sub(closestAttractor.pos, pos);
      float d2 = constrain(r.magSq(), 1, 2000);  
      r.normalize();
      r.mult(closestAttractor.g * closestAttractor.mass * mass / d2);  
      applyForce(r);
      attracted = true;
    }
  }

  boolean checkCollisionWithNube() {
    if (isActive && targetNube != null) {
      float distanceToNube = PVector.dist(pos, targetNube);
      if (distanceToNube < 10) {
        isActive = false;  
        isFalling = true;
        return true;   
      }
    }
    return false;
  }

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

  void applyGravity() {
    PVector gravity = new PVector(0, 0.05, 0); 
    applyForce(gravity);
  }

  void applyForce(PVector f) { 
    acc.add(f);  
  }

  // FLOCKING -------------
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
  
void generarCuerpoDeAgua(int row, int col, int agentesEnElMismoLugar) {
    if (row >= 0 && row < rows && col >= 0 && col < cols) {
        int baseRadius = 3;
        int radius = baseRadius + (int)map(agentesEnElMismoLugar, 1, 30, 0, 5); 
        
        for (int i = -radius; i <= radius; i++) {
            for (int j = -radius; j <= radius; j++) {
                int neighborRow = row + i;
                int neighborCol = col + j;

                if (neighborRow >= 0 && neighborRow < rows && neighborCol >= 0 && neighborCol < cols) {
                    float distance = dist(row, col, neighborRow, neighborCol);

                    if (distance <= radius) {
                        float impacto = max((float)agentesEnElMismoLugar / (distance + 4), 0.001); 

                        float adjustedImpacto = impacto / (distance + 3);

                        waterLevels[neighborRow][neighborCol] = lerp(
                            waterLevels[neighborRow][neighborCol],
                            max(waterLevels[neighborRow][neighborCol] - adjustedImpacto, waterLevel),
                            0.8
                        );
                    }
                }
            }
        }
    }
}

  int contarAgentesEnCelda(int row, int col) {
      int count = 0;
      for (AgentSystem3D system : systems) { 
          for (Agent3D agent : system.agents) {
              int agentRow = int(map(agent.pos.z, -800, 800, 0, rows - 1));
              int agentCol = int(map(agent.pos.x, -800, 800, 0, cols - 1));
              
              if (agentRow == row && agentCol == col) {
                  count++;
              }
          }
      }
      return count;
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
