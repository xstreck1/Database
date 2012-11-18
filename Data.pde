/**
 * Class that handles I/0 and text formatting.
 */
class Data {
  private String output_data; ///< Original string previous to being reformed.
  private String output_stream; ///< List of strings, each corresponding to a single line of the output.
  private String input_stream; ///< The string containing the user-given text.
  private int first_output; ///< Ordinal number of the first line that is displayed

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
    first_output = 0;
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
  
  private String getSublines(String new_line) {
    if (textWidth(new_line) <= dims.data_width) {
      return (new_line + "\n");
    }
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
  
  String reFormat(String input_text) {
    textFont(environment.getFont());
    textSize(dims.text_size);  
    
    String [] lines = input_text.split("\n");
    String formatted_text = "";
     
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
  }
  
  void rebuildOutput() {
    output_stream = reFormat(output_data);
    // print("Data: " + output_data);
    // print("Stream: " + output_stream);
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
    // first_output = max (min (first_output + 1, (output_stream.size() - dims.lines_count)), 0); 
  }
  
  /**
   * Display the output from the first line such that the last line is still visible.
   */    
  void scrollLast() {
    // first_output = max(0, output_stream.size() - dims.lines_count);
  }

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Visual
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  void display() {
    // Fill the text fileds with grey overlap.
    noStroke();
    fill(settings.getColor("field"));
    rect(dims.input_x, dims.input_y + round(dims.basic_key_size*0.25), dims.keyboard_width, dims.text_size); 
    rect(dims.input_x, dims.input_y + round(dims.basic_key_size*0.75), dims.output_width, dims.output_height); 
        
    textAlign(LEFT);    
        
    // Display error output if there is any.
    if (!error.isEmpty()) {
      textFont(basic_font, dims.text_size);
      fill(settings.getColor("error"));
      text(error, dims.input_x + dims.text_indent, int(dims.basic_key_size*0.75) + dims.input_y + settings.text_size);
    } 
    else {
      textFont(environment.getFont(), dims.text_size);
      fill(settings.getColor("text"));
      
      text(input_stream, dims.input_x + dims.text_indent, dims.input_y + round(dims.basic_key_size*0.25) + dims.text_size*0.8);
      text(output_stream, dims.input_x + dims.text_indent, dims.input_y + round(dims.basic_key_size*0.75) + dims.text_size);
    }
  }
  
  final String getInput() {
    return input_stream;
  }
  
  final String getOutput() {
    return output_stream;
  }
}
