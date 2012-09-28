/**
 * Class holds layout placement values.
 */
public class Dimensions {
  // Screen sizes
  int width_;
  int height;
  
  // Layout variables
  int border_x; // Space between layout and window horizontally
  int border_y; // Space between layout and window vertically
  int basic_key_size; // Key size
  int caps_size; // GUI text
  int text_size; // I/O text
  int text_indent;  // Space between window and text
  
  int buttons_count; // How many buttons are active
  
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
  
  Dimensions() {
    width_ = settings.screen_width;
    height = settings.screen_height;
    
    buttons_count = 38;
    
    border_y = int(height * 0.05);
    border_x = int(height * 0.05) + int((width_ - height*1.3)/2.0);
    basic_key_size = int(height *0.1);
    caps_size = settings.caps_size;
    text_size = settings.text_size;
    text_indent = 3;
    
    keyboard_x     = border_x;
    keyboard_y     = height - basic_key_size*3 - border_y;
    keyboard_width = basic_key_size*12;
    wide_key_size  = basic_key_size*3;
    input_x        = border_x;
    input_y        = basic_key_size + border_y;
    output_width   = keyboard_width - basic_key_size;
    output_height  = basic_key_size*4;
    lines_count    = (int) ((float) (output_height - text_indent*2)  / (float) text_size);
  }
}


