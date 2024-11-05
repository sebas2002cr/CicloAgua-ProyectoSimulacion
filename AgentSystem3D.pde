import java.util.Iterator;

class AgentSystem3D {

  PVector pos;
  ArrayList<Agent3D> agents;
  ArrayList<Attractor> attractors;
    float flockingHeight = -180; // Altura donde se activa el flocking
  
  AgentSystem3D(float x, float y, float z) {
    pos = new PVector(x, y, z);
    agents = new ArrayList();
    attractors = new ArrayList<Attractor>();
  }
  
  // Método para agregar un attractor a este sistema
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
        a.update(); // Actualiza la posición de cada agente
      }      
    }
    addAgent();
}


void run() {
  flocking();
    for (Agent3D a : agents) {
      if (a.isActive && a.pos.y <= flockingHeight) { 
        // Aplica flocking solo si la partícula está en la zona de flocking
        a.align(agents);
        a.separate(agents);
        a.cohere(agents);
      }
      a.update();
      a.display();
    }
    addAgent();
  }


void addAgent() {
  if (!generatingAgents) return;  
  
  int numNewAgents = (int) random(0, 9);
  for (int i = 0; i < numNewAgents; i++) {
    Agent3D agent1 = new Agent3D(pos.x, pos.y, pos.z);
    Agent3D agent2 = new Agent3D(pos.x + 20, pos.y, pos.z);
    Agent3D agent3 = new Agent3D(pos.x - 20, pos.y, pos.z);

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
