/**
 * Class that holds and manages environment info
 */
class Environment {
  HashMap fonts;
  String  currentFont;
  int     screen_type; // 1 for name, 2 for password, 3 for data, 4 for error 
  String  user_name;
  String  password;

  Environment () {
    loadFonts();
    currentFont = settings.getFont(0);
    user_name = password = "";  
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
    data.setScreenData();
  }
  
  void changeFont(String font_name) {
    currentFont = font_name;
    data.reFormatOutput();
  }
}
