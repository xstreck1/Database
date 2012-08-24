/**
 * Class that creates and manages virtual keyboard and other buttons
 */
class Keyboard {
  Button[] buttons;
  int hover_button;
  Dimensions dims;

  Keyboard(Dimensions _dims) {
    dims = _dims;
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
        buttons[button_num] = new Button(str(caption), dims.keyboard_x + (x_counter*(dims.key_space*2+dims.basic_key_size)) + dims.key_space, dims.keyboard_y + (y_counter*(dims.key_space*2+dims.basic_key_size)) + dims.key_space);
      }
    }

    // Special input buttons
    buttons[button_num++] = new Button("Potvrd", (9*(dims.key_space*2+dims.basic_key_size)) + dims.key_space + dims.border, dims.keyboard_y + (0*(dims.key_space*2+dims.basic_key_size)) + dims.key_space, 
    dims.wide_key_size, dims.basic_key_size, BUTTON_NOF, BUTTON_NOS, BUTTON_ACF, BUTTON_ACS, TEXT_FILL);                                 
    buttons[button_num++] = new Button("Smaz"  , (9*(dims.key_space*2+dims.basic_key_size)) + dims.key_space + dims.border, dims.keyboard_y + (1*(dims.key_space*2+dims.basic_key_size)) + dims.key_space, 
    dims.wide_key_size, dims.basic_key_size, BUTTON_NOF, BUTTON_NOS, BUTTON_ACF, BUTTON_ACS, TEXT_FILL);
    buttons[button_num++] = new Button("Zrus"  , (9*(dims.key_space*2+dims.basic_key_size)) + dims.key_space + dims.border, dims.keyboard_y + (2*(dims.key_space*2+dims.basic_key_size)) + dims.key_space, 
    dims.wide_key_size, dims.basic_key_size, BUTTON_NOF, BUTTON_NOS, BUTTON_ACF, BUTTON_ACS, TEXT_FILL);

    // Environment language buttons
    buttons[button_num++] = new Button(FONT1, dims.key_space*1 + dims.wide_key_size*0 + dims.border, dims.key_space + dims.border, dims.wide_key_size, dims.basic_key_size, BUTTON_NOF, BUTTON_NOS, BUTTON_ACF, BUTTON_ACS, TEXT_FILL);                                 
    buttons[button_num++] = new Button(FONT2, dims.key_space*3 + dims.wide_key_size*1 + dims.border, dims.key_space + dims.border, dims.wide_key_size, dims.basic_key_size, BUTTON_NOF, BUTTON_NOS, BUTTON_ACF, BUTTON_ACS, TEXT_FILL);   
    buttons[button_num++] = new Button(FONT3, dims.key_space*5 + dims.wide_key_size*2 + dims.border, dims.key_space + dims.border, dims.wide_key_size, dims.basic_key_size, BUTTON_NOF, BUTTON_NOS, BUTTON_ACF, BUTTON_ACS, TEXT_FILL);  
    buttons[button_num++] = new Button(FONT4, dims.key_space*7 + dims.wide_key_size*3 + dims.border, dims.key_space + dims.border, dims.wide_key_size, dims.basic_key_size, BUTTON_NOF, BUTTON_NOS, BUTTON_ACF, BUTTON_ACS, TEXT_FILL);
  
    // Output scroll buttons
    buttons[button_num++] = new Button("▲", (11*(dims.key_space*2+dims.basic_key_size)) + dims.key_space + dims.border, dims.input_y + dims.text_size + dims.key_space*2, dims.basic_key_size, (dims.output_height / 4), 
                                       BUTTON_NOF, BUTTON_NOS, BUTTON_ACF, BUTTON_ACS, TEXT_FILL);
    buttons[button_num++] = new Button("↑", (11*(dims.key_space*2+dims.basic_key_size)) + dims.key_space + dims.border, dims.input_y + dims.text_size + dims.key_space*2 + (dims.output_height / 4), dims.basic_key_size, (dims.output_height / 4), 
                                       BUTTON_NOF, BUTTON_NOS, BUTTON_ACF, BUTTON_ACS, TEXT_FILL);
    buttons[button_num++] = new Button("↓", (11*(dims.key_space*2+dims.basic_key_size)) + dims.key_space + dims.border, dims.input_y + dims.text_size + dims.key_space*2 + (dims.output_height / 4 * 2), dims.basic_key_size, (dims.output_height / 4), 
                                       BUTTON_NOF, BUTTON_NOS, BUTTON_ACF, BUTTON_ACS, TEXT_FILL);
    buttons[button_num++] = new Button("▼", (11*(dims.key_space*2+dims.basic_key_size)) + dims.key_space + dims.border, dims.input_y + dims.text_size + dims.key_space*2 + (dims.output_height / 4 * 3), dims.basic_key_size, dims.output_height - (dims.output_height / 4 * 3), 
                                       BUTTON_NOF, BUTTON_NOS, BUTTON_ACF, BUTTON_ACS, TEXT_FILL);
  }  

  void displayButtons() {
    textFont(environment.getCurrentFont(), dims.font_size);
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
      }
    }
    else if (button.equals("Smaz")) {
      data.eraseLast();
    }
    else if (button.equals("Zrus")) {
      error = "Test";
      data.eraseAll();
    }
    
    else if (button.equals(FONT1) || button.equals(FONT2) || button.equals(FONT3) || button.equals(FONT4)) {
      environment.changeFont(button);
      keyboard.displayButtons();
      data.display();    
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
  color normal_fill, normal_stroke, active_fill, active_stroke, text_fill;
  boolean is_mouse_over = false;
  String caption;

  // Full constructor
  Button (String cap, int xp, int yp, int xs, int ys, color nof, color nos, color acf, color acs, color tf) {
    caption = cap;
    x_pos = xp;
    y_pos = yp;
    x_size = xs;
    y_size = ys;
    normal_fill = nof;
    normal_stroke = nos;
    active_fill = acf;
    active_stroke = acs;
    text_fill = tf;
  }

  // Basic constructor for simpliest buttons
  Button (String cap, int xp, int yp) {
    caption = cap;
    x_pos = xp;
    y_pos = yp;
    x_size = dims.basic_key_size;
    y_size = dims.basic_key_size;
    normal_fill = BUTTON_NOF;
    normal_stroke = BUTTON_NOS;
    active_fill = BUTTON_ACF;
    active_stroke = BUTTON_ACS;
    text_fill = TEXT_FILL;
  }

  void display() {
    if (is_mouse_over) {
      fill(active_fill);
      stroke(active_stroke);
    }
    else {
      fill(normal_fill);
      stroke(normal_stroke);
    }   
    rect(x_pos, y_pos, x_size, y_size); 
    fill(text_fill);
    textAlign(CENTER);
    text(caption, x_pos + (x_size/2), y_pos + (dims.basic_key_size + dims.font_size*3/5)/2);
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
