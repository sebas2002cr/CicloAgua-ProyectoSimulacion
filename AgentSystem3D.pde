import java.util.Iterator;

class AgentSystem3D {

  PVector pos;
  ArrayList<Agent3D> agents;
  ArrayList<Attractor> attractors;
  float flockingHeight = -100; 
  int flockingStartTime; 
  float topHeight = -200;
  boolean flockingStarted = false;

  
  AgentSystem3D(float x, float y, float z) {
    pos = new PVector(x, y, z);
    agents = new ArrayList();
    attractors = new ArrayList<Attractor>();
    flockingStartTime = millis();
  }
  
   void addAttractor(Attractor attractor) {
     attractors.add(attractor);
   }

  void display() {
    for (Agent3D a : agents) {
      a.display();
    }
  }

void update() {
    Iterator<Agent3D> it = agents.iterator();
    while (it.hasNext()) {
      Agent3D a = it.next();
      if (a.isDead()) {
        it.remove(); 
        a.align(agents);      
        a.separate(agents);   
        a.cohere(agents);     
        a.update();
      }else {
        a.update(); 
      }      
    }
    addAgent();
}


void run() {
  if (!flockingStarted) {
            flockingStartTime = millis(); 
            flockingStarted = true;
        }
        
        if (millis() - flockingStartTime > 30000) {  
            releaseSomeParticles();
            flockingStarted = false;  
        }
    for (Agent3D a : agents) {
      if (a.isActive && a.pos.y < flockingHeight) { 
        
        flocking();


        a.align(agents);
        a.separate(agents);
        a.cohere(agents);
      }
      a.update();
      a.display();
    }
    addAgent();
  }


void releaseSomeParticles() {
        for (int i = 0; i < agents.size(); i++) {
            if (random(1) < 0.8) {  // 30% de probabilidad de dejar caer cada partícula
                agents.get(i).isFalling = true;
                agents.get(i).isActive = false;
            }
        }
    }

void addAgent() {
  if (!generatingAgents) return;  

  int numNewAgents = (int) random(1, 4);
  for (int i = 0; i < numNewAgents; i++) {
    float offsetX = random(-500, 500);  //desplazamiento aleatorio en X
    float offsetZ = random(-500, 500);  //desplazamiento aleatorio en Z
    
    Agent3D agent1 = new Agent3D(pos.x + offsetX, pos.y, pos.z - offsetZ);
    Agent3D agent2 = new Agent3D(pos.x + offsetX, pos.y, pos.z + offsetZ);
    Agent3D agent3 = new Agent3D(pos.x - offsetX, pos.y, pos.z - offsetZ);

    PVector f = new PVector(random(-1, 1), 0, random(1, 2));
    f.setMag(random(50, 200));
    agent1.applyForce(f);
    agent2.applyForce(f);
    agent3.applyForce(f);

    agents.add(agent1);
    agents.add(agent2);
    agents.add(agent3);
  }
}

//FLOCKING ----------------
  void align() {
    for (Agent3D a : agents) {
      a.align(agents);
    }
  }
  
  void separate() {
    for (Agent3D a : agents) {
      a.separate(agents);
    }
  }
  void cohere() {
    for (Agent3D a : agents) {
      a.cohere(agents);
    }
  }
  
    void flocking() {
        for (Agent3D agent : agents) {
            agent.align(agents);
            agent.separate(agents);
            agent.cohere(agents);
        }
    }



}
