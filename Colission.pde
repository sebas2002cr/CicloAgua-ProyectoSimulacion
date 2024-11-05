import java.util.ArrayList;

class Collision {
    ArrayList<AgentSystem3D> agentSystems;

    Collision() {
        agentSystems = new ArrayList<>();
    }

    // Agregar un sistema de agentes a la lista
    void addAgentSystem(AgentSystem3D system) {
        agentSystems.add(system);
    }

    // Colisiones entre agentes
    void checkAgentCollisions() {
        for (AgentSystem3D system : agentSystems) {
            for (int i = 0; i < system.agents.size(); i++) {
                Agent3D agentA = system.agents.get(i);
                for (int j = i + 1; j < system.agents.size(); j++) {
                    Agent3D agentB = system.agents.get(j);
                    if (isColliding(agentA, agentB)) {
                        handleCollision(agentA, agentB);
                    }
                }
            }
        }
    }

    // Colisiones entre un agente y los límites del sistema
    void checkBoundaryCollisions() {
        for (AgentSystem3D system : agentSystems) {
            for (Agent3D agent : system.agents) {
                if (agent.pos.x <= -800 || agent.pos.x >= 800 || agent.pos.z <= -800 || agent.pos.z >= 800) {
                    handleBoundaryCollision(agent);
                }
            }
        }
    }

    // Verificar si dos agentes están colisionando
    boolean isColliding(Agent3D agentA, Agent3D agentB) {
        float distance = PVector.dist(agentA.pos, agentB.pos);
        return distance < (agentA.r() + agentB.r()); // Compara la distancia con la suma de sus radios
    }

    // Colisión entre dos agentes
    void handleCollision(Agent3D agentA, Agent3D agentB) {
        // Normal de la colisión entre agentes
        PVector collisionNormal = PVector.sub(agentA.pos, agentB.pos).normalize();

        // Aplicar la reflexión de la velocidad manualmente
        agentA.vel = reflect(agentA.vel, collisionNormal);
        agentB.vel = reflect(agentB.vel, collisionNormal);

        agentA.mass *= 0.95; // Reducir masa del agente A
        agentB.mass *= 0.95; // Reducir masa del agente B
    }

    // Colisión de un agente con los límites del sistema
    void handleBoundaryCollision(Agent3D agent) {
        if (agent.pos.x <= -800 || agent.pos.x >= 800) {
            agent.vel.x *= -1;  // Invertir la velocidad en X
            agent.pos.x = constrain(agent.pos.x, -800, 800); // Restringir posición
        }
        if (agent.pos.z <= -800 || agent.pos.z >= 800) {
            agent.vel.z *= -1;  // Invertir la velocidad en Z
            agent.pos.z = constrain(agent.pos.z, -800, 800); // Restringir posición
        }
    }

    // Función de reflexión personalizada
    PVector reflect(PVector incoming, PVector normal) {
        PVector norm = normal.copy().normalize();
        float dotProduct = incoming.dot(norm);
        return PVector.sub(incoming, PVector.mult(norm, 2 * dotProduct));
    }
}
