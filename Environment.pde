
/**
 * Class that holds and manages environment info
 */
class Environment {
  HashMap fonts;
  String  currentFont;
  int     screen_type; // 1 for name, 2 for password, 3 for data
  HashMap accounts;
  Account current_account;
  int     buttons_count; // How many buttons are active
  
  /** 
   * Simple structure for accounts
   */
  class Account {
    String name;
    String password;
    int    clearence;
    
    Account (String n, String p, int c) {
      name      = n;
      password  = p;
      clearence = c;
    }
    
    String getMyName () {return name;}
    String getPass () {return password;}
    int getClearence () {return clearence;}
  }

  Environment () {
    loadFonts();
    currentFont = FONT1;

    createAccounts();
    setAccount("VEREJNY"); // TODO Erase - there should be no account at the start
    
    screen_type = 0;    
  }

  void loadFonts() {
    fonts = new HashMap();
    String font_path;
    PFont  new_font;
    
    font_path = FONT1 + ".vlw";
    new_font  = loadFont(font_path);
    fonts.put(FONT1, new_font);
    font_path = FONT2 + ".vlw";
    new_font  = loadFont(font_path);
    fonts.put(FONT2, new_font);
    font_path = FONT3 + ".vlw";
    new_font  = loadFont(font_path);
    fonts.put(FONT3, new_font);
    font_path = FONT4 + ".vlw";
    new_font  = loadFont(font_path);
    fonts.put(FONT4, new_font);
  }
  
  void createAccounts() { 
    accounts = new HashMap();
    Account temp;
    
    temp = new Account("Veřejný", "", 0);
    accounts.put("VEREJNY", temp);
    temp = new Account("Admin", "admin", 1);
    accounts.put("ADMIN", temp);    
  }

  boolean accountExists(String name) {
    return accounts.containsKey(name);
  } 

  void setAccount(String name) {
    current_account = (Account) accounts.get(name);
  }
  
  boolean passwordMatches(String pass) {
    return (0 == pass.compareToIgnoreCase(current_account.getPass()));
  }
  
  String getAccountName() {
    return current_account.getMyName();
  }  
 
  int getAccountClereance() {
    return current_account.getClearence();
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
