class Sol {
  PVector pos;
  float radius;
  float influenceRange;
  float radiationForce;
  float heatRadius = 50; 

  Sol(float x, float y, float z, float radius, float influenceRange, float radiationForce) {
    pos = new PVector(x, y, z);
    this.radius = radius;
    this.influenceRange = influenceRange;
    this.radiationForce = radiationForce;
  }

  void affectAgents(ArrayList<AgentSystem3D> systems) {
    for (AgentSystem3D s : systems) {
      for (Agent3D a : s.agents) {
        if (a.onFloor && isInHeatedZone(a.pos.x, a.pos.z)) {
          float randomFactor = random(0.8, 1.2);  
          PVector radiationEffect = new PVector(0, -radiationForce * randomFactor, 0);  // Fuerza hacia arriba
          a.applyForce(radiationEffect);
        }
      }
    }
  }

  boolean isInHeatedZone(float x, float z) {
    int i = int(map(x, -800, 800, 0, 39));
    int j = int(map(z, -800, 800, 0, 39));
    if (i >= 0 && i < 40 && j >= 0 && j < 40) {
      return heatMap[i][j];
    }
    return false;
  }

  void display() {
    noStroke();
    fill(255, 204, 0);  
    pushMatrix();
    translate(pos.x, pos.y, pos.z);
    sphere(radius);  
    popMatrix();
  }

  void expandHeatZone() {
    int centerX = int(map(pos.x, -800, 800, 0, 39));
    int centerZ = int(map(pos.z, -800, 800, 0, 39));
    float maxRadius = influenceRange;  

    for (int i = 0; i < 40; i++) {
      for (int j = 0; j < 40; j++) {
        float x = map(i, 0, 39, -800, 800);
        float z = map(j, 0, 39, -800, 800);
        float distance = dist(x, 0, z, pos.x, 0, pos.z);

        if (distance < heatRadius) {
          heatMap[i][j] = true;
        }
      }
    }

    if (heatRadius < maxRadius) {
      heatRadius += 5;  
    }
  }
}
