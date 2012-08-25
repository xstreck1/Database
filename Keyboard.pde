/**
 * Class that creates and manages virtual keyboard and other buttons
 */
class Keyboard {
  Button[] buttons;
  int hover_button;

  Keyboard() {
    createButtons();
    hover_button = BUTTON_COUNT;
  }

  void createButtons() {
    buttons = new Button [BUTTON_COUNT];
    int button_num = 0;

    // Basic input buttons
    char caption = char(64);
    for (int y_counter = 0; y_counter < BUTTON_ROWS; y_counter++) {
      for (int x_counter = 0; x_counter < BUTTON_COLUMNS; x_counter++, button_num++) {
        if (button_num != 26)
          caption += 1;
        else // Last button - space
        caption = char(95);
        buttons[button_num] = new Button(str(caption), dims.keyboard_x + x_counter*(dims.basic_key_size), dims.keyboard_y + y_counter*+dims.basic_key_size);
      }
    }

    // Special input buttons
    buttons[button_num++] = new Button("Potvrd", 9*dims.basic_key_size + dims.border_x, dims.keyboard_y + 0*dims.basic_key_size, 
    dims.wide_key_size, dims.basic_key_size);                                 
    buttons[button_num++] = new Button("Smaz"  , 9*dims.basic_key_size + dims.border_x, dims.keyboard_y + 1*dims.basic_key_size, 
    dims.wide_key_size, dims.basic_key_size);
    buttons[button_num++] = new Button("Zrus"  , 9*dims.basic_key_size + dims.border_x, dims.keyboard_y + 2*dims.basic_key_size, 
    dims.wide_key_size, dims.basic_key_size);

    // Environment language buttons
    buttons[button_num++] = new Button(settings.getFont(0), dims.wide_key_size*0 + dims.border_x, dims.border_y, dims.wide_key_size, dims.basic_key_size);                                 
    buttons[button_num++] = new Button(settings.getFont(1), dims.wide_key_size*1 + dims.border_x, dims.border_y, dims.wide_key_size, dims.basic_key_size);   
    buttons[button_num++] = new Button(settings.getFont(2), dims.wide_key_size*2 + dims.border_x, dims.border_y, dims.wide_key_size, dims.basic_key_size);  
    buttons[button_num++] = new Button(settings.getFont(3), dims.wide_key_size*3 + dims.border_x, dims.border_y, dims.wide_key_size, dims.basic_key_size);

    // Output scroll buttons
    buttons[button_num++] = new Button("▲", 11*dims.basic_key_size + dims.border_x, dims.input_y + int(dims.basic_key_size*0.75), dims.basic_key_size, dims.basic_key_size);
    buttons[button_num++] = new Button("↑", 11*dims.basic_key_size + dims.border_x, dims.input_y + int(dims.basic_key_size*0.75) + dims.basic_key_size, dims.basic_key_size, dims.basic_key_size);
    buttons[button_num++] = new Button("↓", 11*dims.basic_key_size + dims.border_x, dims.input_y + int(dims.basic_key_size*0.75) + dims.basic_key_size*2, dims.basic_key_size, dims.basic_key_size);
    buttons[button_num++] = new Button("▼",  11*dims.basic_key_size + dims.border_x, dims.input_y + int(dims.basic_key_size*0.75) + dims.basic_key_size*3, dims.basic_key_size, dims.basic_key_size);
  }  

  void displayButtons() {
    textFont(environment.getCurrentFont(), dims.caps_size);
    for (int i = 0; i < environment.getButtonsCount(); i++) // Display only this environments buttons
      buttons[i].display();
  }

  void mouseMove() {
    int i;
    for (i = 0; i < environment.getButtonsCount(); i++)
      if (buttons[i].testMousePosition())
        break;
    if (i != hover_button) {
      if (hover_button != BUTTON_COUNT) // Mouse was off buttons
        buttons[hover_button].highlight(false);
      if (i != BUTTON_COUNT) // Mouse is now off buttons
        buttons[i].highlight(true);
      hover_button = i;
    }
  }
  
  void mousePress() {
    if (hover_button == BUTTON_COUNT)
      return;
    
    String button = buttons[hover_button].getCaption();
    if (hover_button >= 0 && hover_button < BUTTON_COLUMNS*BUTTON_ROWS) {
      if (hover_button == (BUTTON_COLUMNS*BUTTON_ROWS-1))
        data.addLetter(' ');
      else
        data.addLetter(button.charAt(0));
    }
    else if (button.equals("Potvrd")) {
        switch (environment.getScreen()) {
        case 1:
          data.username();      
        break;
        case 2:
          data.password();      
        break;
        case 3:
          data.search();  
        break;
        case 4:
          error = "";
          environment.setScreen(1);  
        break;
      }
    }
    else if (button.equals("Smaz")) {
      data.eraseLast();
    }
    else if (button.equals("Zrus")) {
      data.eraseAll();
    }
    
    else if (button.equals(settings.getFont(0)) || button.equals(settings.getFont(1)) || button.equals(settings.getFont(2)) || button.equals(settings.getFont(3))) {
      environment.changeFont(button);
      data.reFormatOutput(); 
      data.first_output = min(data.first_output, data.output_stream.size() - dims.lines_count);
    }
    else if (button.equals("▲")) {
      data.scrollFirst();
    }
    else if (button.equals("↑")) {
      data.scrollBackwards();
    }
    else if (button.equals("↓")) {
      data.scrollForward();
    }
    else if (button.equals("▼")) {
      data.scrollLast();
    }
  }
}

/**
 * Class for all button objects
 */
class Button {
  int x_pos, y_pos, x_size, y_size;
  boolean is_mouse_over = false;
  String caption;

  // Full constructor
  Button (String cap, int xp, int yp, int xs, int ys) {
    caption = cap;
    x_pos = xp;
    y_pos = yp;
    x_size = xs;
    y_size = ys;
  }

  // Basic constructor for simpliest buttons
  Button (String cap, int xp, int yp) {
    caption = cap;
    x_pos = xp;
    y_pos = yp;
    x_size = dims.basic_key_size;
    y_size = dims.basic_key_size;
  }

  void display() {
    // fill(BG_COLOR);
    // noStroke();
    // stroke(BUTTON_ACS);
    // rect(x_pos, y_pos, x_size, y_size); 
    
    textAlign(CENTER);
    if (is_mouse_over) {
      fill(settings.getColor("highlight"));
    }
    else {
      fill(settings.getColor("caption"));
    }   
    text(caption, x_pos + (x_size/2), y_pos + (dims.basic_key_size + dims.caps_size*3/5)/2);
  }

  boolean testMousePosition() {
    if (mouseX >= x_pos && mouseX <= x_pos + x_size &&  mouseY >= y_pos && mouseY <= y_pos+y_size)
      return true;
    else 
      return false;
  }

  void highlight(boolean on) {
    is_mouse_over = on;
  }
  
  String getCaption() {
    return caption;
  }
}
