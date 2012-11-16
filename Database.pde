import org.xml.sax.XMLReader;
import org.xml.sax.helpers.XMLReaderFactory;
import org.xml.sax.helpers.DefaultHandler;
import org.xml.sax.Attributes;
import org.xml.sax.InputSource;

// Number of frames per second
final int FRAME_RATE = 50; 
// Counter of repetitions of display operation
int draw_count = 0;

// Singular objects that will be used during the computation
// THESE ARE SHARED PROJECT-WISE!
Keyboard    keyboard;
Environment environment;
Data        data;
HTTPHelper  http;
Settings    settings;
Dimensions  dims;

// A list of images cycling on the background
PImage [] background_images;

// A string that is filled if something goes wrong - basically non-intrusive version of an exception. Mainly would be raised if a parsed tag in the settings.xml is unknown.
String error = "";

/**
 * THE ENTRY FUNCTION OF THE APPLICATION
 */ 
@Override
void setup() {
  // Load data
  parseSettings();
  loadBackground();
  
  // Create handling objects
  dims        = new Dimensions();
  keyboard    = new Keyboard();
  environment = new Environment();
  data        = new Data();
  http        = new HTTPHelper();
  
  // Setup graphics
  size(settings.screen_width, settings.screen_height, JAVA2D);
  PImage my_cursor = loadImage("Cursor.png");
  cursor(my_cursor, 16, 16);
  smooth();
  frameRate(FRAME_RATE);
  draw();  
  
  // Start the terminal as required
  environment.setScreen(settings.illegal ? 3 : 1);     
}

@Override
void draw() { 
  // Display error if there is some
  if (!error.isEmpty())
    environment.setScreen(4);  
    
  // Decide current BG image number
  int img_num = ((draw_count % (settings.delay * settings.images_num)) / settings.delay);
  
  // Display the image if there is one
  if (background_images[img_num] != null)
    background(background_images[img_num]);
  else
    background(settings.getColor("background")); 
  
  // Display buttons and data over the background
  keyboard.displayButtons();
  data.display();
  
  // Within a loop, check status from time to time (100 == 2 secs)
  if ((draw_count++ % 100) == 0) {
    // http.check();
  }
}

@Override
void mouseMoved() {
  keyboard.mouseMove();
}

@Override
void mousePressed() {
  keyboard.mousePress();
}

/**
 * Function to get settings from the settings file
 */
void parseSettings() {
  // Create a new settings object - up till now there was none.
  settings = new Settings();
  
  // Setup parser and parse settings
  try {
    XMLReader xr = XMLReaderFactory.createXMLReader();
    XMLParse handler = new XMLParse();
    xr.setContentHandler(handler);
    xr.setErrorHandler(handler);
    xr.parse(new InputSource("settings.xml")); // This call causes the whole parsing process
  }
  catch (Exception e) {
    e.printStackTrace();
    error = e.getMessage(); // Set error if something happenss
  }
  
  // Control if everything that has to be set is set.
  settings.control();
}

/**
 * Load (once) images that will be displayed as a background.
 * Images are to be in the form "width"x"height"_"animation index form 1"."suffix as given in settings"
 */
void loadBackground() {
  // Create space to store the images
  background_images = new PImage[settings.images_num];
  
  // Create prefix of files that will be read
  String file = String.valueOf(settings.screen_width);
  file = file.concat("x");
  file = file.concat(String.valueOf(settings.screen_height));
  
  // Obtain all images as described in the settings
  for (int i = 1; i <= settings.images_num; i++) {
    background_images[i-1] = loadImage(file + "_" + i + settings.image_suffix);
  }
}


