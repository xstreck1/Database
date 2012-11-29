/**
 * Class holds layout placement values.
 */
public class Dimensions {
  // Screen dimensions
  int width_; ///< Width of the window itself.
  int height_; ///< Height of the window itself.

  // Layout variables - THESE ARE SET IN THE SETTINGS
  int border_x; ///< Space between layout and window horizontally.
  int border_y; ///< Space between layout and window vertically.
  int basic_key_size; ///< Key size.
  int caps_size; ///< GUI text.
  int text_size; ///< I/O text.
  final int text_indent = 5;  ///< Space between window and text.

  // Object placement variables - just for simplicity in reccurent uses - THESE ARE COMPUTED.
  int keyboard_x; ///< Leftmost corner x position of the virtual keyboard.
  int keyboard_y; ///< Leftmost corner y position of the virtual keyboard.
  int keyboard_width; ///< Leftmost corner y position of the virtual keyboard.
  int wide_key_size; ///< Size of the bigger key (e.g. "erase").
  int input_x; ///< Leftmost corner x position of the input filed.
  int input_y; ///< Leftmost corner y position of the input filed.
  int output_x; ///< Leftmost corner x position of the output filed.
  int output_y; ///< Leftmost corner y position of the output filed.  
  int output_width; ///< Width of the output field.
  int output_height; ///< Height of the output field.
  int data_width; ///< Width of the output text.
  int data_height; ///< Height of the output text.
  int lines_count; ///< Number of lines in the output filed.

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
    keyboard_y     = height_ - basic_key_size*4 - border_y;
    keyboard_width = basic_key_size*12;
    wide_key_size  = basic_key_size*3;
    input_x        = border_x;
    input_y        = round(basic_key_size*1.25) + border_y;
    output_x       = border_x;
    output_y       = round(basic_key_size*1.75) + border_y;
    output_width   = keyboard_width - basic_key_size;
    output_height  = basic_key_size*3;
    data_width     = output_width - 2*text_indent;
    data_height    = output_height - 2*text_indent;;    
    lines_count    = data_height / text_size; // This is tweaked a bit to make sure no overlap occurs in the bottom.
  }
}

