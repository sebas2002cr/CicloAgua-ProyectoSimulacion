import java.util.Iterator;

class AgentSystem3D {
  PVector pos;
  ArrayList<Agent3D> agents;
  
  AgentSystem3D(float x, float y, float z) {
    pos = new PVector(x, y, z);
    agents = new ArrayList();
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
        a.update();
      }      
    }
    addAgent();
}

void run() {
  for (Agent3D a : agents) {
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
}
