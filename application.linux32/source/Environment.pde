/**
 * Class that holds and manages environment info
 */
class Environment {
  HashMap fonts;
  String  currentFont;
  int     screen_type; // 1 for name, 2 for password, 3 for data, 4 for error
  int     buttons_count; // How many buttons are active
  String  user_name;

  Environment () {
    loadFonts();
    currentFont = settings.getFont(0);
    user_name = "";  
    screen_type = 0;   
  }

  void loadFonts() {
    fonts = new HashMap();
    String font_path;
    PFont  new_font;
    
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
  
  boolean accountExists(String name) {
    return settings.users.containsKey(name);
  } 

  void setAccount(String name) {
    user_name = name;
  }
  
  boolean passwordMatches(String pass) {
    return (0 == pass.compareToIgnoreCase((String) settings.users.get(user_name)));
  }
  
  String getAccountName() {
    return user_name;
  }  

  PFont getCurrentFont() {
    return (PFont) fonts.get(currentFont);
  }
  
  int getScreen() { 
    return screen_type;
  }
  
  void setScreen(int new_screen) { 
    screen_type = new_screen;
    buttons_count = (new_screen == 3) ? BUTTON_COUNT : (BUTTON_COUNT - 4);
    data.setScreenData();
  }
  
  void changeFont(String font_name) {
    currentFont = font_name;
    data.reFormatOutput();
  }
  
  int getButtonsCount() {
    return buttons_count;
  }
}
