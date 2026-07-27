# Fluid Particle Resonance

An interactive generative art installation built with Processing (Java Mode) that explores fluid dynamics, particle systems, and real-time user interaction.

---

## ✨ Features

### Particle System
- **Foreground Particles**: 300 interactive particles that respond to mouse presence and flow field forces
- **Background Particles**: 300 independent slow-moving particles creating depth and atmosphere
- **Mouse Trail Particles**: Dynamic trail effects generated during mouse drag

### Visual Effects
- **Multi-layer Glow**: Three-layer radial gradient glow for each particle with adjustable intensity
- **Connection Network**: Dynamic lines connecting nearby particles based on distance
- **Color Dynamics**: Hue shifts based on velocity, creating flowing color transitions
- **Mouse Proximity Effects**: Enhanced glow and size increase when particles are near the cursor
- **Smooth Trails**: Semi-transparent background redraw creates natural motion trails

### Interaction
- **Attraction/Repulsion**: Mouse acts as a force field with toggleable mode
- **Real-time Glow**: Particles emit stronger light when near the mouse (no click required)
- **Burst Effects**: Click to generate 20 new particles with random velocities
- **Trail Generation**: Drag to leave colorful fading particle trails

---

## 🖱️ Interaction Guide

| Action | Effect |
|--------|--------|
| **Mouse Movement** | Creates attraction/repulsion force field; nearby particles glow brighter |
| **Mouse Drag** | Leaves fading particle trails |
| **Mouse Click** | Generates 20 new particles with burst velocities |
| **Key 1** | Toggle between attraction and repulsion mode |
| **Key 2** | Show/hide particle connection lines |
| **Key 3** | Reset all particles to initial state |
| **Key S** | Save current frame as PNG image |

---

## 🔧 Technical Implementation

### 1. Flow Field with Perlin Noise

The particle movement is driven by a dynamically changing flow field computed using Processing's `noise()` function:

```java
float noiseValue = noise(position.x * noiseScale, position.y * noiseScale, time);
float angle = noiseValue * TWO_PI * 2;
PVector force = new PVector(cos(angle), sin(angle));
force.mult(maxForce);
acceleration.add(force);
```

**How it works:**
- `noise(x, y, z)` returns a smooth pseudo-random value between 0 and 1
- The z parameter (`time`) creates temporal variation, making the flow field animate
- The noise value is mapped to an angle (0 to 4π for more varied directions)
- This angle determines the force direction for each particle

### 2. Distance Detection with dist()

Particle connections are established using the `dist()` function to measure proximity:

```java
float d = dist(p1.position.x, p1.position.y, p2.position.x, p2.position.y);

if (d < connectionThreshold) {
    float alpha = map(d, 0, connectionThreshold, 60, 0);
    float lineWidth = map(d, 0, connectionThreshold, connectionLineWidth, 0.2);
    
    stroke(p1.hue, 70, 60, alpha);
    strokeWeight(lineWidth);
    line(p1.position.x, p1.position.y, p2.position.x, p2.position.y);
}
```

**How it works:**
- `dist(x1, y1, x2, y2)` calculates Euclidean distance between two points
- When distance falls below `connectionThreshold` (120 pixels), a connection is drawn
- Line opacity and width are dynamically mapped based on proximity: closer = thicker and more opaque

### 3. Vector Operations with PVector

All particle physics use Processing's PVector class for vector mathematics:

```java
void applyMouseForce() {
    PVector mouse = new PVector(mouseX, mouseY);
    PVector diff = PVector.sub(mouse, position);
    float d = diff.mag();
    
    if (d < mouseRadius && d > 0) {
        diff.normalize();
        float forceStrength = map(d, 0, mouseRadius, mouseStrength, 0);
        if (!attractMode) forceStrength *= -1;
        diff.mult(forceStrength * maxForce);
        acceleration.add(diff);
    }
}
```

**How it works:**
- `PVector.sub()` computes the direction vector from particle to mouse
- `normalize()` converts to unit vector (length = 1)
- `mag()` returns the vector magnitude (distance)
- Force strength decreases linearly with distance using `map()`

### 4. Mouse Proximity Glow Effect

Particles dynamically enhance their visual appearance when near the mouse:

```java
float getMouseGlowIntensity() {
    PVector mouse = new PVector(mouseX, mouseY);
    float d = position.dist(mouse);
    
    if (d < mouseRadius) {
        return map(d, 0, mouseRadius, 1.0, 0.0);
    }
    return 0.0;
}
```

**How it works:**
- Glow intensity ranges from 1.0 (at mouse position) to 0.0 (at threshold distance)
- Enhanced particles receive: +50% alpha, +50% size, larger glow radius
- A bright core highlight appears when intensity exceeds 0.1

### 5. Background Particle Decoupling

Background particles use individual noise offsets to prevent synchronization:

```java
float noiseValue = noise(
    position.x * bgNoiseScale + noiseOffsetX, 
    position.y * bgNoiseScale + noiseOffsetY, 
    time * 0.5 + noiseOffsetTime
);
```

**How it works:**
- Each particle gets random `noiseOffsetX`, `noiseOffsetY`, and `noiseOffsetTime` values
- This ensures particles don't cluster into patterns despite using the same noise function
- The result is a smooth, organic "flowing mist" effect

---

## 📐 Adjustable Parameters

| Category | Parameter | Default | Description |
|----------|-----------|---------|-------------|
| **System** | `particleCount` | 300 | Number of foreground particles |
| **System** | `maxSpeed` | 2.0 | Maximum particle velocity |
| **System** | `maxForce` | 0.1 | Maximum steering force |
| **Noise** | `noiseScale` | 0.01 | Flow field resolution |
| **Noise** | `noiseSpeed` | 0.005 | Animation speed |
| **Connections** | `connectionThreshold` | 120 | Distance for line drawing |
| **Mouse** | `mouseRadius` | 150 | Interaction radius |
| **Mouse** | `mouseStrength` | 0.5 | Force intensity |
| **Visual** | `particleBaseSize` | 3.0 | Minimum particle size |
| **Visual** | `particleMaxSize` | 8.0 | Maximum particle size |
| **Background** | `bgParticleCount` | 300 | Number of background particles |
| **Background** | `bgMaxSpeed` | 0.8 | Background particle speed |
| **Trail** | `maxTrailCount` | 30 | Maximum trail particles |
| **Trail** | `trailLife` | 60 | Trail particle lifespan (frames) |

---

## 🚀 Getting Started

### Prerequisites
- Processing 4.x (Java Mode)
- Java Development Kit (JDK) 8 or higher

### Installation
1. Clone this repository
2. Open `FluidParticleResonance.pde` in Processing IDE
3. Click the "Run" button (▶️)

### Running from Command Line
```bash
cd FluidParticleResonance
processing-java --sketch=. --run
```

---

## 📁 Project Structure

```
FluidParticleResonance/
├── FluidParticleResonance.pde    # Main sketch file
├── README.md                      # This file
└── .gitignore                     # Git ignore rules
```

---

## 🎨 Aesthetic Design

The visual style combines:
- **Dark ambient background** (HSB 10) for deep space feel
- **Full-spectrum color palette** using HSB color mode (0-360 hue)
- **Soft glow effects** through multi-layer semi-transparent ellipses
- **Organic movement** derived from Perlin noise flow fields
- **Dynamic depth** through layered particle systems with varying speeds

---

## 📝 License

This project is open source and available under the [MIT License](LICENSE).

---

## 🙏 Acknowledgments

- Inspired by the work of Daniel Shiffman and the Processing Foundation
- Built with Processing 4.x - https://processing.org/
  
