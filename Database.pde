import java.lang.Exception;
import java.lang.Character;
import java.util.ArrayList;
import java.net.URL;
import java.net.HttpURLConnection;
import java.io.FileReader;
import org.xml.sax.XMLReader;
import org.xml.sax.Attributes;
import org.xml.sax.InputSource;
import org.xml.sax.helpers.XMLReaderFactory;
import org.xml.sax.helpers.DefaultHandler;

Keyboard    keyboard;
Environment environment;
Data        data;
HTTPHelper  http;
Settings    settings;
Dimensions  dims;

String error;

void parseSettings() {
  settings = new Settings();
  
  // Setup parser and parse settings
  try {
    XMLReader xr = XMLReaderFactory.createXMLReader();
    XMLParse handler = new XMLParse(settings);
    xr.setContentHandler(handler);
    xr.setErrorHandler(handler);
    xr.parse(new InputSource("settings.xml"));
  }
  catch (Exception e) {
    e.printStackTrace();
    error = e.getMessage();
  } 
}

void setup() {
  parseSettings();
  
  dims = new Dimensions(settings);
  
  // Create global objects
  keyboard    = new Keyboard(dims);
  environment = new Environment(dims);
  data        = new Data(dims);
  
  http        = new HTTPHelper();
  error       = "";

  // Application attributes setup
  size(settings.screen_width, settings.screen_height, JAVA2D);
  PImage my_cursor = loadImage(CURSOR1);
  cursor(my_cursor, 16, 16);
  smooth();
  
  // Setup Connection
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
  if (!error.isEmpty())
    environment.setScreen(4);  
    
  background(BG_COLOR);
  keyboard.displayButtons();
  data.display();
}

void mouseMoved() {
  keyboard.mouseMove();
}

void mousePressed() {
  keyboard.mousePress();
}


