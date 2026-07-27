// FluidParticleResonance
// Processing 4.x Java

// === 可调参数 ===
// 粒子系统参数
int particleCount = 300;
float maxSpeed = 2.0;
float maxForce = 0.1;
float noiseScale = 0.01;
float noiseSpeed = 0.005;

// 距离感应参数
float connectionThreshold = 120;
float connectionLineWidth = 1.5;

// 视觉参数
float particleBaseSize = 3.0;
float particleMaxSize = 8.0;
float backgroundColor = 10;

// 鼠标交互参数
float mouseRadius = 150;
float mouseStrength = 0.5;

// 背景粒子参数
int bgParticleCount = 300;
float bgMaxSpeed = 0.8;
float bgNoiseScale = 0.003;

// 鼠标轨迹参数
int maxTrailCount = 30;
float trailLife = 60;

// === 状态变量 ===
Particle[] particles;
BgParticle[] bgParticles;
MouseTrail[] mouseTrails;
boolean attractMode = true;
boolean showConnections = true;
float time = 0;
PFont chineseFont;

void settings() {
  size(1200, 800, P2D);
}

void setup() {
  surface.setResizable(true);
  surface.setLocation((displayWidth - width) / 2, (displayHeight - height) / 2);
  
  chineseFont = createFont("SimHei", 14);
  
  particles = new Particle[particleCount];
  for (int i = 0; i < particleCount; i++) {
    particles[i] = new Particle();
  }
  
  bgParticles = new BgParticle[bgParticleCount];
  for (int i = 0; i < bgParticleCount; i++) {
    bgParticles[i] = new BgParticle();
  }
  
  mouseTrails = new MouseTrail[maxTrailCount];
  
  colorMode(HSB, 360, 100, 100, 100);
  background(backgroundColor);
}

void draw() {
  background(backgroundColor, 15);
  
  time += noiseSpeed;
  
  for (BgParticle p : bgParticles) {
    p.update();
    p.draw();
  }
  
  for (MouseTrail t : mouseTrails) {
    if (t != null && t.alive) {
      t.update();
      t.draw();
    }
  }
  
  for (Particle p : particles) {
    p.update();
    p.draw();
  }
  
  if (showConnections) {
    drawConnections();
  }
  
  drawInfo();
}

void drawConnections() {
  for (int i = 0; i < particles.length; i++) {
    for (int j = i + 1; j < particles.length; j++) {
      Particle p1 = particles[i];
      Particle p2 = particles[j];
      
      float d = dist(p1.position.x, p1.position.y, p2.position.x, p2.position.y);
      
      if (d < connectionThreshold) {
        float alpha = map(d, 0, connectionThreshold, 60, 0);
        float lineWidth = map(d, 0, connectionThreshold, connectionLineWidth, 0.2);
        
        stroke(p1.hue, 70, 60, alpha);
        strokeWeight(lineWidth);
        line(p1.position.x, p1.position.y, p2.position.x, p2.position.y);
      }
    }
  }
}

void drawInfo() {
  fill(255, 60);
  textFont(chineseFont);
  textSize(14);
  String mode = attractMode ? "引力模式" : "斥力模式";
  String connections = showConnections ? "连接线: 开" : "连接线: 关";
  text("模式: " + mode + " | " + connections, 20, height - 30);
  text("按键: 1-切换模式 2-连接线开关 3-重置 s-保存", 20, height - 15);
}

void mousePressed() {
  for (int i = 0; i < 20; i++) {
    Particle newP = new Particle();
    newP.position.set(mouseX + random(-30, 30), mouseY + random(-30, 30));
    newP.velocity.set(random(-3, 3), random(-3, 3));
    particles[i] = newP;
  }
}

void mouseDragged() {
  for (int i = 0; i < maxTrailCount; i++) {
    if (mouseTrails[i] == null || !mouseTrails[i].alive) {
      mouseTrails[i] = new MouseTrail(mouseX, mouseY);
      break;
    }
  }
}

void keyPressed() {
  if (key == '1') {
    attractMode = !attractMode;
  } else if (key == '2') {
    showConnections = !showConnections;
  } else if (key == '3') {
    for (int i = 0; i < particleCount; i++) {
      particles[i] = new Particle();
    }
  } else if (key == 's' || key == 'S') {
    saveFrame("FluidParticleResonance_####.png");
  }
}

class Particle {
  PVector position;
  PVector velocity;
  PVector acceleration;
  float hue;
  float size;
  
  Particle() {
    position = new PVector(random(width), random(height));
    velocity = new PVector(random(-1, 1), random(-1, 1));
    acceleration = new PVector();
    hue = random(360);
    size = particleBaseSize;
  }
  
  void update() {
    acceleration.mult(0);
    
    applyFlowField();
    
    applyMouseForce();
    
    velocity.add(acceleration);
    velocity.limit(maxSpeed);
    position.add(velocity);
    
    wrapAround();
    
    float speed = velocity.mag();
    size = map(speed, 0, maxSpeed, particleBaseSize, particleMaxSize);
    hue = (hue + speed * 0.5) % 360;
  }
  
  void applyFlowField() {
    float noiseValue = noise(position.x * noiseScale, position.y * noiseScale, time);
    float angle = noiseValue * TWO_PI * 2;
    PVector force = new PVector(cos(angle), sin(angle));
    force.mult(maxForce);
    acceleration.add(force);
  }
  
  void applyMouseForce() {
    PVector mouse = new PVector(mouseX, mouseY);
    PVector diff = PVector.sub(mouse, position);
    float d = diff.mag();
    
    if (d < mouseRadius && d > 0) {
      diff.normalize();
      
      float forceStrength = map(d, 0, mouseRadius, mouseStrength, 0);
      if (!attractMode) {
        forceStrength *= -1;
      }
      
      diff.mult(forceStrength * maxForce);
      acceleration.add(diff);
    }
  }
  
  void wrapAround() {
    float margin = 50;
    if (position.x < -margin) position.x = width + margin;
    if (position.x > width + margin) position.x = -margin;
    if (position.y < -margin) position.y = height + margin;
    if (position.y > height + margin) position.y = -margin;
  }
  
  float getMouseGlowIntensity() {
    PVector mouse = new PVector(mouseX, mouseY);
    float d = position.dist(mouse);
    
    if (d < mouseRadius) {
      return map(d, 0, mouseRadius, 1.0, 0.0);
    }
    return 0.0;
  }
  
  void draw() {
    float speed = velocity.mag();
    float baseAlpha = map(speed, 0, maxSpeed, 50, 100);
    
    float glowIntensity = getMouseGlowIntensity();
    
    pushStyle();
    noStroke();
    
    if (glowIntensity > 0) {
      float enhancedAlpha = baseAlpha + glowIntensity * 50;
      float enhancedSize = size + glowIntensity * size * 0.5;
      
      fill(hue, 40, 100, enhancedAlpha * 0.3);
      ellipse(position.x, position.y, enhancedSize * 5, enhancedSize * 5);
      
      fill(hue, 60, 90, enhancedAlpha * 0.5);
      ellipse(position.x, position.y, enhancedSize * 2.5, enhancedSize * 2.5);
      
      fill(hue, 80, 80, enhancedAlpha);
      ellipse(position.x, position.y, enhancedSize, enhancedSize);
      
      fill(hue, 100, 100, enhancedAlpha * 0.9);
      ellipse(position.x, position.y, enhancedSize * 0.3, enhancedSize * 0.3);
    } else {
      fill(hue, 40, 100, baseAlpha * 0.2);
      ellipse(position.x, position.y, size * 4, size * 4);
      
      fill(hue, 60, 90, baseAlpha * 0.5);
      ellipse(position.x, position.y, size * 2, size * 2);
      
      fill(hue, 80, 80, baseAlpha);
      ellipse(position.x, position.y, size, size);
    }
    
    popStyle();
  }
}

class BgParticle {
  PVector position;
  PVector velocity;
  float hue;
  float size;
  float noiseOffsetX;
  float noiseOffsetY;
  float noiseOffsetTime;
  
  BgParticle() {
    position = new PVector(random(width), random(height));
    velocity = new PVector(random(-0.5, 0.5), random(-0.5, 0.5));
    hue = random(360);
    size = random(2, 4);
    noiseOffsetX = random(1000);
    noiseOffsetY = random(1000);
    noiseOffsetTime = random(100);
  }
  
  void update() {
    float noiseValue = noise(
      position.x * bgNoiseScale + noiseOffsetX, 
      position.y * bgNoiseScale + noiseOffsetY, 
      time * 0.5 + noiseOffsetTime
    );
    float angle = noiseValue * TWO_PI;
    PVector force = new PVector(cos(angle), sin(angle));
    force.mult(0.02);
    
    velocity.add(force);
    velocity.limit(bgMaxSpeed);
    position.add(velocity);
    
    if (position.x < 0) position.x = width;
    if (position.x > width) position.x = 0;
    if (position.y < 0) position.y = height;
    if (position.y > height) position.y = 0;
    
    hue = (hue + 0.1) % 360;
  }
  
  void draw() {
    pushStyle();
    noStroke();
    fill(hue, 50, 60, 40);
    ellipse(position.x, position.y, size, size);
    
    fill(hue, 30, 80, 20);
    ellipse(position.x, position.y, size * 2, size * 2);
    popStyle();
  }
}

class MouseTrail {
  PVector position;
  float life;
  float maxLife;
  boolean alive;
  float hue;
  
  MouseTrail(float x, float y) {
    position = new PVector(x, y);
    maxLife = trailLife;
    life = maxLife;
    alive = true;
    hue = random(360);
  }
  
  void update() {
    life -= 1;
    hue = (hue + 0.5) % 360;
    if (life <= 0) {
      alive = false;
    }
  }
  
  void draw() {
    pushStyle();
    noStroke();
    float alpha = map(life, 0, maxLife, 0, 60);
    float size = map(life, 0, maxLife, 0, 20);
    
    fill(hue, 60, 70, alpha);
    ellipse(position.x, position.y, size, size);
    
    fill(hue, 40, 90, alpha * 0.5);
    ellipse(position.x, position.y, size * 2, size * 2);
    popStyle();
  }
}
