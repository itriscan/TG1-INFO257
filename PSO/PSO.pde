int puntos = 100;
Particulas[] fl;
float d = 15;
float g_best_x, g_best_y, g_best = Float.MAX_VALUE;
float inercia = 0.6;
float c1 = 2, c2 = 2;
int evals = 0, evals_to_best = 0;
float maxv = 0.1;
float Cola = 0.3;

class Particulas {
  float x, y, aptitud;
  float p_best_x, p_best_y, p_best_fit;
  float vx, vy;

  Particulas() {
    x = random(-3, 7);  // coordenadas lógicas
    y = random(-3, 7);

    vx = random(-1, 1);
    if (vx == 0) vx = 0.1;
    vy = random(-1, 1);
    if (vy == 0) vy = 0.1;

    aptitud = rastrigin2D(x, y);
    p_best_fit = aptitud;
    p_best_x = x;
    p_best_y = y;

    if (aptitud < g_best) {
      g_best = aptitud;
      g_best_x = x;
      g_best_y = y;
    }
  }

  void mover() {
    vx = inercia * vx + random(0, 1) * c1 * (p_best_x - x) + random(0, 1) * c2 * (g_best_x - x);
    vy = inercia * vy + random(0, 1) * c1 * (p_best_y - y) + random(0, 1) * c2 * (g_best_y - y);

    float velocidad = sqrt(vx * vx + vy * vy);
    if (velocidad > maxv) {
      vx = (vx / velocidad) * maxv;
      vy = (vy / velocidad) * maxv;
    }

    x += vx;
    y += vy;

    if (x > 7) { x = 7; vx *= -1; }
    if (x < -3) { x = -3; vx *= -1; }
    if (y > 7) { y = 7; vy *= -1; }
    if (y < -3) { y = -3; vy *= -1; }
  }

  void Evaluar() {
    evals++;
    aptitud = rastrigin2D(x, y);

    if (aptitud < p_best_fit) {
      p_best_fit = aptitud;
      p_best_x = x;
      p_best_y = y;
    }

    if (aptitud < g_best) {
      g_best = aptitud;
      g_best_x = x;
      g_best_y = y;
      evals_to_best = evals;
      println("Nuevo Global Best: " + g_best);
    }
  }

  void display() {
    float sx = toScreenX(x);
    float sy = toScreenY(y);
    float tailX = toScreenX(x - Cola * vx);
    float tailY = toScreenY(y - Cola * vy);

    noFill();
    stroke(#267F00);
    ellipse(sx, sy, d, d);
    line(sx, sy, tailX, tailY);
  }
}

float rastrigin2D(float x1, float x2) {
  return 20 + sq(x1) - 10 * cos(2 * PI * x1) + sq(x2) - 10 * cos(2 * PI * x2);
}

// funciones para transformar lógica <-> pantalla
float toScreenX(float logicX) {
  return map(logicX, -3, 7, 0, width);
}

float toScreenY(float logicY) {
  return map(logicY, -3, 7, height, 0);
}

float toLogicX(float screenX) {
  return map(screenX, 0, width, -3, 7);
}

float toLogicY(float screenY) {
  return map(screenY, height, 0, -3, 7);
}

void setup() {
  size(800, 800);
  fl = new Particulas[puntos];
  for (int i = 0; i < puntos; i++) {
    fl[i] = new Particulas();
  }
}

void draw() {
  background(255);

  float paso = 0.05;
  float inicio = -3;
  float fin = 7;

  noStroke();

  for (float x1 = inicio; x1 <= fin; x1 += paso) {
    for (float x2 = inicio; x2 <= fin; x2 += paso) {
      float y = rastrigin2D(x1, x2);
      float mappedColor = map(y, 0, 125, 100, 255);
      fill(150, 0, 255, mappedColor);
      float xPos = toScreenX(x1);
      float yPos = toScreenY(x2);
      float size = paso * width / (fin - inicio);
      rect(xPos, yPos, size, size);
    }
  }

  for (int i = 0; i < puntos; i++) {
    fl[i].mover();
    fl[i].Evaluar();
    fl[i].display();
  }

  fill(0);
  ellipse(toScreenX(g_best_x), toScreenY(g_best_y), d, d);
  fill(0);
  textSize(16);
  text("Global Best Fitness: " + nf(g_best, 1, 10), 10, 20);
  text("Evals: " + evals, 10, 40);
  text("Evals to Best: " + evals_to_best, 10, 60);
}
