class Sol {
  PVector pos;
  float radius;
  float influenceRange;
  float radiationForce;

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
          
          // SOLO AFECTAR A LOS GENTES DENTRO DE LA ZONA CALENTADAS 
          
          float randomFactor = random(0.8, 1.2);  // Diferencias pequeñas en la fuerza de radiación
          
          PVector radiationEffect = new PVector(0, -radiationForce * randomFactor, 0);  // Fuerza hacia arriba
          
          a.applyForce(radiationEffect);
        }
      }
    }
  }

  // CHECK si una zona esta dentro de una zona hot
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

  
  //SE ESCOGE UNA ZONA NUEVA Y SE CALIENTA LAS CELDAS 
  void chooseNewZone() {
    
    currentI = int(random(0, 35));  
    
    currentJ = int(random(0, 35));

    for (int i = currentI; i < currentI + zoneSize && i < 40; i++) {
      
      for (int j = currentJ; j < currentJ + zoneSize && j < 40; j++) {
        
        heatMap[i][j] = true;  
      }
    }
  }
}
