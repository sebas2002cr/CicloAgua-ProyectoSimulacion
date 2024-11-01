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
int numCloudCenters = 3; 

// Parámetros del terreno
int cols = 40; // Número de columnas
int rows = 40; // Número de filas
float noiseScale = 0.1; // Escala del ruido
float heightScale = 300; // Escala de altura del terreno

float waterLevel = 300; // Altura del agua

void setup() {
    size(800, 600, P3D);
    cam = new PeasyCam(this, 0, 0, 0, 2000);
    systems = new ArrayList();
    attractors = new ArrayList();
    nubes = new ArrayList();
    sol = new Sol(0, -600, 1000, 300, 1200, 3);
    
    heatMap = new boolean[40][40];

    // Crear centros de nube en posiciones aleatorias en el cielo
    cloudCenters = new ArrayList<>();
    for (int i = 0; i < numCloudCenters; i++) {
        float x = random(-600, 600);
        float y = random(-400, -200);  // Ubica las nubes en el "cielo"
        float z = random(-600, 600);
        cloudCenters.add(new PVector(x, y, z));
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
                agent.isActive = false;
            }
        }
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
        AgentSystem3D s = new AgentSystem3D(0, waterLevel, 0); // Cambia aquí también
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
