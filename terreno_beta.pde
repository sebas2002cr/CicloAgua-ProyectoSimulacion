import peasy.PeasyCam;

PeasyCam cam;
int cols = 400; //número de columnas
int rows = 400; //número de filas
float sizeTerrain; //tamanho del terreno
float noiseScale = 0.06; //ruido
float heightScale = 150; //altura del terreno

void setup() {
  size(800, 600, P3D);
  cam = new PeasyCam(this, 0, 100, 0, 1100);
  cam.rotateX(PI); //esto es para voltear la camara, si da problema eliminar y poner negativa la altura en la creacion del terreno
  sizeTerrain = width / rows;
}

void draw() {
  background(135, 206, 235); //color del cielo
  lights();
  translate(-width / 2, -height / 2); 

  noStroke();
  
  for (int r = 0; r < rows - 1; r++) {
    beginShape(TRIANGLE_STRIP);
    for (int c = 0; c < cols; c++) {
      //determinar la zona del terreno
      float currentNoiseScale = noiseScale;
      float currentHeightScale = heightScale;
      
      //se divide en 3 zonas 
      if (c < cols / 3) { // zona 1
        currentNoiseScale = 0.03; // escala menor para montanhas suaves
        currentHeightScale = 120;  // mayor altura
        
      } else if (c < 2 * cols / 3) { // zona 2
        currentNoiseScale = 0.06; // escala media
        currentHeightScale = 150;  // altura media
        
      } else { // zona 3
        currentNoiseScale = 0.08; // escala mayor para montanhas abruptas
        currentHeightScale = 230;  // menor altura
      }

      //generaramos alturas usando ruido de Perlin
      float y1 = map(noise(c * currentNoiseScale, r * currentNoiseScale), 0, 1, 0, currentHeightScale);
      float y2 = map(noise(c * currentNoiseScale, (r + 1) * currentNoiseScale), 0, 1, 0, currentHeightScale);
      
      //gradiente de color para simular el terreno
      float t = map(y1, 0, heightScale, 0, 1);
      color terrainColor = lerpColor(color(34, 139, 34), color(139, 69, 19), t); // verde a cafe
      fill(terrainColor);
      
      vertex(r * sizeTerrain, y1, -c * sizeTerrain);
      vertex((r + 1) * sizeTerrain, y2, -c * sizeTerrain);
    }
    endShape();
  }
}
