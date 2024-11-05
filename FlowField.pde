class FlowField {
  PVector [][] grid;
  float resolution = 20;
  int rows;
  int cols;
  float defaultMag = 2;
  float noiseInc = 0.1;
  float t = 0;
  float tInc = 0.001;
  ArrayList<AgentSystem3D> systems;

  FlowField() {
    rows = (int)(height / resolution) + 1;
    cols = (int)(width / resolution) + 1;
    systems = new ArrayList();
    createGrid();
  }

  void createGrid() {
    grid = new PVector[rows][];
    for (int r = 0; r < rows; r++) {
      grid[r] = new PVector[cols];
      for (int c = 0; c < cols; c++) {
        grid[r][c] = new PVector(1, 0);
        grid[r][c].setMag(defaultMag);
      }
    }
  }

  void updateGrid() {
    float noiseX = 0;
    for (int r = 0; r < rows; r++) {
      float noiseY = 0;
      for (int c = 0; c < cols; c++) {
        float angle = map(noise(noiseX, noiseY, t), 0, 1, -HALF_PI, TWO_PI + HALF_PI);
        grid[r][c].rotate(angle - grid[r][c].heading());
        noiseY += noiseInc;
      }
      noiseX += noiseInc;
    }
    t += tInc;
  }

  void display() {
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        displayVector(grid[r][c], c * resolution, r * resolution);
      }
    }
  }

  void displayVector(PVector vector, float x, float y) {
    PVector v = vector.copy();
    v.setMag(resolution / 2);
    pushMatrix();
    translate(x + resolution/2, y + resolution/2);
    stroke(30);
    rectMode(CENTER);
    noFill();
    rect(0, 0, resolution, resolution);
    stroke(128);
    line(0, 0, v.x, v.y);
    popMatrix();
  }

  PVector getVector(float x, float y) {
    if (x >= 0 && x <= width) {
      if (y >= 0 && y <= height) {
        int r = (int)(y / resolution);
        int c = (int)(x / resolution);
        return grid[r][c];
      }
    }
    return new PVector(0, 0);
  }

  void update() {
    updateGrid();
    for (AgentSystem3D s : systems) {
      for (Agent3D a : s.agents) {
        //a.addForce(getVector(a.pos.x, a.pos.y));  
      }
    }
  }

  void addSystem(AgentSystem3D system) {
    systems.add(system);
  }
}
