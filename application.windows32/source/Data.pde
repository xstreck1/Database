/**
 * Class that handles I/0 and text formatting 
 */
class Data {
  ArrayList output_stream;  
  String input_stream;
  int first_output;

  Data() {
    clear();
  }
  
  void clear() {
    output_stream = new ArrayList();
    output_stream.add("");
    input_stream = new String();
    first_output = 0;
  }
  
  void setScreenData() {
    switch (environment.getScreen()) {
      case 1:
        output_stream.clear();
        output(settings.getText("username"));       
      break;
      case 2:
        output_stream.clear();
        output(settings.getText("password") + environment.getAccountName());       
      break;
      case 3:
        output_stream.clear();
        output(settings.getText("welcome") + environment.getAccountName() + ".");
        output(settings.getText("logoff") );       
      break;
    }
  }
  
  // If in the third (database) screen, add data to output, otherwise replace current output with data
  void output(String new_text) {
    if (environment.getScreen() == 3) {
      new_text.replace('\r', ' ');
      addToOutput(new_text);
      first_output = max (0, (output_stream.size() - dims.lines_count));
    }
    else {
      output_stream.clear();
      output_stream.add(new_text);
    }
  }
  
  void addToOutput(String new_text) {
    if (new_text.indexOf('\n') != -1) {
      if (new_text.indexOf('\n') != 0)
        addToOutput(new_text.substring(0,new_text.indexOf('\n')));
      addToOutput(new_text.substring(new_text.indexOf('\n')+1));     
    }
    else if (textWidth(new_text) <= (dims.output_width-2*dims.text_indent)) {
      output_stream.add(new_text);
    }
    else {
      int subset_length = 0;
      // while the substring is too long or can't be spliced, shorten it
      while (textWidth(new_text.substring(0, subset_length)) < (dims.output_width-2*dims.text_indent))
        subset_length++;
      subset_length--;
      while (subset_length > 0 && Character.isLetter(new_text.charAt(subset_length)))
        subset_length--;    
       
      boolean toAdd = false;
      for (int i = 0; i < subset_length; i++) {
          toAdd = Character.isLetter(new_text.charAt(i)) || Character.isDigit(new_text.charAt(i));
      }     
      if (toAdd) output_stream.add(new_text.substring(0, subset_length));
      addToOutput(new_text.substring(new_text.charAt(subset_length) == ' ' ? subset_length + 1 : subset_length));
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
  
  void username() {
    if (environment.accountExists(input_stream)) {
      environment.setAccount(input_stream);
      environment.setScreen(2);
      eraseAll();
    }
    else {
      output(settings.getText("noname"));
    }
  }
  
  void password() {
    if (environment.passwordMatches(input_stream)) {
      environment.setScreen(3);
      eraseAll(); 
    }
    else {
      environment.setScreen(1);      
      output(settings.getText("wrongpass"));
      eraseAll();
    }
  }
  
  void search() {
    if (input_stream.equals("EXIT")) {
      environment.setScreen(1);
      clear();
      data.output(settings.getText("logoffreset"));
    }
    else {
      output(input_stream + ": " + (http.findEntry(input_stream)));
      display();
    }
  }
  
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

  void display() {
    textFont(environment.getCurrentFont(), dims.text_size);
    fill(settings.getColor("field"));
    noStroke();
    
    switch (environment.getScreen()) {
      case 1:
        rect(dims.input_x, dims.input_y + (dims.keyboard_y - dims.input_y)/2, dims.output_width, dims.text_size); 
        fill(settings.getColor("text"));
        textAlign(CENTER);
        text((String) output_stream.get(0), (dims.input_x + dims.text_indent*2 + dims.output_width)/2, dims.input_y + (dims.keyboard_y - dims.input_y - dims.text_size)/2);
        textAlign(CENTER);    
        text(input_stream , (dims.input_x + dims.text_indent*2 + dims.output_width)/2, dims.input_y + (dims.keyboard_y - dims.input_y)/2 + (dims.text_size/5*4)); // Y is a little bit higher - whole field is not needed withoud diacritics
      break;      
      
      case 2:
        rect(dims.input_x, dims.input_y + (dims.keyboard_y - dims.input_y)/2, dims.output_width, dims.text_size); 
        fill(color(settings.getColor("text")));
        textAlign(CENTER);
        text((String) output_stream.get(0), (dims.input_x + dims.text_indent*2 + dims.output_width)/2, dims.input_y + (dims.keyboard_y - dims.input_y - dims.text_size)/2);
        textAlign(CENTER);    
        text(input_stream , (dims.input_x + dims.text_indent*2 + dims.output_width)/2, dims.input_y + (dims.keyboard_y - dims.input_y)/2 + (dims.text_size/5*4)); // Y is a little bit higher - whole field is not needed withoud diacritics
      break;   
      
      case 3:
        rect(dims.input_x, dims.input_y + int(dims.basic_key_size*0.25), dims.keyboard_width, dims.text_size); 
        rect(dims.input_x, dims.input_y + int(dims.basic_key_size*0.75), dims.output_width, dims.output_height); 
        fill(settings.getColor("text"));
        textAlign(LEFT);
        text(input_stream, dims.input_x + dims.text_indent, dims.input_y + int(dims.basic_key_size*0.25) + dims.text_size*0.8); // Y is a little bit higher - whole field is not needed withoud diacritics
        for (int i = first_output; i < (min(output_stream.size(), (first_output + dims.lines_count))); i++) {
          text((String) output_stream.get(i), dims.input_x + dims.text_indent,  int(dims.basic_key_size*0.75) + dims.input_y + dims.text_size*(1 + i - first_output));
        }
      break;
      
      case 4:
        rect(dims.input_x, dims.input_y + int(dims.basic_key_size*0.25), dims.output_width, dims.output_height + int(dims.basic_key_size*0.5)); 
        fill(settings.getColor("error"));
        textAlign(LEFT);
        text(error, dims.input_x + dims.text_indent, dims.input_y + int(dims.basic_key_size*0.25) + (dims.text_size*0.75));
      break;    
    }
  }
}
