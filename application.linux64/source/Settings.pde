/**
 * Contains settings load from the xml file.
 */
class Settings {
  int ID;
  int screen_width;
  int screen_height;
  int text_size;
  int caps_size;
  String target_url;
  HashMap users;
  HashMap strings;
  HashMap colors;
  Vector  fonts;
  
  Settings () {
    ID = -1;
    screen_width = 800;
    screen_height = 600;
    text_size = 20;
    caps_size = 30;
    users = new HashMap();
    strings = new HashMap();
    colors = new HashMap();
    fonts = new Vector();
    target_url = "";
  }
  
  String getText(String name) {
    if (strings.get(name) == null) {
      error = name.concat(" string was not found.");
      return "";
    }
    else 
      return (String)(strings.get(name));
  }
  
  String getFont(int val) {
    String font_name = "";
    
    try {
      font_name = (String) fonts.elementAt(val);
    } catch (Exception e) {
      e.printStackTrace();
      error = e.getMessage();
    }
    
    return font_name;
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
