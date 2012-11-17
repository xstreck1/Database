/**
 * Class that handles I/0 and text formatting 
 */
class Data {
  ArrayList output_stream; // List of strings, each corresponding to a single line of the output
  String input_stream; // The string containing the user-given text
  int first_output; // Ordinal number of the first line that is displayed

  /**
   * Constructor just clears objects to the references
   */
  Data() {
    clear();
  }
  
  /**
   * Assigns new objects to the employed references
   */
  void clear() {
    output_stream = new ArrayList();
    input_stream = "";
    first_output = 0;
  }
  
  /**
   * Reset current data based on the screen you are in.
   * Options correspond to username, password, interactive mode and error.
   */
  void setScreenData() {
    switch (environment.getScreen()) {
      case 1: // Username
        clear();
        output(settings.getText("username"));       
        break;
        
      case 2: // Password
        clear();
        output(settings.getText("password") + environment.getAccountName());       
        break;
        
      case 3: // Interface
        clear();
        if (settings.illegal)
          output(settings.getText("welcome") + "???");
        else {
          output(settings.getText("welcome") + environment.getAccountName() + ".");
          output(settings.getText("logoff") );
        }       
        break;
        
      case 4: // Error
        clear();
        output(error);
        error = ""; // After error the user will be allowed to continue normally.      
        break;
    }
  }

  /**
   * Called when the user confirms his typed username.
   * Just moves to the password screen.
   * TODO: Move to Keyboard.
   */
  void username() {
    environment.setAccount(input_stream);
    environment.setScreen(2);
  }
  
  /**
   * Called when the user confirms the typed in password.
   * Control if the user has the access rights - currently take both DENIED and NOT and OK, but sth else should be put here.
   * TODO: Move to Keyboard.
   */
  void password() {
    environment.password = input_stream;
    String valid = http.findEntry("ACCOUNT_VALID");
    if (valid.substring(0,6).contentEquals("DENIED") || valid.substring(0,2).contentEquals("OK") || valid.substring(0,3).contentEquals("NOT")) {
      environment.setScreen(3);
    }
    else {
      environment.setScreen(1);   
      output(settings.getText("wronglogin"));
    }
  }
  
  /**
   * Called when the user confirms the search of the input.
   * TODO: Move to Keyboard.
   */
  void search() {
    if (input_stream.equals("EXIT")) {
      if (settings.illegal)
        output(settings.getText("illegallogoff"));
      else {
        environment.setScreen(1);
        clear();
        output(settings.getText("logoffreset"));
      }
    }
    else {
      String result = http.findEntry(input_stream);
      if (result.substring(0,2).contentEquals("OK")) {
        output(input_stream + ": " + result.substring(3));
      } else if (result.substring(0,6).contentEquals("DENIED")) {
        output(input_stream + ": " + settings.getText("denied"));
      } else if (result.substring(0,6).contentEquals("NOT FOUND")) {
        output(input_stream + ": " + settings.getText("notfound"));
      } else if (result.substring(0,6).contentEquals("CORRUPTED")) {
        output(input_stream + ": " + settings.getText("corrupted"));
      }
      display();
    }
  }
  
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Input stream manipulation
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  void addLetter(char letter) {
    input_stream = input_stream.concat(str(letter));
    if (textWidth(input_stream) > (dims.keyboard_width-2*dims.text_indent)) {
      eraseLast();
      output(settings.getText("outofbounds"));
    }
  }
  
  void eraseLast() {
    if (input_stream.length() > 0)
      input_stream = input_stream.substring(0,input_stream.length()-1);
  }
  
  void eraseAll() {
    input_stream = new String();
  }
  
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Output stream manipulation
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
  /**
   * Reformats the string and places it into the ouput container
   */
  void output(String new_text) {
    // Remove newline symbols from the string
    new_text.replace('\n', ' ');
    new_text.replace('\r', ' ');
    // Add the text to the output
    addToOutput(new_text);
    first_output = max (0, (output_stream.size() - dims.lines_count));
  }
  
  /**
   *
   */
  void addToOutput(String new_text) {
    if ((new_text.indexOf('\n') != -1) && (new_text.indexOf('\n') != new_text.length() - 1)) {
      if (new_text.indexOf('\n') != 0)
        addToOutput(new_text.substring(0,new_text.indexOf('\n')));
      addToOutput(new_text.substring(new_text.indexOf('\n')+1));     
    }
    else if (textWidth(new_text) <= (dims.output_width-2*dims.text_indent)) {
      output_stream.add(new_text + "\n");
    }
    else {
      int subset_length = 0;
      // while the substring is too long or can't be spliced, shorten it
      while ((textWidth(new_text.substring(0, subset_length)) < (dims.output_width-2*dims.text_indent)) && (subset_length < new_text.length()))
        subset_length++;
      subset_length--;
      while (subset_length > 0 && Character.isLetter(new_text.charAt(subset_length)))
        subset_length--;    
       
      boolean toAdd = false;
      for (int i = 0; i < subset_length; i++) {
          toAdd = Character.isLetter(new_text.charAt(i)) || Character.isDigit(new_text.charAt(i));
      }
      
      if (new_text.charAt(subset_length) == ' ')
        subset_length++;
      if (toAdd)
        output_stream.add(new_text.substring(0, subset_length));
      addToOutput(new_text.substring(subset_length));
    }
  }
  
  void reFormatOutput() {
    String output_content = new String();
    for (int i = 0; i < output_stream.size(); i++) {
      output_content = output_content.concat((String) output_stream.get(i));
    }
    output_stream.clear();
    
    textFont(environment.getCurrentFont(), dims.text_size);
    
    addToOutput(output_content);
  }

  void scrollFirst() {
    first_output = 0;
    display();  
  }
  
  void scrollBackwards() {
    first_output = max (first_output - 1, 0);
    display();  
  }
  
  void scrollForward() {
    first_output = max (min (first_output + 1, (output_stream.size() - dims.lines_count)), 0);
    display();  
  }
  
  void scrollLast() {
    first_output = max(0, output_stream.size() - dims.lines_count);
    display();  
  }

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Visual
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  void display() {
    textFont(environment.getCurrentFont(), dims.text_size);
    noStroke();
    fill(settings.getColor("field"));
    rect(dims.input_x, dims.input_y + int(dims.basic_key_size*0.25), dims.keyboard_width, dims.text_size); 
    rect(dims.input_x, dims.input_y + int(dims.basic_key_size*0.75), dims.output_width, dims.output_height); 
        
    switch (environment.getScreen()) {
      case 1: case 2:  case 3:
        fill(settings.getColor("text"));
        textAlign(LEFT);
        text(input_stream, dims.input_x + dims.text_indent, dims.input_y + int(dims.basic_key_size*0.25) + dims.text_size*0.8);
        for (int i = first_output; i < (min(output_stream.size(), (first_output + dims.lines_count))); i++) {
          text((String) output_stream.get(i), dims.input_x + dims.text_indent,  int(dims.basic_key_size*0.75) + dims.input_y + dims.text_size*(1 + i - first_output));
        }
      break;
      
      case 4:
        fill(settings.getColor("error"));
        textAlign(LEFT);
        for (int i = first_output; i < (min(output_stream.size(), (first_output + dims.lines_count))); i++) {
          text((String) output_stream.get(i), dims.input_x + dims.text_indent,  int(dims.basic_key_size*0.75) + dims.input_y + dims.text_size*(1 + i - first_output));
        }
      break;
      
      case 5:
        fill(settings.getColor("text"));
        textAlign(LEFT);
        text(input_stream, dims.input_x + dims.text_indent, dims.input_y + int(dims.basic_key_size*0.25) + dims.text_size*0.8);
        fill(settings.getColor("offline"));
        textAlign(CENTER);
        textSize(250);
        text("OFF", dims.input_x + dims.output_width/2,  int(dims.basic_key_size*0.75) + dims.input_y + dims.output_height/2 + 80);
      break;
    }
  }
}
