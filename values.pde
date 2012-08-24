// Coloring
final color BG_COLOR     = #020014; // Basic background
final color ERROR_COLOR  = #FF1111; // Color of error text
final color BUTTON_NOF   = #040026; // Non-active fill
final color BUTTON_NOS   = #5277FF; // Non-active stroke
final color BUTTON_ACF   = #243269; // Active fill
final color BUTTON_ACS   = #6791FF; // Active stroke
final color INPUT_FILL   = #FFFFFF; // I/O fields
final color INPUT_STROKE = #5277FF; // I/O fields
final color FONT_FILL    = #5277FF; // I/O text
final color TEXT_FILL    = #DDEEFF; // GUI text

// Keyboard values
final int BUTTON_COLUMNS = 9;
final int BUTTON_ROWS    = 3;
final int BUTTON_COUNT   = BUTTON_COLUMNS*BUTTON_ROWS+11;

// Environment values
final String FONT1   = "Ghetto";
final String FONT2   = "Vlada";
final String FONT3   = "Nobilia";
final String FONT4   = "Mafie";
final String CURSOR1 = "Cursor.png";

// Data values
final int SEC_LEVELS = 2;

public class Dimensions {
  int width_;
  int height;
  
  // Layout constants
  int border; // Space between layout and window
  int key_space; // Border of the key (2* between keys)
  int basic_key_size; // Key size
  int font_size; // GUI text
  final int TEXT_SIZE      = 20; // I/O text
  final int TEXT_INTENT    = 3;  // Space between window and text
  
  // Layout varialbes - just for simplicity in reccurent uses
  int KEYBOARD_X     = BORDER;
  int KEYBOARD_Y     = WINDOW_HEIGHT - BASIC_KEY_SIZE*3 - KEY_SPACE*6 - BORDER;
  int KEYBOARD_WIDTH = BASIC_KEY_SIZE*12 + KEY_SPACE*22;
  int WIDE_KEY_SIZE  = KEY_SPACE*4 + BASIC_KEY_SIZE*3;
  int INPUT_X        = KEY_SPACE + BORDER; // First possible position
  int INPUT_Y        = BASIC_KEY_SIZE + 3*KEY_SPACE + BORDER; // First possible position
  int WINDOW_WIDTH   = BORDER*2 + KEY_SPACE*2 + BASIC_KEY_SIZE*12 + KEY_SPACE*22;
  int OUTPUT_WIDTH   = KEYBOARD_WIDTH - 2*KEY_SPACE - BASIC_KEY_SIZE;
  int OUTPUT_HEIGHT  = KEYBOARD_Y - (INPUT_Y + TEXT_SIZE + KEY_SPACE*3);
  int LINES_COUNT    = (int) ( (float) OUTPUT_HEIGHT / (float) TEXT_SIZE);
  
  Dimensions(Settings settings) {
    width_ = settings.screen_width;
    height = settings.screen_height;
    
    border = height / 20;
    key_space = 8;
    basic_key_size = 55;
    font_size = 30;
    text_size = 20;
  }
  
  public void compute(){
  }
}

// Strings


