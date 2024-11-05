


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
ArrayList<PVector> cloudCenters;  // Centros de nubes invisibles
ArrayList<PVector> cloudVelocities; 
int numCloudCenters = 3; 
boolean isPrecipitating = false;


void setup() {
    size(800, 600, P3D);
    cam = new PeasyCam(this, 0, 0, 0, 2000);
    systems = new ArrayList();
    attractors = new ArrayList();
    nubes = new ArrayList();
    sol = new Sol(0, -600, 1000, 300, 1200, 7);
    heatMap = new boolean[40][40];

    // Crear centros de nube en posiciones fijas
    cloudCenters = new ArrayList<>();
    cloudCenters.add(new PVector(-200, -300, -200));  // Centro de nube 1
    cloudCenters.add(new PVector(200, -300, 200));    // Centro de nube 2

    // Inicializar velocidades de los centros de nube
    cloudVelocities = new ArrayList<>();
    for (int i = 0; i < numCloudCenters; i++) {
        float vx = random(-1, 1);
        float vy = 0;  // Mantén las nubes en el mismo plano
        float vz = random(-1, 1);
        cloudVelocities.add(new PVector(vx, vy, vz));
    }
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
        sol.affectAgents(systems, cloudCenters);
        sol.expandHeatZone();
    } else if (isPrecipitating) {
        moveCloudCenters();  // Mueve las nubes lentamente
        precipitateParticles();  // Activa la precipitación de partículas
    }

    // Actualizar y detener partículas en la nube sin eliminarlas
    for (int i = systems.size() - 1; i >= 0; i--) {
        AgentSystem3D s = systems.get(i);
        for (int j = s.agents.size() - 1; j >= 0; j--) {
            Agent3D agent = s.agents.get(j);
            agent.update();
            
            if (agent.checkCollisionWithNube()) {
                agent.isActive = false; // Desactiva la partícula para que se mantenga en la nube
            }
        }
        s.run();  // Corre el sistema de agentes
    }
}

void moveCloudCenters() {
    for (int i = 0; i < cloudCenters.size(); i++) {
        PVector center = cloudCenters.get(i);
        PVector velocity = cloudVelocities.get(i).mult(0.1);  // Reducir velocidad para movimiento lento

        // Actualiza la posición del centro de nube
        center.add(velocity);

        // Verifica los límites y hace que la nube rebote
        if (center.x < -800 || center.x > 800) velocity.x *= -1;
        if (center.z < -800 || center.z > 800) velocity.z *= -1;
    }
}

void precipitateParticles() {
    for (int i = systems.size() - 1; i >= 0; i--) {
        AgentSystem3D s = systems.get(i);
        for (int j = s.agents.size() - 1; j >= 0; j--) {
            Agent3D agent = s.agents.get(j);
            
            // Si la partícula ya está en la nube y no está activa, hazla caer
            if (!agent.isActive && agent.pos.y > 300) {  // Comienza a caer solo si está sobre el suelo
                PVector gravity = new PVector(0, 0.2, 0);  // Gravedad aumentada para caída más rápida
                agent.applyForce(gravity);

                // Detén la partícula al llegar al suelo
                if (agent.pos.y >= 300) {
                    agent.pos.y = 300;  // Asegura que esté en el suelo
                    agent.vel.set(0, 0, 0);  // Detén la velocidad
                }
            }
        }
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
  
  if (key == 't') {  // Presiona 't' para encender o apagar el sol
        sol.toggleSun();
    }
    
  if (key == 'x') {
    solActive = !solActive;  
  }
  
  
    
if (key == 'p' && !sol.isActive) {  // Activar precipitación solo cuando el sol esté apagado
        isPrecipitating = !isPrecipitating;
    }
    
    
    
   if (key == 'g') {
    generatingAgents = !generatingAgents;  
  }
  
  
  if (key == ' ') {
    attractors.clear();
    systems.clear();
  }
} 
