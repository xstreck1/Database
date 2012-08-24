class Settings {
  int ID;
  int screen_width;
  int screen_height;
  HashMap users;
  HashMap strings;
  HashMap colors;
  
  Settings () {
    ID = -1;
    screen_width = -1;
    screen_height = -1;
    users = new HashMap();
    strings = new HashMap();
    colors = new HashMap();
  }
  
  String obtainString(String name) {
    if (strings.get(name) == null) {
      error = name.concat(" string was not found.");
      return "";
    }
    else 
      return (String)(strings.get(name));
  }
  
  int getColor(String name) {
    if (colors.get(name) == null) {
      error = name.concat(" color was not found.");
      return 0;
    }
    else 
      return Integer.decode((String)(colors.get(name)));
  }
}
