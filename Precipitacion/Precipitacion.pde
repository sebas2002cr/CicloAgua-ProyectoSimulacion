import peasy.*;
import java.util.ArrayList;

PeasyCam cam;
ArrayList<Particle> raindrops;
PVector gravity = new PVector(0, 0.3, 0); // Gravedad que afecta las partículas hacia abajo
float groundLevel = 0; // Ajuste del nivel del terreno
int numParticles = 1000; // Número de partículas de lluvia (menos cantidad)
ArrayList<Cloud> clouds; // Arreglo de nubes
int numClouds = 5; // Número de nubes
float friction = 0.99; // Fricción para cuando las partículas "rueden" sobre el suelo
float[][] terrain; // Matriz para almacenar la altura del terreno
int terrainSize = 80; // Tamaño del terreno

void setup() {
  size(800, 600, P3D);
  cam = new PeasyCam(this, 1000); // Inicializar la cámara PeasyCam

  raindrops = new ArrayList<Particle>();
  clouds = new ArrayList<Cloud>();

  // Generar posiciones iniciales para las nubes (una sola vez)
  for (int i = 0; i < numClouds; i++) {
    clouds.add(new Cloud(new PVector(random(-300, 300), random(-300, -100), random(-300, 300))));
  }

  // Generar el terreno usando Perlin Noise
  terrain = new float[terrainSize][terrainSize];
  for (int x = 0; x < terrainSize; x++) {
    for (int z = 0; z < terrainSize; z++) {
      float noiseValue = noise(x * 0.1, z * 0.1);
      terrain[x][z] = map(noiseValue, 0, 1, -50, 50); // Ajuste de la altura del terreno
    }
  }
}

void draw() {
  background(0, 0, 0); // Fondo del cielo negro
  lights(); // Añadir luces a la escena

  // Dibujar terreno irregular
  drawTerrain();

  // Dibujar nubes
  for (Cloud cloud : clouds) {
    cloud.display();
    // Generar partículas de lluvia de forma equitativa entre las nubes
    if (raindrops.size() < numParticles) {
      // Generar solo 5 partículas por cada nube en cada frame
      for (int i = 0; i < 5; i++) {
        raindrops.add(new Particle(new PVector(cloud.pos.x + random(-30, 30), cloud.pos.y, cloud.pos.z + random(-30, 30))));
      }
    }
  }

  // Actualizar y mostrar partículas de lluvia
  for (int i = raindrops.size() - 1; i >= 0; i--) {
    Particle p = raindrops.get(i);
    p.applyForce(gravity); // Aplicar gravedad a cada partícula
    p.update();
    p.display();
    p.checkCollision(groundLevel); // Verificar colisión con el suelo

    // Eliminar la partícula si ha tocado el suelo
    if (p.isRemoved()) {
      raindrops.remove(i);
    }
  }
}

// Función para dibujar el terreno utilizando Perlin Noise
void drawTerrain() {
  fill(100, 200, 100); // Color verde para el terreno
  stroke(0);
  
  for (int x = 0; x < terrainSize - 1; x++) {
    for (int z = 0; z < terrainSize - 1; z++) {
      beginShape(TRIANGLES);
      
      PVector p1 = new PVector(x * 10 - terrainSize * 5, terrain[x][z], z * 10 - terrainSize * 5);
      PVector p2 = new PVector((x + 1) * 10 - terrainSize * 5, terrain[x + 1][z], z * 10 - terrainSize * 5);
      PVector p3 = new PVector(x * 10 - terrainSize * 5, terrain[x][z + 1], (z + 1) * 10 - terrainSize * 5);
      PVector p4 = new PVector((x + 1) * 10 - terrainSize * 5, terrain[x + 1][z + 1], (z + 1) * 10 - terrainSize * 5);
      
      vertex(p1.x, p1.y, p1.z);
      vertex(p2.x, p2.y, p2.z);
      vertex(p3.x, p3.y, p3.z);

      vertex(p2.x, p2.y, p2.z);
      vertex(p3.x, p3.y, p3.z);
      vertex(p4.x, p4.y, p4.z);
      
      endShape();
    }
  }
}

// Clase para las nubes realistas
class Cloud {
  PVector pos;
  ArrayList<PVector> cloudParts; // Partes que componen la nube

  Cloud(PVector startPos) {
    pos = startPos;
    cloudParts = new ArrayList<PVector>();

    // Generar las posiciones iniciales de las esferas que componen la nube
    for (int i = 0; i < 10; i++) {
      float offsetX = random(-20, 20);
      float offsetY = random(-10, 10);
      float offsetZ = random(-20, 20);
      cloudParts.add(new PVector(offsetX, offsetY, offsetZ));
    }
  }

  // Mostrar la nube
  void display() {
    fill(255);
    noStroke();
    pushMatrix();
    translate(pos.x, pos.y, pos.z);
    
    // Dibujar cada parte de la nube en su posición fija
    for (PVector part : cloudParts) {
      pushMatrix();
      translate(part.x, part.y, part.z);
      sphere(15); // Dibujar cada esfera de tamaño fijo
      popMatrix();
    }
    
    popMatrix();
  }
}

// Clase para las partículas de lluvia
class Particle {
  PVector pos;
  PVector vel;
  PVector acc;
  float mass;
  float restLength = 50; // Longitud de reposo del resorte
  float k = 0.08; // Aumentar la constante del resorte para un rebote más fuerte
  float damping = 0.7; // Reducir el damping para que el rebote sea más visible
  boolean atRest = false; // Para determinar si la partícula ya está en reposo
  boolean toRemove = false; // Marcar la partícula para eliminarla después del rebote

  Particle(PVector startPos) {
    pos = startPos.copy();
    vel = new PVector();
    acc = new PVector();
    mass = random(1, 3); // Masa aleatoria para las partículas
  }

  // Aplicar una fuerza a la partícula
  void applyForce(PVector force) {
    PVector f = force.copy();
    f.div(mass);
    acc.add(f);
  }

  // Actualizar la posición y la velocidad de la partícula
  void update() {
    if (!toRemove) {
      vel.add(acc);
      pos.add(vel);
    }
    acc.mult(0); // Resetear aceleración después de actualizar
  }

  // Mostrar la partícula de lluvia como una esfera
  void display() {
    fill(135, 206, 250); // Color celeste más marcado
    noStroke();
    pushMatrix();
    translate(pos.x, pos.y, pos.z);
    sphere(1); // Tamaño reducido de las partículas de lluvia
    popMatrix();
  }

  // Verificar colisión con el suelo y simular rebote con resortes
  void checkCollision(float ground) {
    if (pos.y >= ground && !toRemove) {
      float stretch = pos.y - ground;
      PVector springForce = new PVector(0, -k * stretch, 0); // Fuerza del resorte (más fuerte)
      applyForce(springForce);

      // Aplicar amortiguación para el rebote
      vel.y *= -1 * damping;

      // Marcar la partícula para eliminarla después de rebotar
      toRemove = true;
    }
  }

  // Función para verificar si la partícula debe ser eliminada
  boolean isRemoved() {
    return toRemove && pos.y >= groundLevel;
  }
}
