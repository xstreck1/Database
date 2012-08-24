/**
 * Class that handles I/0 and text formatting 
 */
class Data {
  ArrayList output_stream;  
  String input_stream;
  int first_output;
  Dimensions dims;

  Data(Dimensions _dims) {
    output_stream = new ArrayList();
    input_stream = new String();
    first_output = 0;
    dims = _dims;
  }
  
  //////////////////////////
  // Data-related operations
  void setScreenData() {
    switch (environment.getScreen()) {
      case 1:
        output_stream.clear();
        output("Zadejte uživateské jméno.");       
      break;
      case 2:
        output_stream.clear();
        output("Účet: " + environment.getAccountName() + ", zadejte heslo.");       
      break;
      case 3:
        output_stream.clear();
        output("Vítejte uživateli " + environment.getAccountName() + ". Pro odhlášení zadejte EXIT. Pro vyhledávání zadejte požadované slovo.");       
      break;
    }
  }
  
  // If in the third (database) screen, add data to output, otherwise replace current output with data
  void output(String new_text) {
    if (environment.getScreen() == 3) {
      addToOutput(new_text);
      first_output = max (0, (output_stream.size() - dims.lines_count));
    }
    else {
      output_stream.clear();
      output_stream.add(new_text);
    }
  }
  
  void addToOutput(String new_text) {
     if (textWidth(new_text) <= (dims.output_width-2*dims.text_indent)) {
       output_stream.add(new_text);
     }
     else {
       int subset_length = new_text.length() - 1;
       // while the substrin is too long or can't be spliced, shorten it
       while (textWidth(new_text.substring(0, subset_length)) > (dims.output_width-2*dims.text_indent)
              || Character.isLetter(new_text.charAt(subset_length)))
         subset_length--;
       
       output_stream.add(new_text.substring(0, subset_length+1));
       addToOutput(new_text.substring(subset_length+1));
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
  
  /////////////////////////////
  // Buttons-related operations
  void username() {
    if (environment.accountExists(input_stream)) {
      environment.setAccount(input_stream);
      environment.setScreen(2);
      eraseAll();
    }
    else {
      output("Zadané uživatelské jméno neexistuje. Zadejte nové jméno.");
    }
  }
  
  void password() {
    if (environment.passwordMatches(input_stream)) {
      environment.setScreen(3);
      eraseAll(); 
    }
    else {
      environment.setScreen(1);      
      output("Zadáno špatné heslo. Zadejte uživatelské jméno.");
      eraseAll();
    }
  }
  
  void search() {
    if (input_stream.equals("EXIT")) {
      environment.setScreen(1);
      input_stream = new String();
      return;
    }
    output(input_stream + ": " + (info.findEntry(input_stream, environment.getAccountClereance())));
    display();
  }
  
  void addLetter(char letter) {
    input_stream = input_stream.concat(str(letter));
    if (textWidth(input_stream) > (dims.keyboard_width-2*dims.text_indent)) {
      eraseLast();
      output("Překročena délka vstupního pole.");
    }
  }
  
  void eraseLast() {
    if (input_stream.length() > 0)
      input_stream = input_stream.substring(0,input_stream.length()-1);
  }
  
  void eraseAll() {
    input_stream = new String();
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
    first_output = output_stream.size() - dims.lines_count;
    display();  
  }


  ///////////////////
  // Display function
  void display() {
    textFont(environment.getCurrentFont(), dims.text_size);
    fill(INPUT_FILL);
    stroke(INPUT_STROKE);
        
    switch (environment.getScreen()) {
      case 1:
        rect(dims.input_x, dims.input_y + (dims.keyboard_y - dims.input_y)/2, dims.keyboard_width, dims.text_size); 
        fill(FONT_FILL);
        textAlign(CENTER);
        text((String) output_stream.get(0), (dims.input_x + dims.text_indent*2 + dims.keyboard_width)/2, dims.input_y + (dims.keyboard_y - dims.input_y - dims.text_size)/2);
        textAlign(CENTER);    
        text(input_stream , (dims.input_x + dims.text_indent*2 + dims.keyboard_width)/2, dims.input_y + (dims.keyboard_y - dims.input_y)/2 + (dims.text_size/5*4)); // Y is a little bit higher - whole field is not needed withoud diacritics
      break;      
      
      case 2:
        rect(dims.input_x, dims.input_y + (dims.keyboard_y - dims.input_y)/2, dims.keyboard_width, dims.text_size); 
        fill(FONT_FILL);
        textAlign(CENTER);
        text((String) output_stream.get(0), (dims.input_x + dims.text_indent*2 + dims.keyboard_width)/2, dims.input_y + (dims.keyboard_y - dims.input_y - dims.text_size)/2);
        textAlign(CENTER);    
        text(input_stream , (dims.input_x + dims.text_indent*2 + dims.keyboard_width)/2, dims.input_y + (dims.keyboard_y - dims.input_y)/2 + (dims.text_size/5*4)); // Y is a little bit higher - whole field is not needed withoud diacritics
      break;   
      
      case 3:
        rect(dims.input_x, dims.input_y , dims.keyboard_width, dims.text_size); 
        rect(dims.input_x, dims.input_y + dims.text_size + dims.key_space*2, dims.output_width  , dims.output_height); 
        fill(FONT_FILL);
        textAlign(LEFT);
        text(input_stream, dims.input_x + dims.text_indent, dims.input_y + (dims.text_size/5*4)); // Y is a little bit higher - whole field is not needed withoud diacritics
        for (int i = first_output; i < (min(output_stream.size(), (first_output + dims.lines_count))); i++) {
          text((String) output_stream.get(i), dims.input_x + dims.text_indent, dims.input_y + dims.text_size*(2 + i - first_output) + dims.key_space*2);
        }
      break;
      
      case 4:
        rect(dims.input_x, dims.input_y , dims.keyboard_width, dims.output_height); 
        fill(ERROR_COLOR);
        textAlign(LEFT);
        text(error, dims.input_x + dims.text_indent, dims.input_y + (dims.text_size/5*4));
      break;    
    }
  }
}
