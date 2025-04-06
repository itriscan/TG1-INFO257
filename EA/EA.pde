int tamanoPoblacion = 100; // Tamaño de la población
int generaciones = 1000; // Número de generaciones
float tasaMutacion = 0.2; // Probabilidad de mutación [0.3, 0.9], velocidad de mutación a menos mas lento se encuentra el optimo.
float sigma = 0.2; // Sigma controla la exploracion / explotación, mientras mas grande, mas demora en pasar a explotacion de un valor minimo.
Individuo[] poblacion; // Población de individuos
Individuo mejorIndividuo; // se define variable mejor individuo
int generacion = 0; // Contador de generaciones

// Función de Rastrigin 2D
float rastrigin2D(float x1, float x2) {
    return 20 + sq(x1) - 10 * cos(2 * PI * x1) + sq(x2) - 10 * cos(2 * PI * x2);
}

// Clase que define el comportamiento de un individuo en el algoritmo
class Individuo {
    float x, y, aptitud; // x e y son coordenadas en el espacio de búsqueda

    Individuo() {
        x = random(-3, 7);
        y = random(-3, 7);
        evaluarAptitud();
    }

    void evaluarAptitud() {
        aptitud = rastrigin2D(x, y); // Se evalua los valores x e y en la funcion
    }

    Individuo cruzar(Individuo pareja) {
        Individuo hijo = new Individuo();
        float alfa = random(0, 1); // Cruce aritmético
        hijo.x = alfa * this.x + (1 - alfa) * pareja.x;
        hijo.y = alfa * this.y + (1 - alfa) * pareja.y;
        hijo.evaluarAptitud();
        return hijo;
    }

    void mutar() {
        if (random(1) < tasaMutacion) x += randomGaussian() * sigma;
        if (random(1) < tasaMutacion) y += randomGaussian() * sigma;
        evaluarAptitud();
    }
}

// Inicialización de la población
void setup() {
    size(800, 800);
    poblacion = new Individuo[tamanoPoblacion];
    mejorIndividuo = new Individuo();

    for (int i = 0; i < tamanoPoblacion; i++) {
        poblacion[i] = new Individuo();
        if (poblacion[i].aptitud < mejorIndividuo.aptitud) {
            mejorIndividuo = poblacion[i];
        }
    }
}

// Función para obtener el mejor individuo de la población
Individuo obtenerMejor() {
    Individuo mejor = poblacion[0];
    for (Individuo ind : poblacion) {
        if (ind.aptitud < mejor.aptitud) mejor = ind;
    }
    return mejor;
}

void evolucionar() {
    Individuo[] nuevaPoblacion = new Individuo[tamanoPoblacion];
    nuevaPoblacion[0] = mejorIndividuo; // Elitismo, mantener el mejor

    for (int i = 1; i < tamanoPoblacion; i++) {
        Individuo padre1 = seleccionTorneo();
        Individuo padre2 = seleccionTorneo();
        Individuo hijo = padre1.cruzar(padre2);
        hijo.mutar();
        nuevaPoblacion[i] = hijo;
    }
    poblacion = nuevaPoblacion;
    mejorIndividuo = obtenerMejor();
    generacion++;

    // Ajuste adaptativo de sigma
    sigma = max(0.001, sigma * 0.995);
}

Individuo seleccionTorneo() {
    Individuo[] candidatos = new Individuo[3];
    for (int i = 0; i < 3; i++) {
        candidatos[i] = poblacion[int(random(tamanoPoblacion))];
    }
    Individuo mejor = candidatos[0];
    for (Individuo candidato : candidatos) {
        if (candidato.aptitud < mejor.aptitud) mejor = candidato;
    }
    return mejor;
}


// esta función  dibuja el mapa de calor de la funcion rastrigin en el rango [x,y] --> [-3,7]
void dibujaMapaCalor() {
  noStroke();
  float step = 0.05;
  for (float x1 = -3; x1 <= 7; x1 += step) {
    for (float x2 = -3; x2 <= 7; x2 += step) {
      float y = rastrigin2D(x1, x2);
      float colorVal = map(y, 0, 125, 255, 100);
      fill(colorVal, 100, 255);
      float xPos = map(x1, -3, 7, 0, width);
      float yPos = map(x2, -3, 7, height, 0);
      rect(xPos, yPos, step * width / 10, step * height / 10);
    }
  }
}

void draw(){
  background(255);
  dibujaMapaCalor();

  // dibujar individuos
  for (Individuo ind : poblacion) {
    float xPos = map(ind.x, -3, 7, 0, width);
    float yPos = map(ind.y, -3, 7, height, 0);
    fill(0, 0, 255);
    ellipse(xPos, yPos, 5, 5);
  }
  
  // dibujar el mejor
  float bestX = map(mejorIndividuo.x, -3, 7, 0, width);
  float bestY = map(mejorIndividuo.y, -3, 7, height, 0);
  fill(255, 0, 0);
  ellipse(bestX, bestY, 10, 10);

  evolucionar();
  
  // mostrar info
  fill(0);
  textSize(16);
  text("Generacion: " + generacion, 10, 20);
  text("Mejor Fitness: " + nf(mejorIndividuo.aptitud, 1, 4), 10, 40);
  text("sigma: " + nf(sigma, 1, 4), 10, 60);
  text("coordenadas best: " + nf(bestX,1,4) + " - " +nf(bestY,1,4),10,80);
}
