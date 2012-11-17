/**
 * Class holds layout placement values.
 */
public class Dimensions {
  // Screen dimensions
  int width_;
  int height_;

  // Layout variables - THESE ARE SET
  int border_x; // Space between layout and window horizontally
  int border_y; // Space between layout and window vertically
  int basic_key_size; // Key size
  int caps_size; // GUI text
  int text_size; // I/O text
  final int text_indent = 3;  // Space between window and text
  final int buttons_count = 38; // How many buttons are active

  // Object placement variables - just for simplicity in reccurent uses - THESE ARE COMPUTED
  int keyboard_x; // Leftmost corner x position of the virtual keyboard
  int keyboard_y; // Leftmost corner y position of the virtual keyboard
  int keyboard_width; // Leftmost corner y position of the virtual keyboard
  int wide_key_size; // Size of the bigger key (e.g. "erase")
  int input_x; // Leftmost corner x position of the input filed
  int input_y; // Leftmost corner y position of the input filed
  int output_width; // Width of the output field
  int output_height; // Height of the output field
  int lines_count; // Number of lines in the output filed

  /**
   * The constructor sets the values.
   */
  Dimensions() {
    // Obtain the size from settings
    width_ = settings.screen_width;
    height_ = settings.screen_height;

    // Relate basic values to this setting
    border_y = round(height_ * 0.05);
    border_x = round(height_ * 0.05) + round((width_ - height_*1.3)/2.0);
    basic_key_size = round(height_ *0.1);
    caps_size = settings.caps_size;
    text_size = settings.text_size;

    // Compute helping values from the basic ones.
    keyboard_x     = border_x;
    keyboard_y     = height_ - basic_key_size*3 - border_y;
    keyboard_width = basic_key_size*12;
    wide_key_size  = basic_key_size*3;
    input_x        = border_x;
    input_y        = basic_key_size + border_y;
    output_width   = keyboard_width - basic_key_size;
    output_height  = basic_key_size*4;
    lines_count    = (int) ((float) (output_height - text_indent*2)  / (float) text_size);
  }
}

