class Settings {
  int ID;
  int screen_width;
  int screen_height;
  String target_url;
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
    target_url = "";
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
      return color(0);
    }
    else {
      Vector parts = (Vector) colors.get(name);
      int r = Integer.valueOf((String) parts.elementAt(0));
      int g = Integer.valueOf((String) parts.elementAt(1)); 
      int b = Integer.valueOf((String) parts.elementAt(2));  
      int a = Integer.valueOf((String) parts.elementAt(3));  
      return color(r,g,b,a);
    }  
  }
}
