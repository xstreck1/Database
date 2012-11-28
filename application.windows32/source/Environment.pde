/**
 * Class that holds and manages environment info
 */
class Environment {
  private FontDesc current_font = BASIC_FONT; ///< Name of the current font.
  private int screen_type = 1; ///< 1 for name, 2 for password, 3 for data 
  private String  user_name = ""; ///< Name of the current user.
  private String  password = ""; ///< Password of the current user.
  private boolean on_line = false; ///< Statin whether the terminal is online or not.

  /**
   * Constructor creates fonts and sets the active font.
   */
  Environment () {   
    if (settings.getFontCount() > 0)
      current_font = settings.getFont(0);
      
    on_line = settings.on_line;
  }

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Getters / Setters.
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  void setAccountName(final String name) {
    user_name = name;
  }
  
  String getAccountName() {
    return user_name;
  }  
  
  void setFont(final int font_num) {
    current_font = settings.getFont(font_num);
  }

  FontDesc getFont() {
    return current_font;
  }
  
  void setScreen(final int new_screen) { 
    screen_type = new_screen;
  }
  
  int getScreen() { 
    return screen_type;
  }
}
