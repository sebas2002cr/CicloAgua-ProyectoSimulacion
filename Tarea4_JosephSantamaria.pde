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

// Parámetros del terreno
int cols = 40; // Número de columnas
int rows = 40; // Número de filas
float noiseScale = 0.1; // Escala del ruido
float heightScale = 300; // Escala de altura del terreno

float waterLevel = 300; // Altura del agua

ArrayList<PVector> cloudVelocities; 
int numCloudCenters = 3; 
boolean isPrecipitating = false;

void setup() {
    size(800, 600, P3D);
    cam = new PeasyCam(this, 0, 0, 0, 2000);
    systems = new ArrayList();
    attractors = new ArrayList();
    nubes = new ArrayList();

    sol = new Sol(0, -600, 1000, 300, 1200, 3);
    heatMap = new boolean[40][40];

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
    background(135, 206, 235); // color del cielo
    lights();
    translate(0, 0, 0); 

    noStroke();

    for (int r = 0; r < rows - 1; r++) {
        beginShape(TRIANGLE_STRIP);
        for (int c = 0; c < cols; c++) {
            // Determinar la zona del terreno
            float currentNoiseScale;
            float currentHeightScale;

            // Se divide en 3 zonas 
            if (c < cols / 3) { // zona 1
                currentNoiseScale = 0.3; // escala menor para montañas suaves
                currentHeightScale = 120;   // menor altura
            } else if (c < 2 * cols / 3) { // zona 2
                currentNoiseScale = 0.8; // escala media
                currentHeightScale = 140;   // altura media
            } else { // zona 3
                currentNoiseScale = 1.0; // escala mayor para montañas suaves
                currentHeightScale = 180;  // mayor altura
            }

            // Generamos alturas usando ruido de Perlin
            float y1 = map(noise(c * currentNoiseScale, r * currentNoiseScale), 0, 1, 0, currentHeightScale);
            float y2 = map(noise(c * currentNoiseScale, (r + 1) * currentNoiseScale), 0, 1, 0, currentHeightScale);
            
            // Gradiente de color para simular el terreno
            float t = map(y1, 0, heightScale, 0, 1);
            color terrainColor = lerpColor(color(34, 139, 34), color(139, 69, 19), t); // verde a café
            fill(terrainColor);
            
            // Dibujar los vértices del terreno
            float x = map(c, 0, cols - 1, -800, 800);
            float z = map(r, 0, rows - 1, -800, 800);
            vertex(x, 350 - y1, z); // Elevar el terreno debajo del nivel del agua
            vertex(x, 350 - y2, z + (1600 / (rows - 1))); // 1600 porque el área es de -800 a 800
        }
        endShape();
    }

    // Dibujar el agua
    fill(0, 0, 255, 150); // Color del agua
    noStroke();
    beginShape(QUADS);
    vertex(-800, waterLevel, -800);
    vertex(800, waterLevel, -800);
    vertex(800, waterLevel, 800);
    vertex(-800, waterLevel, 800);
    endShape();
    
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
