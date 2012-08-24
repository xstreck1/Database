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
  
  // Layout variables
  int border_x; // Space between layout and window horizontally
  int border_y; // Space between layout and window vertically
  int basic_key_size; // Key size
  int font_size; // GUI text
  int text_size; // I/O text
  int text_indent;  // Space between window and text
  
  // Object placement variables - just for simplicity in reccurent uses
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
    
    border_y = int(height * 0.05);
    border_x = int(height * 0.05) + int((width_ - height*1.3)/2.0);
    basic_key_size = int(height *0.1);
    font_size = 30;
    text_size = 20;
    text_indent = 3;
    
    keyboard_x     = border_x;
    keyboard_y     = height - basic_key_size*3 - border_y;
    keyboard_width = basic_key_size*12;
    wide_key_size  = basic_key_size*3;
    input_x        = border_x;
    input_y        = basic_key_size + border_y; // First possible position
    output_width   = keyboard_width - basic_key_size;
    output_height  = basic_key_size*4;
    lines_count    = (int) ( (float) output_height / (float) text_size);
  }
}

// Strings


