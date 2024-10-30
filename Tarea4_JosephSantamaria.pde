


//Simluacion del proceso de radiacion termica


Sol sol;

import peasy.*;

PeasyCam cam;
boolean generatingAgents = true;  
boolean solActive = false;  
boolean[][] heatMap;  
int currentI = -1, currentJ = -1;  
int lastChangeTime = 0;  
int zoneSize = 5; 
ArrayList<AgentSystem3D> systems;
ArrayList<Attractor> attractors;

void setup() {
  
  size(800, 600, P3D);
  cam = new PeasyCam(this, 0, 0, 0, 2000);
  systems = new ArrayList();
  attractors = new ArrayList();
  sol = new Sol(0, -600, 1000, 300, 1200, 0.5);  
  heatMap = new boolean[40][40];  //PISO EN FORMA DE CUADRICULA


}

void draw() {
  blendMode(ADD);
  background(0);
  lights();
  stroke(255, 255, 255, 50);
  noFill();
  
  // SE DIBUJA EL PISO
  
  for (int i = 0; i < 40; i++) {
    
    for (int j = 0; j < 40; j++) {
      
      if (heatMap[i][j]) {
        
        fill(255, 150, 0, 150);  // Color naranja  para las zonas hot
      } else {
        fill(0, 0, 255);  // Color azul para las zonas chill
      }
      float x = map(i, 0, 39, -800, 800);
      float z = map(j, 0, 39, -800, 800);
      beginShape(QUADS); 
      vertex(x, 300, z); 
      vertex(x + 40, 300, z);  
      vertex(x + 40, 300, z + 40);   
      vertex(x, 300, z + 40);  
      endShape();
    }
  }

  fill(100, 100, 100, 150); 
  drawWalls();  

  if (solActive) {
    sol.display();
    sol.affectAgents(systems);  

    if (millis() - lastChangeTime > 30000) {
      sol.chooseNewZone();  
      lastChangeTime = millis();  
    }
  }
  
  for (Attractor at : attractors) {
    at.display();
    at.update();
  }
  for (AgentSystem3D s : systems) {
    s.run();
  }
}

void drawWalls() {
  
  beginShape(QUADS);
  vertex(-800, 300, -800); 
  vertex(800, 300, -800);
  vertex(800, -300, -800); 
  vertex(-800, -300, -800);
  endShape();
  
  beginShape(QUADS);
  vertex(-800, 300, 800); 
  vertex(800, 300, 800);
  vertex(800, -300, 800); 
  vertex(-800, -300, 800);
  endShape();
  
  beginShape(QUADS);
  vertex(-800, 300, -800); 
  vertex(-800, 300, 800);
  vertex(-800, -300, 800); 
  vertex(-800, -300, -800);
  endShape();
  
  beginShape(QUADS);
  vertex(800, 300, -800); 
  vertex(800, 300, 800);
  vertex(800, -300, 800); 
  vertex(800, -300, -800);
  endShape();
}
void keyPressed() {
  
  
  if (key == 's') {
    
    AgentSystem3D s = new AgentSystem3D(
      0,   
      300, 
      0   
    );

    systems.add(s);
  }
  if (key == 'x') {
    solActive = !solActive;  
  }
  
  
    

    
    
    
   if (key == 'g') {
    generatingAgents = !generatingAgents;  
  }
   
  
    
  
  
  
  
   if (key == 'a') {
    Attractor at = new Attractor(0, -1000, 0, 500);  
    attractors.add(at);
    for (AgentSystem3D s : systems) {
      at.addSystem(s);
    }
  }
  
  if (key == ' ') {
    attractors.clear();
    systems.clear();
  }
} 
