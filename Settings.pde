public class FontDesc {
  String name;
  PFont font;
  int move;
  
  FontDesc(String o_name, PFont o_font, int o_move) {
    name = o_name;
    font = o_font;
    move = o_move;
  }
}
  
/**
 * Contains settings load from the xml file. 
 * Most settings are not really that important or have default values, that are instantiated in the constructor. The mandatory ones can be checked using the "control" function.
 */
public class Settings {
  private int ID = -1;; ///< ID of the terminal.
  private boolean illegal = false; ///< True if the terminal is hacked.
  private boolean on_line = false; ///< True if the terminal is initially on-line.
  private int screen_width = 800; ///< Width of the screen, in pixels.
  private int screen_height = 600; ///< Height of the screen, in pixels.
  private int text_size = 20; ///< Size of the font, in pixels.
  private int caps_size = 30; ///< Size of the captions (buttons of keyboard etc.), in pixels.
  private int images_num = 1; ///< Number of images included in the animation
  private int delay = 1000; ///< Delay between the images. Default 1 sec.
  private String target_url = ""; ///< String with prefix of the database URL
  private String image_suffix = ".png"; ///< String with the suffix of images that are used
  private HashMap<String, String> strings = new HashMap<String, String>(); ///< Strings that are used within the program.
  private HashMap<String, Vector<String> > colors = new HashMap<String, Vector<String> >(); ///< Colors that are displayed somewhere. Each color is given by four (ARGB) strings.
  private Vector<FontDesc> fonts = new Vector<FontDesc>(); ///< Vector that eventually holds the fonts.
  
  void addFont(String name, String move) {
    PFont font = loadFont(name + ".vlw");
    int move_val = Integer.valueOf(move);
    FontDesc new_font = new FontDesc(name, font, move_val);
    fonts.add(new_font);
  }
  
  /**
   * Obtain a certain string with the name as a key. If not present, set error.
   *
   * @param name  key for the string that is searched for
   *
   * @return  the requested string, if it was found, error otherwise
   */
  final String getText(String name) {
    if (strings.get(name) == null) {
      error = name.concat(" string was not found.");
      return "";
    }
    else 
      return strings.get(name);
  }
  
  /**
   * Obtain a certain font by its ordinal number referenced from 0. If not present, set error.
   *
   * @param number  ordinal number of the requested font
   *
   * @return   the font, if it is present, otherwise an empty string
   */
  final FontDesc getFont(int number) {    
    if (number < fonts.size() || number >= 0)
      return fonts.get(number);
    
    error = "Trying to acces a font ouf of range."; 
    return BASIC_FONT;  
  }
  
  /**
   * @return  number of the fonts present
   */
  final int getFontCount() {
    return fonts.size();
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
      Vector<String> parts = colors.get(name);
      int r = Integer.valueOf(parts.elementAt(0));
      int g = Integer.valueOf(parts.elementAt(1)); 
      int b = Integer.valueOf(parts.elementAt(2));  
      int a = Integer.valueOf(parts.elementAt(3));  
      return color(r,g,b,a);
    }  
  }
  
  /**
   * This function controls if all the mandatory tags are set in the way sufficient for the sucessful run of the app.
   */
  void control() {
    String error_pref = "Missing data from the tag: ";
    if (ID == -1)
      error = error_pref + "ID.";
    if (target_url.compareTo("") == 0)
      error = error_pref + "URL.";
  }
}
