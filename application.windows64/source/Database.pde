import org.xml.sax.XMLReader;
import org.xml.sax.helpers.XMLReaderFactory;
import org.xml.sax.helpers.DefaultHandler;
import org.xml.sax.Attributes;
import org.xml.sax.InputSource;

Keyboard    keyboard;
Environment environment;
Data        data;
HTTPHelper  http;
Settings    settings;
Dimensions  dims;

PImage background_image;
String error;
int draw_count = 0;

void parseSettings() {
  settings = new Settings();
  
  // Setup parser and parse settings
  try {
    XMLReader xr = XMLReaderFactory.createXMLReader();
    XMLParse handler = new XMLParse();
    xr.setContentHandler(handler);
    xr.setErrorHandler(handler);
    xr.parse(new InputSource("settings.xml"));
  }
  catch (Exception e) {
    e.printStackTrace();
    error = e.getMessage();
  } 
}

void loadBackground() {
  String file = String.valueOf(settings.screen_width);
  file = file.concat("x");
  file = file.concat(String.valueOf(settings.screen_height));
  file = file.concat(".png");
  
  background_image = loadImage(file);
}

void setup() {
  error = "";
  parseSettings();
  loadBackground();
  
  dims = new Dimensions();
  keyboard    = new Keyboard();
  environment = new Environment();
  data        = new Data();
  http        = new HTTPHelper();
  
  size(settings.screen_width, settings.screen_height, JAVA2D);
  PImage my_cursor = loadImage("Cursor.png");
  cursor(my_cursor, 16, 16);
  smooth();
  
  environment.setScreen(settings.illegal ? 3 : 1);     
  draw();  
}

void draw() {
  if (!error.isEmpty())
    environment.setScreen(4);  
  if (background_image != null)
    background(background_image);
  keyboard.displayButtons();
  data.display();
  
  // Within a loop, check status from time to time (100 == 2 secs)
  if (draw_count++ > 100) {
    http.check();
    draw_count = 0;
  }
}

void mouseMoved() {
  keyboard.mouseMove();
}

void mousePressed() {
  keyboard.mousePress();
}


