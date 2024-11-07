class Attractor {
  PVector pos;
  float mass;
  float g;
  ArrayList<AgentSystem3D> systems;
  float noiseOffsetX, noiseOffsetY, noiseOffsetZ; 

  Attractor(float x, float y, float z, float mass) {
    pos = new PVector(x, y, z);
    this.mass = mass;
    systems = new ArrayList();
    g = 0.05;  
    noiseOffsetX = random(1000);
    noiseOffsetY = random(1000);
    noiseOffsetZ = random(1000);
  }

  void addSystem(AgentSystem3D s) {
    systems.add(s);
  }

  void update() {
    
    float noiseSpeed = 0.01; 
    
    pos.x += map(noise(noiseOffsetX), 0, 1, -2, 2); 
    pos.y += map(noise(noiseOffsetY), 0, 1, -2, 2);
    pos.z += map(noise(noiseOffsetZ), 0, 1, -2, 2);

    noiseOffsetX += noiseSpeed;
    noiseOffsetY += noiseSpeed;
    noiseOffsetZ += noiseSpeed;

    pos.x = constrain(pos.x, -800, 800);
    pos.y = constrain(pos.y, -300, 300);
    pos.z = constrain(pos.z, -800, 800);

    
    for (AgentSystem3D s : systems) {
      for (Agent3D a : s.agents) {
        if (!a.onFloor) {  
          PVector r = PVector.sub(pos, a.pos);
          float d2 = constrain(r.magSq(), 1, 2000);
          r.normalize();
          r.mult(g * mass * a.mass / d2);
          a.applyForce(r);
          a.attracted = true;  
        } else {
          a.attracted = false;  
        }
      }
    }
  }

void display() {
    noStroke();
    fill(121, 210, 230);  
    pushMatrix();
    translate(pos.x, pos.y, pos.z);
    sphere(mass / 10);  
    popMatrix();
    
    // Definir 5 colores pastel
    color[] pastelColors = {
        color(255, 182, 193),  // Rosa pastel
        color(255, 223, 186),  // Naranja pastel
        color(186, 255, 201),  // Verde pastel
        color(186, 225, 255),  // Azul pastel
        color(225, 186, 255)   // Morado pastel
    };
    
    int numSpots = 10;  
    for (int i = 0; i < numSpots; i++) {
        pushMatrix();
        float spotX = random(-mass / 10, mass / 10);
        float spotY = random(-mass / 10, mass / 10);
        float spotZ = random(-mass / 10, mass / 10);
        
        translate(pos.x + spotX, pos.y + spotY, pos.z + spotZ);
        
        fill(pastelColors[i % pastelColors.length]);
        
        sphere(mass / 50);  
        
        popMatrix();
    }
    
    fill(255);  
    textAlign(CENTER, CENTER);
    textSize(40);
    
    hint(DISABLE_DEPTH_TEST);
    pushMatrix();
    translate(pos.x, pos.y - mass / 5 - 50, pos.z);  
    text("E+T+H+C", 0, 0);  
    popMatrix();
    hint(ENABLE_DEPTH_TEST);
}

} //NO LO MODIFICO 
