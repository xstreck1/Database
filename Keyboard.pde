
/**
 * Class that represents a single button on the virtual keyboard. Logic of the button itself is handled here.
 */
class Button {
  private int x_pos, y_pos, width_, height_; // Dimensions.n  boolean is_mouse_over = false; 
  private String caption; // Caption of the button, also used as a key string.

  /**
   * Constructor for buttons width specific height and width.
   */
  Button (String o_caption, int o_x, int o_y, int o_width, int o_height) {
    caption = o_caption;
    x_pos = o_x;
    y_pos = o_y;
    width_ = o_width;
    height_ = o_height;
  }

  /**
   * Constructor for the basic, square buttons.
   */
  Button (String o_caption, int o_x, int o_y) {
    caption = o_caption;
    x_pos = o_x;
    y_pos = o_y;
    width_ = height_ = dims.basic_key_size;
  }

  /**
   * Draws the button on the screen.
   */
  public void display(boolean is_mouse_over) {    
    // Choose the highlight color, if requested.
    if (is_mouse_over) {
      fill(settings.getColor("highlight"));
    }
    else {
      fill(settings.getColor("caption"));
    }
    
    // Draw the caption with X in the middle of button, Y being moved down a half of the letter height (basically center) 
    textAlign(CENTER);
    text(caption, x_pos + width_/2, y_pos + (height_ + dims.caps_size)/2);
  }

  /**
   * Tests for collision with the current position of the mouse.
   *
   * @return  true if the mouse is over the button
   */
  public boolean testMousePosition() {
    if (mouseX >= x_pos && mouseX <= x_pos + width_ &&  mouseY >= y_pos && mouseY <= y_pos+height_)
      return true;
    else 
      return false;
  }
  
  /**
   * @return  caption of the button
   */
  public String getCaption() {
    return caption;
  }
}

/**
 * Keyboard is completelly responsible for the appereance and functionallity of the virtual keyboard acessible to user.
 */
public class Keyboard {
  private Vector<Button> buttons = new Vector();; ///< Holder for all the buttons that are actually used.
  private int hover_button = -1; ///< ID of the button that has a mouse over it at the moment. -1 stands for none.

  /**
   * Creates the keyboard itself - from this moment all the buttons are ready to go.
   */
  Keyboard() {
    buttons.clear();
    createButtons();
  }

  /**
   * Creates object representing all the buttons.
   */
  void createButtons() {
    // Create buttons etter buttons.
    char caption = char(65);
    for (int y_counter = 0; y_counter < 3; y_counter++) {
      for (int x_counter = 0; x_counter < 9; x_counter++) {
        if (caption == 92)
          caption = char(95);
        buttons.add(new Button(str(caption++), dims.keyboard_x + x_counter*(dims.basic_key_size), dims.keyboard_y + y_counter*+dims.basic_key_size));
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
    int scroll_button_x = dims.input_y + round(dims.basic_key_size*0.75);
    buttons.add(new Button("<<", 11*dims.basic_key_size + dims.border_x, scroll_button_x + dims.basic_key_size*0, dims.basic_key_size, dims.basic_key_size));
    buttons.add(new Button("<", 11*dims.basic_key_size + dims.border_x, scroll_button_x + dims.basic_key_size*1, dims.basic_key_size, dims.basic_key_size));
    buttons.add(new Button(">", 11*dims.basic_key_size + dims.border_x, scroll_button_x + dims.basic_key_size*2, dims.basic_key_size, dims.basic_key_size));
    buttons.add(new Button(">>", 11*dims.basic_key_size + dims.border_x, scroll_button_x + dims.basic_key_size*3, dims.basic_key_size, dims.basic_key_size));
  }  

  /**
   * Calls the display function for all the buttons in the container.
   */
  void displayButtons() {
    textFont(environment.getCurrentFont(), dims.caps_size);
    for (int i = 0; i < buttons.size(); i++) // Display only this environments buttons - for the one that is hovered over pass that information.
      buttons.get(i).display(i == hover_button);
  }

  /**
   * Mouse moveme resets the currently marked button and sets a new one if the mouse cursor is hovering over it.
   */
  void mouseMove() {
    hover_button = -1; // Reset the current button

    // Search for a hit.
    for (int i = 0; i < buttons.size() && hover_button == -1; i++) {
      if (buttons.get(i).testMousePosition()) {
        hover_button = i; // Set the button.
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

