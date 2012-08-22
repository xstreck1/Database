/**
 * Class that handles I/0 and text formatting 
 */
class Data {
  ArrayList output_stream;  
  String input_stream;
  int first_output;

  Data() {
    output_stream = new ArrayList();
    input_stream = new String();
    first_output = 0;
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
      first_output = max (0, (output_stream.size() - LINES_COUNT));
    }
    else {
      output_stream.clear();
      output_stream.add(new_text);
    }
  }
  
  void addToOutput(String new_text) {
     if (textWidth(new_text) <= (OUTPUT_WIDTH-2*TEXT_INTENT)) {
       output_stream.add(new_text);
     }
     else {
       int subset_length = new_text.length() - 1;
       // while the substrin is too long or can't be spliced, shorten it
       while (textWidth(new_text.substring(0, subset_length)) > (OUTPUT_WIDTH-2*TEXT_INTENT)
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
    
    textFont(environment.getCurrentFont(), TEXT_SIZE);
    
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
    if (textWidth(input_stream) > (KEYBOARD_WIDTH-2*TEXT_INTENT)) {
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
    first_output = max (min (first_output + 1, (output_stream.size() - LINES_COUNT)), 0);
    display();  
  }
  
  void scrollLast() {
    first_output = output_stream.size() - LINES_COUNT;
    display();  
  }


  ///////////////////
  // Display function
  void display() {
    textFont(environment.getCurrentFont(), TEXT_SIZE);
    fill(INPUT_FILL);
    stroke(INPUT_STROKE);
        
    switch (environment.getScreen()) {
      case 1:
        rect(INPUT_X, INPUT_Y + (KEYBOARD_Y - INPUT_Y)/2, KEYBOARD_WIDTH, TEXT_SIZE); 
        fill(FONT_FILL);
        textAlign(CENTER);
        text((String) output_stream.get(0), (INPUT_X + TEXT_INTENT*2 + KEYBOARD_WIDTH)/2, INPUT_Y + (KEYBOARD_Y - INPUT_Y - TEXT_SIZE)/2);
        textAlign(CENTER);    
        text(input_stream , (INPUT_X + TEXT_INTENT*2 + KEYBOARD_WIDTH)/2, INPUT_Y + (KEYBOARD_Y - INPUT_Y)/2 + (TEXT_SIZE/5*4)); // Y is a little bit higher - whole field is not needed withoud diacritics
      break;      
      
      case 2:
        rect(INPUT_X, INPUT_Y + (KEYBOARD_Y - INPUT_Y)/2, KEYBOARD_WIDTH, TEXT_SIZE); 
        fill(FONT_FILL);
        textAlign(CENTER);
        text((String) output_stream.get(0), (INPUT_X + TEXT_INTENT*2 + KEYBOARD_WIDTH)/2, INPUT_Y + (KEYBOARD_Y - INPUT_Y - TEXT_SIZE)/2);
        textAlign(CENTER);    
        text(input_stream , (INPUT_X + TEXT_INTENT*2 + KEYBOARD_WIDTH)/2, INPUT_Y + (KEYBOARD_Y - INPUT_Y)/2 + (TEXT_SIZE/5*4)); // Y is a little bit higher - whole field is not needed withoud diacritics
      break;   
      
      case 3:
        rect(INPUT_X, INPUT_Y                          , KEYBOARD_WIDTH, TEXT_SIZE); 
        rect(INPUT_X, INPUT_Y + TEXT_SIZE + KEY_SPACE*2, OUTPUT_WIDTH  , OUTPUT_HEIGHT); 
        fill(FONT_FILL);
        textAlign(LEFT);
        text(input_stream, INPUT_X + TEXT_INTENT, INPUT_Y + (TEXT_SIZE/5*4)); // Y is a little bit higher - whole field is not needed withoud diacritics
        for (int i = first_output; i < (min(output_stream.size(), (first_output + LINES_COUNT))); i++) {
          text((String) output_stream.get(i), INPUT_X + TEXT_INTENT, INPUT_Y + TEXT_SIZE*(2 + i - first_output) + KEY_SPACE*2);
        }
      break;
    }
  }
}
