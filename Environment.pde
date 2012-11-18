/**
 * Class that holds and manages environment info
 */
class Environment {
  private HashMap<String, PFont> fonts; // Container of the fonts keyed by their name.
  private String  currentFont; // Name of the current font.
  private int screen_type = 1; // 1 for name, 2 for password, 3 for data 
  private String  user_name = ""; // Name of the current user.
  private String  password = ""; // Password of the current user.

  /**
   * Constructor creates fonts and sets the active font.
   */
  Environment () {
    loadFonts();
    
    if (fonts.size() > 0)
      currentFont = settings.getFont(0);
    else
      currentFont = BASIC_FONT_NAME;
  }

  /**
   * Load fonts based on their resource names - exactly 4 are assumed to be present.
   */
  void loadFonts() {
    fonts = new HashMap();
    String font_path;
    PFont new_font;
    
    // Create all fonts that are loaded from settings.
    for (int i = 0; i < FONT_COUNT; i++) {
      font_path = settings.getFont(i) + ".vlw";
      new_font  = loadFont(font_path);
      fonts.put(settings.getFont(i), new_font);
    }
    
    // Add the basic font.
    fonts.put(BASIC_FONT_NAME, basic_font);
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
  
  void setFont(final String font_name) {
    currentFont = font_name;
  }

  PFont getFont() {
    return fonts.get(currentFont);
  }
  
  void setScreen(final int new_screen) { 
    screen_type = new_screen;
  }
  
  int getScreen() { 
    return screen_type;
  }
}
