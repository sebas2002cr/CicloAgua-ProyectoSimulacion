//NO LO MODIFICO 


class Repeller extends Attractor {
  Repeller(float x, float y, float z, float mass) {
    super(x, y, z, mass);
    g *= -1;
  }

  void update() {
    for (AgentSystem3D s : systems) {
      for (Agent3D a : s.agents) {
        PVector r = PVector.sub(pos, a.pos);
        float distance = r.mag(); 

        if (distance <= 100) {
          float d2 = constrain(r.magSq(), 1, 2000);
          r.normalize();
          r.mult(g * mass * a.mass / d2);
          a.applyForce(r);
        }
      }
    } 
  }

  void display() {
    noStroke();
    fill(255, 0, 0);
    pushMatrix();
    translate(pos.x, pos.y, pos.z);
    sphere(10);
    popMatrix();
  }
}
