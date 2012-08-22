/**
 * Database that will contain all the game information.
 */

import java.lang.Exception;
import java.lang.Character;
import java.util.ArrayList;
import java.net.URL;
import java.net.HttpURLConnection;

Keyboard    keyboard;
Environment environment;
Data        data;
Information info;
HTTPHelper  http;
String error;

/**
 * Callback functions
 */
void setup() {
  // Application attributes setup
  size(WINDOW_WIDTH, WINDOW_HEIGHT, JAVA2D);
  PImage my_cursor = loadImage(CURSOR1);
  cursor(my_cursor, 16, 16);
  smooth();

  // Create global objects
  keyboard    = new Keyboard();
  environment = new Environment();
  data        = new Data();
  info        = new Information();
  http        = new HTTPHelper();
  
  error = new String();
  
  try {
    println(http.connect(new String("http://www.fi.muni.cz/~xstreck1/")));
  }
  catch (Exception e) {
    e.printStackTrace();
    error = e.getMessage();
  }
  
  draw();  
  environment.setScreen(1); 
}

void draw() {
  if (error.isEmpty()) {
    background(BG_COLOR);
    keyboard.displayButtons();
    data.display();
  }
  else {
    // TODO add string output
    background(ERROR_COLOR);  
    PFont f = createFont("Arial",30,true);  
    textFont(f);
    fill(#000000);
    textAlign(CENTER);
    text(error, 0, 100, WINDOW_WIDTH, WINDOW_HEIGHT);
  }
}

void mouseMoved() {
  keyboard.mouseMove();
}

void mousePressed() {
  keyboard.mousePress();
}


