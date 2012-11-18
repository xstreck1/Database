// Resources locations.
final String SETTINGS_FILE = "settings.xml"; ///< The file with all the settings.
final String CURSOR_FILE = "cursor.png"; ///< A picture used as the cursor.
// Background images and fonts are derived from settings.
final int FONT_COUNT = 4; ///< Number of fonts employed.
final String BASIC_FONT_NAME = "Arial.vlw"; ///< Name of the font that is used in default cases.
PFont basic_font; ///< Reference to a program-wise basic font.
PImage [] background_images; ///< An array containing the images rotated on the background.
// Screen identifiers.
final int NAME_SCREEN = 1; ///< Identifier of the screen with the name prompt.
final int PASS_SCREEN = 2; ///< Identifier of the screen with the password prompt.
final int TEXT_SCREEN = 3; ///< Identifier of the screen with the text content.

// Number of frames per second.
final int FRAME_RATE = 50; 
// Counter of repetitions of display operation.
int draw_count = 0;

// Singular objects that will be used during the computation.
// ALL THESE ARE SHARED PROJECT-WISE!
Keyboard    keyboard;
Environment environment;
Data        data;
HTTPHelper  http;
Settings    settings;
Dimensions  dims;

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
  basic_font = loadFont(BASIC_FONT_NAME);
  
  // Create handling objects.
  dims        = new Dimensions();
  keyboard    = new Keyboard();
  environment = new Environment();
  data        = new Data();
  http        = new HTTPHelper();
  
  // Setup graphics.
  size(settings.screen_width, settings.screen_height, JAVA2D);
  cursor(loadImage(CURSOR_FILE), 16, 16);
  smooth();
  frameRate(FRAME_RATE);
  draw();  
  
  // Start the terminal as required.
  environment.setScreen(settings.illegal ? TEXT_SCREEN : NAME_SCREEN);     
}

@Override
void draw() { 
  // Decide current BG image number.
  int img_num = ((draw_count % (settings.delay * settings.images_num)) / settings.delay);
  
  // Display the image if there is one.
  if (background_images[img_num] != null)
    background(background_images[img_num]);
  else
    background(settings.getColor("background")); 
  
  // Display buttons and data over the background.
  keyboard.displayButtons();
  data.display();
  
  // Within a loop, check status from time to time (100 == 2 secs).
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
 * Function to get settings from the settings file.
 */
void parseSettings() {
  // Create a new settings object - up till now there was none.
  settings = new Settings();
  
  // Setup parser and parse settings.
  XMLParser parser = new XMLParser();
  parser.parse(SETTINGS_FILE);
  
  // Control if everything that has to be set is set.
  settings.control(); 
}

/**
 * Load (once) images that will be displayed as a background.
 * Images are to be in the form "width"x"height"_"animation index form 1"."suffix as given in settings"
 */
void loadBackground() {
  // Create space to store the images.
  background_images = new PImage[settings.images_num];
  
  // Create prefix of files that will be read
  String file = String.valueOf(settings.screen_width);
  file = file.concat("x");
  file = file.concat(String.valueOf(settings.screen_height));
  
  // Obtain all images as described in the settings.
  for (int i = 1; i <= settings.images_num; i++) {
    background_images[i-1] = loadImage(file + "_" + i + settings.image_suffix);
  }
}


