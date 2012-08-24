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
  int text_size; // I/O text
  int text_indent;  // Space between window and text
  
  // Layout varialbes - just for simplicity in reccurent uses
  int keyboard_x;
  int keyboard_y;
  int keyboard_width;
  int wide_key_size;
  int input_x;
  int input_y;
  int output_width;
  int output_height;
  int lines_count;
  
  Dimensions(Settings settings) {
    width_ = settings.screen_width;
    height = settings.screen_height;
    
    border = height / 20;
    key_space = 8;
    basic_key_size = 55;
    font_size = 30;
    text_size = 20;
    text_indent = 3;
    
  // Layout varialbes - just for simplicity in reccurent uses
    keyboard_x     = border;
    keyboard_y     = height - basic_key_size*3 - key_space*6 - border;
    keyboard_width = basic_key_size*12 + key_space*22;
    wide_key_size  = key_space*4 + basic_key_size*3;
    input_x        = key_space + border; // First possible position
    input_y        = basic_key_size + 3*key_space + border; // First possible position
    output_width   = keyboard_width - 2*key_space - basic_key_size;
    output_height  = keyboard_y - (input_y + text_size + key_space*3);
    lines_count    = (int) ( (float) output_height / (float) text_size);
  }
}

// Strings


