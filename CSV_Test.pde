import promidi.*;
import processing.serial.*;
float brainFactor = 1000.0;
float betaGammaFactor = 500.0;
int attVal[];
int medVal[];
int deltaVal[];
int thetaVal[];

int alphaVal[];
int lowAlphaVal[];
int highAlphaVal[];

int betaVal[];
int lowBetaVal[];
int highBetaVal[];

int gammaVal[];
int lowGammaVal[];
int highGammaVal[];

int numCols;
int i = 0;

int tempo = 145;
// these 2 variables define the controller #s which we'll send out over MIDI
int attCC = 8;
int medCC = 9;
// These are that MIDI notes that I have setup with each instrument in my DAW
int G4 = 67;
int B4 = 71;
int D5 = 74;
int G5Flat = 78;
int G2 = 43;
int D3 = 50;
int G3 = 55;
int j;
// curious, should control note's duration, no luck with it myself, ymmv
int noteLength = 1;

Table table;

Sequencer sequencer;
Song song;
Track g4Track, b4Track, d5Track, g5FlatTrack, g2Track, d3Track, g3Track;
Controller attController, medController;
MidiOut midiOut;

void setup() {
  size(800, 768);
  smooth(4);
  background(255);
  iniciar();
  vectores();
  sequencer = new Sequencer();
  // Use this method to get instance of MidiIO. It makes sure that only one
  // instance of MidiIO is initialized. You have to give this method a reference
  // to
  // your applet, to let promidi communicate with it.
  MidiIO midiIO = MidiIO.getInstance();
  // Muestra los dispositivos MIDI disponibles en el equipo
  midiIO.printDevices();
  midiIO.closeOutput(1);
  // Abre un Midiout usando el primer dispositivo y el primer canal
  midiOut = midiIO.getMidiOut(0, 3);
  // Se definen los parametros inic.mnW5iales de atencion y meditacion
  // Controller Class -> representa un controlador MIDI
  // Tiene un numero y un valor se pueden recibir valores de midi ins y enviarlos
  // a midi outs
  attController = new Controller(attCC, 100);
  medController = new Controller(medCC, 100);
  // A song is a data structure containing musical information
  // that can be played back by the proMIDI sequencer object. Specifically, the
  // song contains timing information and one or more tracks. Each track consists
  // of a
  // series of MIDI events (such as note-ons, note-offs, program changes, and
  // meta-events).
  song = new Song("beat", tempo);
  // A track handles all midiEvents of a song for a certain midiout. You can
  // directly
  // add Events like Notes or ControllerChanges to it or also work with patterns.
  g4Track = new Track("g4", midiOut);
  // Establece el tiempo de duracion de duracion de una nota: 8-> corcheas
  g4Track.setQuantization(Q._1_8);
  b4Track = new Track("b4", midiOut);
  b4Track.setQuantization(Q._1_8);
  d5Track = new Track("d5", midiOut);
  d5Track.setQuantization(Q._1_8);
  g5FlatTrack = new Track("g5Flat", midiOut);
  g5FlatTrack.setQuantization(Q._1_8);
  g2Track = new Track("g2", midiOut);
  g2Track.setQuantization(Q._1_8);
  d3Track = new Track("d3", midiOut);
  d3Track.setQuantization(Q._1_8);
  g3Track = new Track("g3", midiOut);
  g3Track.setQuantization(Q._1_8);
  song.addTrack(g4Track);
  song.addTrack(b4Track);
  song.addTrack(d5Track);
  song.addTrack(g5FlatTrack);
  song.addTrack(g2Track);
  song.addTrack(d3Track);
  song.addTrack(g3Track);
  sequencer.setSong(song);
  // Sets the startpoint of the loop the sequencer should play
  sequencer.setLoopStartPoint(0);
  // Sets the endpoint of the loop the sequencer should play
  sequencer.setLoopEndPoint(512);
  // Sets how often the loop of the sequencer has to be played.
  sequencer.setLoopCount(-1);
}

void iniciar() {
  //Files: Reading, Reading2, Guitar, Guitar2
  table = loadTable("Guitar2.csv", "header");
  numCols = table.getRowCount();
  println("Número de registros " + numCols);
  attVal = new int[numCols];
  medVal = new int[numCols];
  gammaVal = new int[numCols];
  deltaVal = new int[numCols];
  thetaVal = new int[numCols];
  alphaVal = new int[numCols];
  lowAlphaVal = new int[numCols];
  highAlphaVal = new int[numCols];
  betaVal = new int[numCols];
  lowBetaVal = new int[numCols];
  highBetaVal = new int[numCols];
  gammaVal = new int[numCols];
  lowGammaVal = new int[numCols];
  highGammaVal = new int[numCols];
}

void vectores() {
  for (TableRow row : table.rows()) {
    attVal[i] = round(row.getInt(0) * 1.27);
    medVal[i] = round(row.getInt(1) * 1.27);
    deltaVal[i] = round(row.getInt(2)/int(brainFactor));
    thetaVal[i] = round(row.getInt(3)/int(brainFactor));
    lowAlphaVal[i] = round(row.getInt(4)/int(brainFactor)) ;
    highAlphaVal[i] = round(row.getInt(5)/int(brainFactor));
    alphaVal[i] = round((lowAlphaVal[i] + highAlphaVal[i])/2);
    lowBetaVal[i] = round(row.getInt(6)/int(betaGammaFactor));
    highBetaVal[i] = round(row.getInt(7)/int(betaGammaFactor));
    betaVal[i] = round((lowBetaVal[i] + highBetaVal[i])/2);
    lowGammaVal[i] = round(row.getInt(8)/int(betaGammaFactor));
    highGammaVal[i] = round(row.getInt(9)/int(betaGammaFactor));
    gammaVal[i] = round((lowGammaVal[i] + highGammaVal[i])/2);
    i++;
  }
}

void draw() {
  j = 0;
  while (j < numCols) {
    float time = millis()/1000.;
    randomSeed(9999); //Semilla para el elemento random lo que hace que los puntos se desplazen. COn 1 los puntos son gigantes
    int cc = deltaVal[j]; //Cantidad de puntos de pintura. Gamma, Alpha, Theta, Delta
    int div = gammaVal[j]; //Afecta el tamaño de los puntos, entre mas pequeño el valor más grandes los puntos
    float ss = width*1./div; //Divide el ancho de la pantalla entre div
    stroke(0, 50); //Dibuja bordes en cada circulo. Hace el efecto de generar cada circulo a la vez. El primero argumento es el color el RGB, el segundo es la opacidad, a mayor opacidad más bordeado el circulo
    //noStroke(); //Desabilita dibujar bordes
    for (int i = 0; i < cc; i++) {
      float x = int(random(div+1))*ss;
      float y = int(random(div+1))*ss;
      float desplazamiento = time*random(0.1, 1)*60*(int(random(2))*2-1); //Puede ser negativo
      if (random(1) > 0.5) {
        x += desplazamiento;
        if (x < -ss) x = width*ss*2-(abs(x)%(width+ss));
        if (x > width+ss) x = (x%(width+ss))-ss;
      } else {
        y += desplazamiento;
        if (y < -ss) y = height*ss*2-(abs(y)%(height+ss));
        if (y > height+ss) y = (y%(height+ss))-ss;
      }
      float s = ss*random(1)*(1-cos(time*random(1))*random(1)); //Efecto ola
      float c = random(colors.length)+time*random(-1, 1);
      if (c < 0) c = abs(c);
      fill(getColor(c), random(attVal[j], medVal[j])); //Llena el circulo de un color y una opacidad
      ellipse(x, y, s, s); //Hace una elipse de alto-ancho s
    }
    resetPatterns();
    j++;
  }
}

int colors[] = {#fbff05, #ffa305, #ff054c, #ff05c1, #680885, #0e0b57, #4287f5, #0ba9e3, #11a63b, #043b31, #ffffff};
int seed = int(random(999999));

int getColor(float v) {
  v = v%(colors.length);
  int c1 = colors[int(v%colors.length)];
  int c2 = colors[int((v+1)%colors.length)];
  //Calcula un color entre dos colores con un incremento específico. 
  //El último parámetro es la cantidad a interpolar entre los dos primeros colores
  return lerpColor(c1, c2, v%1);
}

void keyPressed() {
  if (key == 's')
    saveImage();
  if (key == 'e')
    exit();
}

void saveImage() {
  String timestamp = year() + nf(month(), 2) + nf(day(), 2) + "-" + nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2);
  println("Guardando imagen ... ");
  save("Capturas/" + timestamp + ".png");
  println("Imagen guardada exitosamente");
}

void mousePressed() {
  if (mouseButton == LEFT) {
    sequencer.start();
    println("sequencer is running");
  } else if (mouseButton == RIGHT) {
    sequencer.stop();
    println("sequencer has stopped");
  }
}
void exit() {
  println("Exiting");
  super.exit();
}

public void creatingMusic(String note) {
  int cuantization = 0;
  int noteValue = 0;
  int pattMax = notePatt.length - 1;
  // send attention & meditation values as MIDI CC messages
  // Se usan los niveles de atención y relajación para cambiar el sonido general
  // del beat
  medController = new Controller(medCC, medVal[j]);
  midiOut.sendController(medController);

  attController = new Controller(attCC, attVal[j]);
  midiOut.sendController(attController);
  // pasoDeMensajes();
  // this could be much more elegant (& shorter), but it works //Se aisgna cada
  // onda a un instrumento de percusion
  // thetaVal -> G4
  // alphaVal -> B4
  // betaVal -> D5
  // gammaVal -> G5Flat
  // Cada nivel de frecuencia determina que patron de la lista se reproduce
  if (note.equals("g4")) {
    song.removeTrack(g4Track);
    g4Track = new Track(note, midiOut);
    g4Track.setQuantization(Q._1_8);
    cuantization = constrain(thetaVal[j], 0, pattMax);
    noteValue = G4;
    // println("C value (Theta): " + cuantization + "|" + "Theta: " + thetaVal + "|"
    // + raw_theta );
    for (int i = (notePatt[cuantization].length - 1); i >= 0; i--) {
      // The tick is the position of an event in a sequence, is the unit of time
      int tick = notePatt[cuantization][i];
      // Añade un nuevo evento. Note: nota, velocidad, duracion
      g4Track.addEvent(new Note(noteValue, 100, noteLength), tick);
    }
    song.addTrack(g4Track);
  } else if (note.equals("b4")) {
    song.removeTrack(b4Track);
    b4Track = new Track("b4", midiOut);
    b4Track.setQuantization(Q._1_8);
    cuantization = constrain(alphaVal[j], 0, pattMax);
    noteValue = B4;
    // println("C value (Alpha): " + cuantization + "|" + "Alpha " + alphaVal + "|"
    // + raw_alpha);
    for (int i = (notePatt[cuantization].length - 1); i >= 0; i--) {
      // The tick is the position of an event in a sequence, is the unit of time
      int tick = notePatt[cuantization][i];
      // Añade un nuevo evento. Note: nota, velocidad, duracion
      b4Track.addEvent(new Note(noteValue, 100, noteLength), tick);
    }
    song.addTrack(b4Track);
  } else if (note.equals("d5")) {
    song.removeTrack(d5Track);
    d5Track = new Track("d5", midiOut);
    d5Track.setQuantization(Q._1_8);
    cuantization = constrain(betaVal[j], 0, pattMax);
    noteValue = D5;
    // println("C value (Beta): " + cuantization + "|" + "Beta " + betaVal + "|" +
    // raw_beta);
    for (int i = (notePatt[cuantization].length - 1); i >= 0; i--) {
      // The tick is the position of an event in a sequence, is the unit of time
      int tick = notePatt[cuantization][i];
      // Añade un nuevo evento. Note: nota, velocidad, duracion
      d5Track.addEvent(new Note(noteValue, 100, noteLength), tick);
    }
    song.addTrack(d5Track);
  } else if (note.equals("g5Flat")) {
    song.removeTrack(g5FlatTrack);
    g5FlatTrack = new Track("g5Flat", midiOut);
    g5FlatTrack.setQuantization(Q._1_8);
    cuantization = constrain(gammaVal[j], 0, pattMax);
    noteValue = G5Flat;
    // println("C value (G5Flat): " + cuantization + "|" + "Gamma " + gammaVal + "|"
    // + raw_gamma);
    for (int i = (notePatt[cuantization].length - 1); i >= 0; i--) {
      // The tick is the position of an event in a sequence, is the unit of time
      int tick = notePatt[cuantization][i];
      // Añade un nuevo evento. Note: nota, velocidad, duracion
      g5FlatTrack.addEvent(new Note(noteValue, 100, noteLength), tick);
    }
    song.addTrack(g5FlatTrack);
  } else if (note.equals("g2")) {
    song.removeTrack(g2Track);
    g2Track = new Track("g2", midiOut);
    g2Track.setQuantization(Q._1_8);
    cuantization = constrain(deltaVal[j], 0, pattMax);
    noteValue = G2;
    // println("C value (Delta): " + cuantization + "|" + "Delta " + deltaVal + "|"
    // + raw_delta);
    for (int i = (notePatt[cuantization].length - 1); i >= 0; i--) {
      // The tick is the position of an event in a sequence, is the unit of time
      int tick = notePatt[cuantization][i];
      // Añade un nuevo evento. Note: nota, velocidad, duracion
      g2Track.addEvent(new Note(noteValue, 100, noteLength), tick);
    }
    song.addTrack(g2Track);
  } else if (note.equals("d3")) {
    song.removeTrack(d3Track);
    d3Track = new Track("d3", midiOut);
    d3Track.setQuantization(Q._1_8);
    cuantization = constrain(highAlphaVal[j], 0, pattMax);
    noteValue = D3;
    // println("C value (HighAplha): " + cuantization + "|" + "HighAplha " +
    // highAlphaVal + "|" + raw_high_alpha);
    for (int i = (notePatt[cuantization].length - 1); i >= 0; i--) {
      // The tick is the position of an event in a sequence, is the unit of time
      int tick = notePatt[cuantization][i];
      // Añade un nuevo evento. Note: nota, velocidad, duracion
      d3Track.addEvent(new Note(noteValue, 100, noteLength), tick);
    }
    song.addTrack(d3Track);
  } else if (note.equals("g3")) {
    song.removeTrack(g3Track);
    g3Track = new Track("g3", midiOut);
    g3Track.setQuantization(Q._1_8);
    cuantization = constrain(highGammaVal[j], 0, pattMax);
    noteValue = G3;
    // println("C value (MidGamma): " + cuantization + "|" + "MidGamma " +
    // midGammaVal + "|" + raw_mid_gamma);
    for (int i = (notePatt[cuantization].length - 1); i >= 0; i--) {
      // The tick is the position of an event in a sequence, is the unit of time
      int tick = notePatt[cuantization][i];
      // Añade un nuevo evento. Note: nota, velocidad, duracion
      g3Track.addEvent(new Note(noteValue, 100, noteLength), tick);
    }
    song.addTrack(g3Track);
  }
}

void resetPatterns() {
  creatingMusic("g4");
  creatingMusic("b4");
  creatingMusic("d5");
  creatingMusic("g5Flat");
  creatingMusic("g2");
  creatingMusic("d3");
  creatingMusic("g3");
}

// hey look - an array of pattern arrays (a multidimensional array) - COOL!
// These are the note locations/patterns we choose from for each percussion
// instrument
// (we put this @ the bottom just because it's really long & gets in the way)
// Patrones que funcionan como secuenciaas de notas.
// Cada numero determina la ocurrencia una nota dentro de una escala

int notePatt[][] = { 
  { 2 }, 
  { 3 }, 
  { 4 }, 
  { 5 }, 
  { 6 }, 
  { 7 }, 
  { 0, 2 }, 
  { 1, 3 }, 
  { 2, 5 }, 
  { 3, 5 }, 
  { 2, 7 }, 
  { 4, 5 }, 
  { 2, 4 }, 
  { 3, 4 }, 
  { 2, 5 }, 
  { 0, 4, 7 }, 
  { 1, 3, 7 }, 
  { 1, 5, 6 }, 
  { 1, 3, 7 }, 
  { 2, 4, 6 }, 
  { 2, 5, 7 }, 
  { 2, 2, 6 }, 
  { 5, 4, 7 }, 
  { 0, 2, 4, 6 }, 
  { 0, 2, 5, 6 }, 
  { 0, 1, 2, 6 }, 
  { 1, 2, 5, 6 }, 
  { 1, 2, 6, 6 }, 
  { 1, 4, 5, 7 }, 
  { 2, 2, 5, 7 }, 
  { 2, 3, 5, 7 }, 
  { 2, 3, 6, 7 }, 
  { 3, 4, 5, 7 }, 
  { 0, 6, 4, 1, 6 }, 
  { 0, 1, 2, 4, 6 }, 
  { 0, 2, 3, 4, 6 }, 
  { 1, 3, 4, 5, 6 }, 
  { 1, 3, 4, 5, 7 }, 
  { 2, 3, 4, 5, 6 }, 
  { 2, 3, 4, 5, 7 }, 
  { 3, 4, 5, 6, 7 }, 
  { 1, 2, 3, 4, 5, 6 }, 
  { 1, 2, 3, 4, 5, 7 }, 
  { 0, 2, 3, 4, 5, 7 }, 
  { 0, 1, 2, 3, 4, 5 }, 
  { 2, 3, 4, 5, 6, 7 }, 
  { 0, 3, 4, 5, 6, 7 }, 
  { 0, 1, 4, 5, 6, 7 }, 
  { 0, 1, 2, 3, 4, 5, 6 }, 
  { 0, 1, 2, 3, 4, 5, 6 }, 
  { 0, 1, 2, 4, 4, 5, 7 }, 
  { 0, 1, 2, 1, 4, 6, 7 }, 
  { 0, 1, 5, 3, 1, 6, 7 }, 
  { 0, 1, 2, 4, 4, 6, 7 }, 
  { 0, 1, 3, 4, 5, 6, 7 }, 
  { 0, 2, 3, 4, 5, 6, 7 }, 
  { 1, 2, 3, 3, 5, 6, 7 }, 
  { 1, 2, 3, 4, 5, 6, 7 }, 
  { 0, 1, 2, 3, 4, 5, 6, 7 }, // these were duplicated to fill out the list & drumfills in playback
  { 0, 2, 2, 3, 4, 5, 6, 7 }, 
  { 0, 1, 5, 3, 4, 5, 6, 7 }, 
  { 0, 1, 2, 3, 4, 5, 6, 7 }, 
  { 0, 1, 2, 3, 4, 5, 6, 7 }, 
  { 0, 1, 2, 3, 4, 5, 6, 7 }, 
  { 0, 1, 2, 3, 4, 5, 6, 7 }, 
  { 0, 1, 2, 3, 4, 5, 6, 7 }, 
  { 0, 1, 2, 3, 4, 5, 6, 7 }, 
  { 0, 1, 2, 3, 4, 5, 6, 7 }, 
};
