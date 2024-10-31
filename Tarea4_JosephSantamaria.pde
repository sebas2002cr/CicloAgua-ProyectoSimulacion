


//Simluacion del proceso de radiacion termica


Sol sol;
Nube nube;


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
ArrayList<Nube> nubes;


void setup() {
    size(800, 600, P3D);
    cam = new PeasyCam(this, 0, 0, 0, 2000);
    systems = new ArrayList();
    attractors = new ArrayList();
    nubes = new ArrayList();
    sol = new Sol(0, -600, 1000, 300, 1200, 3);
    heatMap = new boolean[40][40];

    // Crear nubes en posiciones fijas
    nubes.add(new Nube(-400, -300, 0, 0.5));
    nubes.add(new Nube(400, -300, 200, 0.5));
}


void draw() {
    blendMode(ADD);
    background(0);
    lights();
    stroke(255, 255, 255, 50);
    noFill();

    // Dibujar el piso y otros elementos
    for (int i = 0; i < 40; i++) {
        for (int j = 0; j < 40; j++) {
            if (heatMap[i][j]) {
                fill(255, 150, 0, 150);
            } else {
                fill(0, 0, 255);
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
        sol.affectAgents(systems, nubes);  // Llama a affectAgents con ambos parámetros
        sol.expandHeatZone();

        // Atraer agentes a las nubes cuando el sol esté activo
        for (Nube nube : nubes) {
            nube.display();
            nube.attractAgents(systems);
        }
    }

    // Actualizar y eliminar partículas que llegan a la nube
    for (int i = systems.size() - 1; i >= 0; i--) {
        AgentSystem3D s = systems.get(i);
        for (int j = s.agents.size() - 1; j >= 0; j--) {
            Agent3D agent = s.agents.get(j);
            agent.update();
            if (agent.checkCollisionWithNube()) {
                s.agents.remove(j);  // Eliminar agente al colisionar con la nube
            }
        }
        s.run();  // Corre el sistema de agentes
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
  
  
  if (key == ' ') {
    attractors.clear();
    systems.clear();
  }
} 
