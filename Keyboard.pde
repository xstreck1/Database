
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

/**
 * Keyboard is completelly responsible for the appereance and functionallity of the virtual keyboard acessible to user.
 */
public class Keyboard {
  private final int BUTTONS_COUNT = 38; ///< Number of buttons on the keyboard.
  
  private Vector<Button> buttons; ///< Holder for all the buttons that are actually used.
  private int hover_button; ///< ID of the button that has a mouse over it at the moment.

  /**
   * Creates the keyboard itself - from this moment all the buttons are ready to go.
   */
  Keyboard() {
    buttons = new Vector();
    hover_button = -1; // Set no active button.
    createButtons();
  }

  /**
   * Creates object representing all the buttons.
   */
  void createButtons() {
    int button_num = 0; //< ID of the currently used button.

    // Create buttons etter buttons.
    char caption = char(64);
    for (int y_counter = 0; y_counter < 3; y_counter++) {
      for (int x_counter = 0; x_counter < 9; x_counter++) {
        if (button_num != 26)
          caption += 1;
        else // Last button - space.
        caption = char(95);
        buttons.add(new Button(str(caption), dims.keyboard_x + x_counter*(dims.basic_key_size), dims.keyboard_y + y_counter*+dims.basic_key_size));
      }
    }

    // Special input buttons.
    buttons.add(new Button("Potvrd", 9*dims.basic_key_size + dims.border_x, dims.keyboard_y + 0*dims.basic_key_size, 
    dims.wide_key_size, dims.basic_key_size));                                 
    buttons.add(new Button("Smaz"  , 9*dims.basic_key_size + dims.border_x, dims.keyboard_y + 1*dims.basic_key_size, 
    dims.wide_key_size, dims.basic_key_size));
    buttons.add( new Button("Zrus"  , 9*dims.basic_key_size + dims.border_x, dims.keyboard_y + 2*dims.basic_key_size, 
    dims.wide_key_size, dims.basic_key_size));

    // Environment language buttons.
    buttons.add(new Button(settings.getFont(0), dims.wide_key_size*0 + dims.border_x, dims.border_y, dims.wide_key_size, dims.basic_key_size));                                 
    buttons.add(new Button(settings.getFont(1), dims.wide_key_size*1 + dims.border_x, dims.border_y, dims.wide_key_size, dims.basic_key_size));   
    buttons.add(new Button(settings.getFont(2), dims.wide_key_size*2 + dims.border_x, dims.border_y, dims.wide_key_size, dims.basic_key_size));  
    buttons.add(new Button(settings.getFont(3), dims.wide_key_size*3 + dims.border_x, dims.border_y, dims.wide_key_size, dims.basic_key_size));

    // Output scroll buttons.
    buttons.add(new Button("<<", 11*dims.basic_key_size + dims.border_x, dims.input_y + int(dims.basic_key_size*0.75), dims.basic_key_size, dims.basic_key_size));
    buttons.add(new Button("<", 11*dims.basic_key_size + dims.border_x, dims.input_y + int(dims.basic_key_size*0.75) + dims.basic_key_size, dims.basic_key_size, dims.basic_key_size));
    buttons.add(new Button(">", 11*dims.basic_key_size + dims.border_x, dims.input_y + int(dims.basic_key_size*0.75) + dims.basic_key_size*2, dims.basic_key_size, dims.basic_key_size));
    buttons.add(new Button(">>",  11*dims.basic_key_size + dims.border_x, dims.input_y + int(dims.basic_key_size*0.75) + dims.basic_key_size*3, dims.basic_key_size, dims.basic_key_size));
  }  

  void displayButtons() {
    textFont(environment.getCurrentFont(), dims.caps_size);
    for (int i = 0; i < BUTTONS_COUNT; i++) // Display only this environments buttons
      buttons.get(i).display();
  }

  /**
   * Mouse moveme resets the currently marked button and sets a new one if the mouse cursor is hovering over it.
   */
  void mouseMove() {
    // Turn of the current button.
    if (hover_button != -1) {
      buttons.get(hover_button).highlight(false);
      hover_button = -1; // Reset the button.
    }
  
    // Set a new one, if such is present.
    for (int i = 0; i < BUTTONS_COUNT && hover_button == -1; i++) {
      if (buttons.get(i).testMousePosition()) {
        hover_button = i; // Set the button.
        buttons.get(hover_button).highlight(true);
      }
    }
  }
  
  void mousePress() {
    if (hover_button == -1)
      return;
    
    String button = buttons.get(hover_button).getCaption();
    if (hover_button >= 0 && hover_button < 27) {
      if (hover_button == 26)
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
          environment.setScreen(settings.illegal ? 3 : 1);   
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
      data.first_output = max(0, min(data.first_output, data.output_stream.size() - dims.lines_count));
    }
    else if (button.equals("<<")) {
      data.scrollFirst();
    }
    else if (button.equals("<")) {
      data.scrollBackwards();
    }
    else if (button.equals(">")) {
      data.scrollForward();
    }
    else if (button.equals(">>")) {
      data.scrollLast();
    }
  }
}

