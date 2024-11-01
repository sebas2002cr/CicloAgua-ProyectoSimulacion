class Displacement {

    float noiseScale; // Escala de ruido para el movimiento
    float speed; // Velocidad de desplazamiento
    float maxOffset; // Máxima desviación en la posición

    Displacement() {
        noiseScale = 0.01; // Suavidad del ruido
        speed = 1; // Velocidad de desplazamiento
        maxOffset = 10; // Máximo desplazamiento en cada dirección
    }

    // Aplicar el desplazamiento

    void applyDisplacement(Agent3D agent) {
        // Ruido Perlin
        float displacementX = map(noise(agent.pos.x * noiseScale, millis() * 0.001), 0, 1, -maxOffset, maxOffset);
        float displacementY = map(noise(agent.pos.y * noiseScale, millis() * 0.001), 0, 1, -maxOffset, maxOffset);
        float displacementZ = map(noise(agent.pos.z * noiseScale, millis() * 0.001), 0, 1, -maxOffset, maxOffset);

        // Aplicar la fuerza de desplazamiento
        PVector displacement = new PVector(displacementX, displacementY, displacementZ);
        displacement.mult(speed); // Ajustar según la velocidad

        agent.applyForce(displacement);
    }
}
