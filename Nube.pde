class Nube {
    PVector pos;
    float attractionForce;
    ArrayList<PVector> cloudParticles;  

    Nube(float x, float y, float z, float attractionForce) {
        pos = new PVector(x, y, z);
        this.attractionForce = attractionForce;
        cloudParticles = new ArrayList<>();

        for (int i = 0; i < 20; i++) {
            float offsetX = random(-50, 50);
            float offsetY = random(-20, 20);
            float offsetZ = random(-50, 50);
            cloudParticles.add(new PVector(pos.x + offsetX, pos.y + offsetY, pos.z + offsetZ));
        }
    }

    void attractAgents(ArrayList<AgentSystem3D> systems) {
        for (AgentSystem3D s : systems) {
            for (int i = s.agents.size() - 1; i >= 0; i--) {
                Agent3D a = s.agents.get(i);
                if (a.isActive) {  
                    PVector closestCloudParticle = findClosestCloudParticle(a.pos);
                    float distance = PVector.dist(a.pos, closestCloudParticle);

                    if (distance < 10) {
                        s.agents.remove(i);  
                    } else {
                        PVector attraction = PVector.sub(closestCloudParticle, a.pos).normalize().mult(attractionForce);
                        a.applyForce(attraction);
                    }
                }
            }
        }
    }

    PVector findClosestCloudParticle(PVector agentPos) {
        PVector closest = cloudParticles.get(0);
        float minDistance = PVector.dist(agentPos, closest);

        for (PVector p : cloudParticles) {
            float distance = PVector.dist(agentPos, p);
            if (distance < minDistance) {
                closest = p;
                minDistance = distance;
            }
        }
        return closest;
    }

    void display() {
        noStroke();
        fill(200, 200, 255, 150); 
        for (PVector p : cloudParticles) {
            pushMatrix();
            translate(p.x, p.y, p.z);
            sphere(random(100, 20));  
            popMatrix();
        }
    }
}
