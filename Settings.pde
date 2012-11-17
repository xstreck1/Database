/**
 * Contains settings load from the xml file.
 */
class Settings {
  int ID; // ID of the terminal.
  int screen_width; // Width of the screen, in pixels.
  int screen_height; // Height of the screen, in pixels.
  int text_size; // Size of the font, in pixels.
  int caps_size; // Size of the captions (buttons of keyboard etc.), in pixels.
  int images_num; // Number of images included in the animation
  int delay; // Delay between the images.
  boolean illegal; // True if the terminal is hacked.
  String target_url; // String with prefix of the database URL
  String image_suffix; // String with the suffix of images that are used
  HashMap strings; // Strings that are used within the program.
  HashMap colors; // Colors that are displayed somewhere.
  Vector fonts; // Vector that eventually holds the fonts.
  
  /**
   * Constructor sets the values to default. Note that some of them must be still stated though.
   */
  Settings () {
    ID = -1;
    illegal = false;
    screen_width = 800;
    screen_height = 600;
    text_size = 20;
    caps_size = 30;
    images_num = 1;
    delay = 100;
    strings = new HashMap();
    colors = new HashMap();
    fonts = new Vector();
    target_url = "";
    image_suffix = ".png";
  }
  
  /**
   * Obtain a certain string with the name as a key. If not present, set error.
   *
   * @param name  key for the string that is searched for
   *
   * @return  the requested string, if it was found, error otherwise
   */
  String getText(String name) {
    if (strings.get(name) == null) {
      error = name.concat(" string was not found.");
      return "";
    }
    else 
      return (String)(strings.get(name));
  }
  
  /**
   * Obtain a certain font name by its ordinal number referenced from 0. If not present, set error.
   *
   * @param number  ordinal number of the requested font
   *
   * @return  name of the font, if it is present, otherwise an empty string
   */
  String getFont(int number) {
    String font_name = "";
    
    // Try to seach for the font
    try {
      font_name = (String) fonts.elementAt(number);
    } catch (Exception e) {
      e.printStackTrace();
      error = e.getMessage();
    }
    
    return font_name;
  }
  
  /**
   * Obtain a decimal representation of the color based on its components, referenced by a string name. Raise an error if it is not present.
   *
   * @param name  name of the requested color
   *
   * @return  decimal representation of the color if present, otherwise black
   */
  int getColor(String name) {
    if (colors.get(name) == null) {
      error = name.concat(" color was not found.");
      return color(0);
    }
    // Obatain subparts of the color.
    else {
      Vector parts = (Vector) colors.get(name);
      int r = Integer.valueOf((String) parts.elementAt(0));
      int g = Integer.valueOf((String) parts.elementAt(1)); 
      int b = Integer.valueOf((String) parts.elementAt(2));  
      int a = Integer.valueOf((String) parts.elementAt(3));  
      return color(r,g,b,a);
    }  
  }
  
  /**
   * This function control if all the mandatory tags are set.
   */
  void control() {
    String error_pref = "Missing a mandatory data from the setting file that should have been described in the tag: ";
    if (ID == -1)
      error = error_pref + "ID.";
    if (target_url.compareTo("") == 0)
      error = error_pref + "URL.";
    if (fonts.size() != 4)
      error = error_pref + "FONT. (Must occur four times).";
  }
}
