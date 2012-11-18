/**
 * Keyboard is completelly responsible for the appereance and functionallity of the virtual keyboard acessible to user.
 */
public class Keyboard {
  private Vector<Button> buttons = new Vector();
  ; ///< Holder for all the buttons that are actually used.
  private int hover_button = -1; ///< ID of the button that has a mouse over it at the moment. -1 stands for none.

  // ASCII codes for some important positions
  private final char ALPHA_BEGIN = 65;
  private final char ALPHA_END = 91;
  private final char SPACE = '_';

  // Dimensions, in the number of buttons, of the keyboard.
  private final int BOARD_WIDTH = 9;
  private final int BOARD_HEIGHT = 3; 

  // Strings for some action buttons.
  private final String CONFIRM = "Potvrd";
  private final String ERASE = "Smaz";
  private final String KILL = "Zrus";
  private final String FIRST = "<<";
  private final String PREV = "<";
  private final String NEXT = ">";
  private final String LAST = ">>";

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
    char caption = char(ALPHA_BEGIN);

    // Build the buttons
    for (int y_counter = 0; y_counter < BOARD_HEIGHT; y_counter++) {
      for (int x_counter = 0; x_counter < BOARD_WIDTH; x_counter++) {
        // Change the last button for the space
        if (caption == ALPHA_END)
          caption = char(SPACE);

        // Add a button with the character given by the caption variable and position in based on the loop.
        buttons.add(new Button(str(caption++), dims.keyboard_x + x_counter*(dims.basic_key_size), dims.keyboard_y + y_counter*+dims.basic_key_size));
      }
    }

    // Special input buttons.
    buttons.add(new Button(CONFIRM, 9*dims.basic_key_size + dims.border_x, dims.keyboard_y + 0*dims.basic_key_size, dims.wide_key_size, dims.basic_key_size));                                 
    buttons.add(new Button(ERASE, 9*dims.basic_key_size + dims.border_x, dims.keyboard_y + 1*dims.basic_key_size, dims.wide_key_size, dims.basic_key_size));
    buttons.add(new Button(KILL, 9*dims.basic_key_size + dims.border_x, dims.keyboard_y + 2*dims.basic_key_size, dims.wide_key_size, dims.basic_key_size));

    // Environment language buttons.
    for (int i = 0; i < FONT_COUNT; i++) {
      buttons.add(new Button(settings.getFont(i), dims.wide_key_size*i + dims.border_x, dims.border_y, dims.wide_key_size, dims.basic_key_size, dims.text_size));
    }

    // Output scroll buttons.
    int scroll_button_x = dims.input_y + round(dims.basic_key_size*0.75);
    buttons.add(new Button(FIRST, 11*dims.basic_key_size + dims.border_x, scroll_button_x + dims.basic_key_size*0, dims.basic_key_size, dims.basic_key_size));
    buttons.add(new Button(PREV, 11*dims.basic_key_size + dims.border_x, scroll_button_x + dims.basic_key_size*1, dims.basic_key_size, dims.basic_key_size));
    buttons.add(new Button(NEXT, 11*dims.basic_key_size + dims.border_x, scroll_button_x + dims.basic_key_size*2, dims.basic_key_size, dims.basic_key_size));
    buttons.add(new Button(LAST, 11*dims.basic_key_size + dims.border_x, scroll_button_x + dims.basic_key_size*3, dims.basic_key_size, dims.basic_key_size));
  }  

  /**
   * Calls the display function for all the buttons in the container.
   */
  void displayButtons() {
    textFont(environment.getFont(), dims.caps_size);
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

  /**
   * A reaction on a button press. All the logic of virtual buttons is governed here!
   */
  void mousePress() {
    // If there is no button under the mouse, do not mind.
    if (hover_button == -1)
      return;

    // Obtain the caption of the current button.
    String button = buttons.get(hover_button).getCaption();

    // Go through letter buttons and space.
    if (button.matches("\\p{Lu}"))
      data.addLetter(button.charAt(0));
    else if (button.equals("_"))
      data.addLetter(' ');

    // Action buttons
    else if (button.equals(CONFIRM)) {
      // Erase the previous error if there was any.
      if (!error.isEmpty()) {
        error = "";
        startDatabase();
      }

      else if (data.getInput().equals("EXIT")) {
        if (settings.illegal)
          data.addLine(settings.getText("illegallogoff"));
        else {
          environment.setScreen(1);
          data.clear();
          data.addLine(settings.getText("logoffreset"));
        }
      }

      // Pass the current input to an appropriate handler.
      else { 
        final String input = data.getInput();
        switch (environment.getScreen()) {
          case NAME_SCREEN:
            confirmName(input);
            break;
  
          case PASS_SCREEN:
            confirmPass(input);     
            break;
  
          case TEXT_SCREEN:
            searchText(input);  
            break;
        }
      }
    } 
    else if (button.equals(ERASE)) {
      data.eraseLast();
    } 
    else if (button.equals(KILL)) {
      data.eraseAll();
    }

    // Font buttons
    else if (button.equals(settings.getFont(0)) || button.equals(settings.getFont(1)) || button.equals(settings.getFont(2)) || button.equals(settings.getFont(3))) {
      environment.setFont(button);
      data.rebuildOutput();
      data.display();
    }

    // Scrollers
    else if (button.equals(FIRST)) {
      data.scrollFirst();
    } 
    else if (button.equals(PREV)) {
      data.scrollBackwards();
    } 
    else if (button.equals(NEXT)) {
      data.scrollForward();
    } 
    else if (button.equals(LAST)) {
      data.scrollLast();
    }
  }

  /**
   * Called when the user presses confirm button while in the name screen.
   */
  private void confirmName(final String input) {
    environment.setAccountName(input);
    environment.setScreen(PASS_SCREEN);
    data.clear();
    data.addLine(settings.getText("password") + input);
  }

  /**
   * Called when the user confirms the typed in password.
   * Control if the user has the access rights - currently take both DENIED and NOT and OK, but sth else should be put here.
   */
  private void confirmPass(final String input) {
    environment.password = input;
    data.clear();
    String valid = http.findEntry("ACCOUNT_VALID");
    if (valid.substring(0, 6).contentEquals("DENIED") || valid.substring(0, 2).contentEquals("OK") || valid.substring(0, 3).contentEquals("NOT")) {
      environment.setScreen(TEXT_SCREEN);
      data.addLine(settings.getText("welcome") + environment.getAccountName() + ".");
      data.addLine(settings.getText("logoff"));
    }
    else {
      environment.setScreen(NAME_SCREEN);
      data.addLine(settings.getText("wrongpass") + input);
    }
  }

  /**
   * Called when the user confirms the search of the input. The input keyed data are requested from the server and then stored in the output string.
   */
  private void searchText(final String input) {
    String result = http.findEntry(input);
    if (result.substring(0, 2).contentEquals("OK")) {
      data.addLine(input + ": " + result.substring(3));
    } 
    else if (result.substring(0, 6).contentEquals("DENIED")) {
      data.addLine(input + ": " + settings.getText("denied"));
    } 
    else if (result.substring(0, 6).contentEquals("NOT FOUND")) {
      data.addLine(input + ": " + settings.getText("notfound"));
    } 
    else if (result.substring(0, 6).contentEquals("CORRUPTED")) {
      data.addLine(input + ": " + settings.getText("corrupted"));
    }
  }
}

/**
 * Class that represents a single button on the virtual keyboard. Logic of the button itself is handled here.
 */
class Button {
  private int x_pos, y_pos, width_, height_; // Dimensions.n  boolean is_mouse_over = false; 
  private int font_size;
  private String caption; // Caption of the button, also used as a key string.

  /**
   * Set all the data of the button.
   */
  private void setValues(String o_caption, int o_x, int o_y, int o_width, int o_height, int o_font_size) {
    caption = o_caption;
    x_pos = o_x;
    y_pos = o_y;
    width_ = o_width;
    height_ = o_height;
    font_size = o_font_size;
  }

  /**
   * Constructor for buttons width specific height, width and font size.
   */
  Button(String o_caption, int o_x, int o_y, int o_width, int o_height, int o_font_size) {
    setValues(o_caption, o_x, o_y, o_width, o_height, o_font_size);
  }

  /**
   * Constructor for buttons width specific height and width.
   */
  Button(String o_caption, int o_x, int o_y, int o_width, int o_height) {
    setValues(o_caption, o_x, o_y, o_width, o_height, dims.caps_size);
  }

  /**
   * Constructor for the basic, square buttons.
   */
  Button (String o_caption, int o_x, int o_y) {
    setValues(o_caption, o_x, o_y, dims.basic_key_size, dims.basic_key_size, dims.caps_size);
  }

  /**
   * Draws the button on the screen.
   */
  public void display(final boolean is_mouse_over) {
    textSize(font_size);

    // Choose the highlight color, if requested.
    if (is_mouse_over) {
      fill(settings.getColor("highlight"));
    }
    else {
      fill(settings.getColor("caption"));
    }

    // Draw the caption with X in the middle of button, Y being moved down a half of the letter height (basically center) 
    textAlign(CENTER);
    text(caption, x_pos + width_/2, y_pos + (height_ + font_size)/2);
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

