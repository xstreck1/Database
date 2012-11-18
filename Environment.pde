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
   * Constructor creates fonts and sets the first one as active.
   */
  Environment () {
    loadFonts();
    currentFont = settings.getFont(0);
  }

  /**
   * Load fonts based on their resource names - exactly 4 are assumed to be present.
   */
  void loadFonts() {
    fonts = new HashMap();
    String font_path;
    PFont new_font;
    
    font_path = settings.getFont(0) + ".vlw";
    new_font  = loadFont(font_path);
    fonts.put(settings.getFont(0), new_font);
    font_path = settings.getFont(1)  + ".vlw";
    new_font  = loadFont(font_path);
    fonts.put(settings.getFont(1), new_font);
    font_path = settings.getFont(2) + ".vlw";
    new_font  = loadFont(font_path);
    fonts.put(settings.getFont(2), new_font);
    font_path = settings.getFont(3) + ".vlw";
    new_font  = loadFont(font_path);
    fonts.put(settings.getFont(3), new_font);
  }

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
