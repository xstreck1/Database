/**
 * Class that handles I/0 and text formatting.
 */
class Data {
  private String output_data; ///< Original string previous to being reformed.
  private String output_stream; ///< List of strings, each corresponding to a single line of the output.
  private String input_stream; ///< The string containing the user-given text.
  private int first_output; ///< Ordinal number of the first line that is displayed
  private int lines_count; ///< Vector holds positions of newline symbols in the output_stream

  /**
   * Constructor just assigns empty data to the objects.
   */
  Data() {
    clear();
  }
  
  /**
   * Assigns new objects to the employed references.
   */
  void clear() {
    output_stream = "";
    output_data = "";
    input_stream = "";
    first_output = lines_count = 0;
  }
  
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Input stream manipulation
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  /**
   * Adds a letter to the input text field.
   */
  void addLetter(char letter) {
    input_stream = input_stream + str(letter);
    
    // Check if the text can still be fitted in the field - if not, erase the symbol and prompt the  user.
    if (textWidth(input_stream) > (dims.keyboard_width-2*dims.text_indent)) {
      eraseLast();
      addLine(settings.getText("outofbounds"));
    }
  }
  
  /**
   * Erases the single last symbol from the input stream.
   */
  void eraseLast() {
    if (input_stream.length() > 0)
      input_stream = input_stream.substring(0, input_stream.length() - 1);
  }
  
  /**
   * Erases all the symbols in the input stream.
   */
  void eraseAll() {
    input_stream = new String();
  }
  
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Output stream manipulation
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  /**
   * Reforms the string so it fits the screen. This string is not expected to have any newline symbols!
   *
   * @param new_line  a string containing the original data
   *
   * @return  string separated by newlines 
   */
  private String getSublines(String new_line) {
    lines_count++; // Increament the number of lines present with each call (since it adds a new line)
    // Check wheather it does not fit already.
    if (textWidth(new_line) <= dims.data_width) {
      return (new_line + "\n");
    }
    // If not, take the longest fitting line ended by a space and make it into new line. The rest then recursivly divide again.
    else {
      for (int symbol = 0; symbol < new_line.length(); symbol++) {
        if (textWidth(new_line.substring(0, symbol)) > dims.data_width) {
          int space_pos = new_line.substring(0, symbol).lastIndexOf(' ');
          return (new_line.substring(0, space_pos) + "\n" + getSublines(new_line.substring(space_pos+1)));
        }
      }  
    }
    return null; // Errornous state, will not occur.
  }
  
  /**
   * Takes a string and adds new lines so it fits the screen.
   *
   * @param input_text  a string with the text to change
   *
   * @return  a newly formatted string 
   */
  private String reFormat(String input_text) {
    // Make sure we will measure correctly.
    textFont(environment.getFont().font);
    textSize(dims.text_size);  
    
    // Split to substrings that are already separated.
    String [] lines = input_text.split("\n");
    String formatted_text = "";
    
    // Add each substring, possibly with new newlines.
    for (int i = 0; i < lines.length; i++) {
      formatted_text += getSublines(lines[i]);
    }
    
    return formatted_text;
  }
  
  /**
   * Reformats the string and places it into the ouput container
   */
  void addLine(String new_text) {
    output_data += new_text + "\n";
    output_stream += reFormat(new_text);
    scrollLast();
  }
  
  /**
   * Called to reformat the whole output string to make sure it fits current screen.
   */
  void rebuildOutput() {
    lines_count = 0;
    output_stream = reFormat(output_data);
    scrollLast();
  }
  
  /**
   * Display the output from the first line.
   */
  void scrollFirst() {
    first_output = 0;
  }
  
  /**
   * Display the output from the previous line.
   */  
  void scrollBackwards() {
    first_output = max (first_output - 1, 0); 
  }

  /**
   * Display the output from the next line.
   */  
  void scrollForward() {
    first_output = max (0, min (first_output + 1, lines_count - dims.lines_count)); 
  }
  
  /**
   * Display the output from the first line such that the last line is still visible.
   */    
  void scrollLast() {
    first_output = max(0, lines_count - dims.lines_count);
  }

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Visual
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  /**
   * Displays the content of the input and output fileds.
   */
  void display() {
    // Fill the text fileds with grey overlap.
    noStroke();
    fill(settings.getColor("field"));
    rect(dims.input_x, dims.input_y, dims.keyboard_width, round(dims.text_size*1.25)); 
    rect(dims.input_x, dims.output_y, dims.output_width, dims.output_height); 
    textAlign(LEFT);    
        
    // Display error output if there is any.
    if (!error.isEmpty()) {
      textFont(BASIC_FONT.font, dims.text_size); // Set readable font.
      fill(settings.getColor("error"));
      // Fill the output filed with the error.
      text(error, dims.input_x + dims.text_indent, dims.input_y + settings.text_size - environment.getFont().move);
    } 
    else {
      textFont(environment.getFont().font, dims.text_size);
      fill(settings.getColor("text"));
      
      // Fill the input bar.
      text(input_stream, dims.input_x + dims.text_indent, dims.input_y + round(dims.text_size*0.90));
      
      // From the output string take those substrings that are currently visible.
      String [] substrings = output_stream.split("\n");
      for (int i = 0; (i < dims.lines_count) && (i + first_output < substrings.length); i++)
        text(substrings[i + first_output], dims.input_x + dims.text_indent, dims.output_y + dims.text_size*(i+1) + dims.text_indent - environment.getFont().move);
    }
  }
  
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Getters / Setters
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  final String getInput() {
    return input_stream;
  }
  
  final String getOutput() {
    return output_stream;
  }
}
