Sol sol;
Nube nube;

ArrayList<Nube> nubes;
boolean generatingAgents = true;
boolean isRaining = false;
import peasy.*;

PeasyCam cam;
boolean solActive = false;  
boolean[][] heatMap;  
int currentI = -1, currentJ = -1;  
int lastChangeTime = 0;  
int zoneSize = 5; 
ArrayList<AgentSystem3D> systems;
ArrayList<Attractor> attractors;
ArrayList<PVector> cloudCenters; 
ArrayList<PVector> cloudVelocities; 
int numCloudCenters = 3; 

boolean showStatistics = false;

int cols = 40; 
int rows = 40; 
float noiseScale = 0.1; 
float heightScale = 300; 

float waterLevel = 280; 
float[][] waterLevels; 





void setup() {
    size(800, 600, P3D);
    cam = new PeasyCam(this, 0, 0, 0, 2000);
  
    attractors = new ArrayList();
    sol = new Sol(800, -600, 1000, 400, 2500, 15);
    heatMap = new boolean[40][40];
    float[][] waterTransparency = new float[rows][cols];

    
    waterLevels = new float[rows][cols]; 

    
    systems = new ArrayList<AgentSystem3D>();
    
    //systems.add(new AgentSystem3D(0, 300, 0)); 
   
    // Inicializar velocidades de los centros de nube
    cloudVelocities = new ArrayList<>();
    for (int i = 0; i < numCloudCenters; i++) {
        float vx = random(-1, 1);
        float vy = 0;  // Mantén las nubes en el mismo plano
        float vz = random(-1, 1);
        cloudVelocities.add(new PVector(vx, vy, vz));
    }
    
    for (int r = 0; r < rows; r++) {
    for (int c = 0; c < cols; c++) {
        waterLevels[r][c] = waterLevel;  
        waterTransparency[r][c] = 255;   
    }
}

}


void draw() {
    background(135, 206, 235); 
    lights();
    translate(0, 0, 0); 
    noStroke();
    
    float[][] terrainHeights = new float[rows][cols]; 


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
            
            int i = int(map(c, 0, cols - 1, 0, 39));
            int j = int(map(r, 0, rows - 1, 0, 39));

            if (heatMap[i][j]) {
                float t = map(y1, 0, heightScale, 0, 1);
                color terrainColor = lerpColor(color(34, 139, 34), color(255, 223, 0), t); // verde a amarillo
                fill(terrainColor);
            } else {

              float t = map(y1, 0, heightScale, 0, 1);
                color terrainColor = lerpColor(color(34, 139, 34), color(139, 69, 19), t); // verde a café
                fill(terrainColor);
            }

            // Dibujar los vértices del terreno
            float x = map(c, 0, cols - 1, -800, 800);
            float z = map(r, 0, rows - 1, -800, 800);
            vertex(x, 350 - y1, z); // Elevar el terreno debajo del nivel del agua
            vertex(x, 350 - y2, z + (1600 / (rows - 1))); // 1600 porque el área es de -800 a 800
            terrainHeights[r][c] = 350 - y1;  // Guardar la altura del terreno

      
    
  }
        endShape();
    }
    
    float cellOffsetX = (1600 / (cols - 1)) / 2 * 1.05;  // Multiplicar por 1.05 para que se solapen
    float cellOffsetZ = (1600 / (rows - 1)) / 2 * 1.05;

    // Dibujar el agua como un plano continuo celda por celda, asegurando que no esté bajo el terreno
    fill(0, 0, 255, 150); // Color del agua
    noStroke();

    for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
            float x = map(c, 0, cols - 1, -800, 800);
            float z = map(r, 0, rows - 1, -800, 800);
            
            float terrainHeight = terrainHeights[r][c]; // Obtener la altura del terreno
            float currentWaterLevel = waterLevels[r][c]; // Obtener el nivel actual del agua

            if (currentWaterLevel  < terrainHeight) {
                // Dibujar agua solo si el nivel del agua está por encima del terreno en esa celda
                beginShape(QUADS);
                vertex(x - cellOffsetX, currentWaterLevel, z - cellOffsetZ);
                vertex(x + cellOffsetX, currentWaterLevel, z - cellOffsetZ);
                vertex(x + cellOffsetX, currentWaterLevel, z + cellOffsetZ);
                vertex(x - cellOffsetX, currentWaterLevel, z + cellOffsetZ);
                endShape();
            }
        }
    }

    fill(100, 100, 100, 150);
    drawWalls();

    // Control de precipitación (caída de partículas)
    //if (isPrecipitating) {
      //precipitateParticles();
    //}

if (solActive) {
    sol.display();
    sol.affectAgents(systems);
    sol.expandHeatZone(terrainHeights, waterLevels);
  } else if (isRaining) {
    precipitateParticles();  
  } else if (!solActive) {
    sol.reduceHeatZone(); // Enfriamiento cuando el sol está apagado
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
        s.run();  
    }
    
      if (showStatistics) {
        displayStatistics();
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

//LLUVIA---------------------------------------------------
void precipitateParticles() {
    for (int i = systems.size() - 1; i >= 0; i--) {
        AgentSystem3D s = systems.get(i);
        for (int j = s.agents.size() - 1; j >= 0; j--) {
            Agent3D agent = s.agents.get(j);
            
            // si la partícula ya está en la nube y no está activa, hazla caer
            if (!agent.isActive && agent.pos.y > 300) {  // comienza a caer solo si está sobre el suelo
                PVector gravity = new PVector(0, 0.2, 0);  // gravedad aumentada para caída más rápida
                agent.applyForce(gravity);

                // detén la partícula al llegar al suelo
                if (agent.pos.y >= 300) {
                    agent.pos.y = 300;  // asegura que esté en el suelo
                    agent.vel.set(0, 0, 0);  // detén la velocidad
                }
            }
        }
    }
}


void displayStatistics() {
  
  
    float heatPercentage = sol.calculateHeatPercentage();
    
    fill(0);  
    
    textSize(16);
    
    textAlign(LEFT);
    
    text("Estadísticas de Terreno", 20, -200);
    
    text("Terreno Calentado: " + nf(heatPercentage, 1, 2) + "%", 20,  -170);
    
    float barWidth = 200;  
    float barHeight = 20;  
    float filledWidth = map(heatPercentage, 0, 100, 0, barWidth);  

    noFill();
    stroke(0);
    rect(20, -150, barWidth, barHeight);

    noStroke();
    fill(255, 165, 0);  
    rect(20, -150, filledWidth, barHeight);
}


void colocarAgua() {
    for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
            waterLevels[r][c] = waterLevel;
        }
    }
}

//MUROS DE LA CAJA --------------
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


//TECLAS ------------------------------
void keyPressed() {
  if (key == 's') {
    AgentSystem3D s = new AgentSystem3D(0, 300, 0);
    systems.add(s);
  }
  
  if (key == 'w' || key == 'W') {
        colocarAgua();
    }
  
  if (key == 't') {  // 't' para encender o apagar el sol
    sol.toggleSun();
  }
    
  if (key == 'x') {
    solActive = !solActive;  
  }
  
  if (key == 'p' || key == 'P') {
    isRaining = !isRaining; // Activa o desactiva la lluvia
  }
    
  if (key == 'g') {
    generatingAgents = !generatingAgents;  
  }
  
  if (key == ' ') {
    attractors.clear();
    systems.clear();
  }
  
  if (key == 'i' || key == 'I') {  
        showStatistics = !showStatistics;
    }
    
  
}  
