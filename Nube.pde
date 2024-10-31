class Nube {
    PVector pos;
    float attractionForce;
    ArrayList<PVector> cloudParticles;  // Para representar una nube realista

    Nube(float x, float y, float z, float attractionForce) {
        pos = new PVector(x, y, z);
        this.attractionForce = attractionForce;
        cloudParticles = new ArrayList<>();

        // Generar partículas de la nube para crear una forma más realista
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
                if (a.isActive) {  // Solo agentes activados por el sol
                    PVector closestCloudParticle = findClosestCloudParticle(a.pos);
                    float distance = PVector.dist(a.pos, closestCloudParticle);

                    if (distance < 10) {
                        s.agents.remove(i);  // Eliminar agente al llegar a la nube
                    } else {
                        // Aplicar fuerza de atracción hacia la partícula de nube más cercana
                        PVector attraction = PVector.sub(closestCloudParticle, a.pos).normalize().mult(attractionForce);
                        a.applyForce(attraction);
                    }
                }
            }
        }
    }

    // Encontrar la partícula de nube más cercana a la posición del agente
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

    // Representación visual de la nube
    void display() {
        noStroke();
        fill(200, 200, 255, 150);  // Color azul claro, semitransparente
        for (PVector p : cloudParticles) {
            pushMatrix();
            translate(p.x, p.y, p.z);
            sphere(random(100, 20));  // Esferas de diferentes tamaños para dar forma de nube
            popMatrix();
        }
    }
}
