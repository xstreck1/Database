import processing.core.*; 
import processing.data.*; 
import processing.opengl.*; 

import java.net.MalformedURLException; 
import java.net.URL; 
import java.net.URLConnection; 

import java.applet.*; 
import java.awt.Dimension; 
import java.awt.Frame; 
import java.awt.event.MouseEvent; 
import java.awt.event.KeyEvent; 
import java.awt.event.FocusEvent; 
import java.awt.Image; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class Database extends PApplet {

// Resources locations.
final String SETTINGS_FILE = "settings.xml"; ///< The file with all the settings.
final String CURSOR_FILE = "cursor.png"; ///< A picture used as the cursor.
// Background images and fonts are derived from settings.
FontDesc BASIC_FONT; ///< Name of the font that is used in default cases.
PImage [] background_images; ///< An array containing the images rotated on the background.
PImage offline_image; ///< An image that is displayed when the terminal is on-line.
// Screen identifiers.
final int NAME_SCREEN = 1; ///< Identifier of the screen with the name prompt.
final int PASS_SCREEN = 2; ///< Identifier of the screen with the password prompt.
final int TEXT_SCREEN = 3; ///< Identifier of the screen with the text content.

// Number of frames per second.
final int FRAME_RATE = 50; 
// Number of seconds between each check.
final int CHECK_RATE = 5000; 
// Counter of repetitions of display operation.
int draw_count = 0;

final float ANILLO_FIT = 2.5f; // Changes font size for the Anillo font, which 

// Singular objects that will be used during the computation.
// ALL THESE ARE SHARED PROJECT-WISE!
Keyboard    keyboard; ///< Virtual keyboard object.
Environment environment; ///< Global values and current setting.
Data        data; ///< Input / output content.
HTTPHelper  http; ///< Class for conntecting to the server.
Settings    settings; ///< Settings read from the XML file.
Dimensions  dims; ///< Numerical layout values.

// A string that is filled if something goes wrong - basically non-intrusive version of an exception. Mainly would be raised if a parsed tag in the settings.xml is unknown.
String error = "";

public @Override
void setup() {
  // Load data
  parseSettings();
  loadBackground();
  
  BASIC_FONT = new FontDesc("Arial", loadFont("Arial.vlw"), 0);
  
  // Create handling objects.
  dims        = new Dimensions();
  keyboard    = new Keyboard();
  environment = new Environment();
  data        = new Data();
  http        = new HTTPHelper();
  
  // Setup graphics.
  size(settings.screen_width, settings.screen_height, JAVA2D);
  cursor(loadImage(CURSOR_FILE), 16, 16);
  smooth();
  frameRate(FRAME_RATE);
  draw();  
  
  // Start the terminal as required.
  startDatabase();
}

public @Override
void draw() {
  // Within a loop, check status from time to time (100 == 2 secs).
  if ((draw_count++ % round(CHECK_RATE/FRAME_RATE)) == 0) {
    http.check();
  }
  
  // Pick animation if the terminal is on-line and an image if otherwise.
  if (environment.on_line || settings.illegal ) {
    // Decide current BG image number.
    int img_num = ((draw_count % (settings.delay * settings.images_num)) / settings.delay);
    
    // Display the image if there is one.
    if (background_images[img_num] != null)
      background(background_images[img_num]);
    else
      background(settings.getColor("background")); 
  } else {
    if (offline_image != null)
      background(offline_image);
    else
      background(settings.getColor("background")); 
  }
  
  // Display buttons and data over the background.
  keyboard.displayButtons();
  data.display();
}

public @Override
void mouseMoved() {
  keyboard.mouseMove();
}

public @Override
void mousePressed() {
  keyboard.mousePress();
}

/**
 * Function to get settings from the settings file.
 */
public void parseSettings() {
  // Create a new settings object - up till now there was none.
  settings = new Settings();
  
  // Setup parser and parse settings.
  XMLParser parser = new XMLParser();
  parser.parse(SETTINGS_FILE);
  
  // Control if everything that has to be set is set.
  settings.control(); 
}

/**
 * Load (once) images that will be displayed as a background.
 * Images are to be in the form "width"x"height"_"animation index form 1"."suffix as given in settings".
 */
public void loadBackground() {
  // Create space to store the images.
  background_images = new PImage[settings.images_num];
  
  // Create prefix of files that will be read.
  String file = String.valueOf(settings.screen_width);
  file = file.concat("x");
  file = file.concat(String.valueOf(settings.screen_height));
  
  // Obtain all images as described in the settings.
  for (int i = 1; i <= settings.images_num; i++) {
    background_images[i-1] = loadImage(file + "_" + i + settings.image_suffix);
  }
  
  // Obtain the off-line image.
  offline_image = loadImage(file + "_off" + settings.image_suffix);
}

/**
 * This function starts a database from the scratch.
 */
public void startDatabase() {
  // Content is dependent on whether the terminal is legal or not.
  if (settings.illegal) { 
    data.clear();
    environment.setScreen(TEXT_SCREEN);
    data.addLine(settings.getText("illegal_welcome")); 
  } else { 
    data.clear();
    environment.setScreen(NAME_SCREEN);
    data.addLine(settings.getText("username")); 
  }   
}
/**
 * Class that handles I/0 and text formatting.
 */
class Data {
  private String output_data; ///< Original string previous to being reformed.
  private String output_stream; ///< List of strings, each corresponding to a single line of the output.
  private String input_stream; ///< The string containing the user-given text.
  private int first_output; ///< Ordinal number of the first line that is displayed
  private int lines_count; ///< Vector holds positions of newline symbols in the output_stream

  /**
   * Constructor just assigns empty data to the objects.
   */
  Data() {
    clear();
  }
  
  /**
   * Assigns new objects to the employed references.
   */
  public void clear() {
    output_stream = "";
    output_data = "";
    input_stream = "";
    first_output = lines_count = 0;
  }
  
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Input stream manipulation
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  /**
   * Adds a letter to the input text field.
   */
  public void addLetter(char letter) {
    input_stream = input_stream + str(letter);
    
    // Check if the text can still be fitted in the field - if not, erase the symbol and prompt the  user.
    if (textWidth(input_stream) > (dims.keyboard_width-2*dims.text_indent)) {
      eraseLast();
      addLine(settings.getText("outofbounds"));
    }
  }
  
  /**
   * Erases the single last symbol from the input stream.
   */
  public void eraseLast() {
    if (input_stream.length() > 0)
      input_stream = input_stream.substring(0, input_stream.length() - 1);
  }
  
  /**
   * Erases all the symbols in the input stream.
   */
  public void eraseAll() {
    input_stream = new String();
  }
  
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Output stream manipulation
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  /**
   * Reforms the string so it fits the screen. This string is not expected to have any newline symbols!
   *
   * @param new_line  a string containing the original data
   *
   * @return  string separated by newlines 
   */
  private String getSublines(String new_line) {
    lines_count++; // Increament the number of lines present with each call (since it adds a new line)
    // Check wheather it does not fit already.
    if (textWidth(new_line) <= dims.data_width) {
      return (new_line + "\n");
    }
    // If not, take the longest fitting line ended by a space and make it into new line. The rest then recursivly divide again.
    else {
      for (int symbol = 0; symbol < new_line.length(); symbol++) {
        if (textWidth(new_line.substring(0, symbol)) > dims.data_width) {
          int space_pos = new_line.substring(0, symbol).lastIndexOf(' ');
          return (new_line.substring(0, space_pos) + "\n" + getSublines(new_line.substring(space_pos+1)));
        }
      }  
    }
    return null; // Errornous state, will not occur.
  }
  
  /**
   * Takes a string and adds new lines so it fits the screen.
   *
   * @param input_text  a string with the text to change
   *
   * @return  a newly formatted string 
   */
  private String reFormat(String input_text) {
    // Make sure we will measure correctly.
    textFont(environment.getFont().font);
    int text_size = environment.getFont().name.equals("Anillo") ? round(dims.text_size / ANILLO_FIT) : dims.text_size;
    textSize(text_size);  
    
    // Split to substrings that are already separated.
    String [] lines = input_text.split("\n");
    String formatted_text = "";
    
    // Add each substring, possibly with new newlines.
    for (int i = 0; i < lines.length; i++) {
      formatted_text += getSublines(lines[i]);
    }
    
    return formatted_text;
  }
  
  /**
   * Reformats the string and places it into the ouput container
   */
  public void addLine(String new_text) {
    output_data += new_text + "\n";
    output_stream += reFormat(new_text);
    scrollLast();
  }
  
  /**
   * Called to reformat the whole output string to make sure it fits current screen.
   */
  public void rebuildOutput() {
    lines_count = 0;
    output_stream = reFormat(output_data);
    scrollLast();
  }
  
  /**
   * Display the output from the first line.
   */
  public void scrollFirst() {
    first_output = 0;
  }
  
  /**
   * Display the output from the previous line.
   */  
  public void scrollBackwards() {
    first_output = max (first_output - 1, 0); 
  }

  /**
   * Display the output from the next line.
   */  
  public void scrollForward() {
    first_output = max (0, min (first_output + 1, lines_count - dims.lines_count)); 
  }
  
  /**
   * Display the output from the first line such that the last line is still visible.
   */    
  public void scrollLast() {
    first_output = max(0, lines_count - dims.lines_count);
  }

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Visual
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  /**
   * Displays the content of the input and output fileds.
   */
  public void display() {
    int text_size = environment.getFont().name.equals("Anillo") ? round(dims.text_size / ANILLO_FIT): dims.text_size; // Hard-fix for Anillo
    
    // Fill the text fileds with grey overlap.
    noStroke();
    fill(settings.getColor("field"));
    rect(dims.input_x, dims.input_y, dims.keyboard_width, round(text_size*1.25f)); 
    rect(dims.input_x, dims.output_y, dims.output_width, dims.output_height); 
    textAlign(LEFT);    
        
    // Display error output if there is any.
    if (!error.isEmpty()) {
      textFont(BASIC_FONT.font, text_size); // Set readable font.
      fill(settings.getColor("error"));
      // Fill the output filed with the error.
      text(error, dims.input_x + dims.text_indent, dims.input_y + settings.text_size - environment.getFont().move);
    } 
    else {
      textFont(environment.getFont().font, text_size);
      fill(settings.getColor("text"));
      
      // Fill the input bar.
      int fix = (environment.getFont().name.equals("OmikronOne")) ? round(dims.text_size * -0.25f) : 0; // Hard-fix for Omikronone
      text(input_stream, dims.input_x + dims.text_indent, dims.input_y + round(dims.text_size * 0.8f) + fix);
      
      // From the output string take those substrings that are currently visible.
      String [] substrings = output_stream.split("\n");
      for (int i = 0; (i < dims.lines_count) && (i + first_output < substrings.length); i++)
        text(substrings[i + first_output], dims.input_x + dims.text_indent, dims.output_y + dims.text_size*(i+1) + dims.text_indent - environment.getFont().move);
    }
  }
  
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Getters / Setters
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  public final String getInput() {
    return input_stream;
  }
  
  public final String getOutput() {
    return output_stream;
  }
}
/**
 * Class holds layout placement values.
 */
public class Dimensions {
  // Screen dimensions
  int width_; ///< Width of the window itself.
  int height_; ///< Height of the window itself.

  // Layout variables - THESE ARE SET IN THE SETTINGS
  int border_x; ///< Space between layout and window horizontally.
  int border_y; ///< Space between layout and window vertically.
  int basic_key_size; ///< Key size.
  int caps_size; ///< GUI text.
  int text_size; ///< I/O text.
  final int text_indent = 5;  ///< Space between window and text.

  // Object placement variables - just for simplicity in reccurent uses - THESE ARE COMPUTED.
  int keyboard_x; ///< Leftmost corner x position of the virtual keyboard.
  int keyboard_y; ///< Leftmost corner y position of the virtual keyboard.
  int keyboard_width; ///< Leftmost corner y position of the virtual keyboard.
  int wide_key_size; ///< Size of the bigger key (e.g. "erase").
  int input_x; ///< Leftmost corner x position of the input filed.
  int input_y; ///< Leftmost corner y position of the input filed.
  int output_x; ///< Leftmost corner x position of the output filed.
  int output_y; ///< Leftmost corner y position of the output filed.  
  int output_width; ///< Width of the output field.
  int output_height; ///< Height of the output field.
  int data_width; ///< Width of the output text.
  int data_height; ///< Height of the output text.
  int lines_count; ///< Number of lines in the output filed.

  /**
   * The constructor sets the values.
   */
  Dimensions() {
    // Obtain the size from settings
    width_ = settings.screen_width;
    height_ = settings.screen_height;

    // Relate basic values to this setting
    border_y = round(height_ * 0.05f);
    border_x = round(height_ * 0.05f) + round((width_ - height_*1.3f)/2.0f);
    basic_key_size = round(height_ *0.1f);
    caps_size = settings.caps_size;
    text_size = settings.text_size;

    // Compute helping values from the basic ones.
    keyboard_x     = border_x;
    keyboard_y     = height_ - basic_key_size*4 - border_y;
    keyboard_width = basic_key_size*12;
    wide_key_size  = basic_key_size*3;
    input_x        = border_x;
    input_y        = round(basic_key_size*1.25f) + border_y;
    output_x       = border_x;
    output_y       = round(basic_key_size*1.75f) + border_y;
    output_width   = keyboard_width - basic_key_size;
    output_height  = basic_key_size*3;
    data_width     = output_width - 2*text_indent;
    data_height    = output_height - 2*text_indent;;    
    lines_count    = data_height / text_size; // This is tweaked a bit to make sure no overlap occurs in the bottom.
  }
}

/**
 * Class that holds and manages environment info
 */
class Environment {
  private FontDesc current_font = BASIC_FONT; ///< Name of the current font.
  private int screen_type = 1; ///< 1 for name, 2 for password, 3 for data 
  private String  user_name = ""; ///< Name of the current user.
  private String  password = ""; ///< Password of the current user.
  private boolean on_line = false; ///< Statin whether the terminal is online or not.

  /**
   * Constructor creates fonts and sets the active font.
   */
  Environment () {   
    if (settings.getFontCount() > 0)
      current_font = settings.getFont(0);
      
    on_line = settings.on_line;
  }

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Getters / Setters.
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  public void setAccountName(final String name) {
    user_name = name;
  }
  
  public String getAccountName() {
    return user_name;
  }  
  
  public void setFont(final int font_num) {
    current_font = settings.getFont(font_num);
  }

  public FontDesc getFont() {
    return current_font;
  }
  
  public void setScreen(final int new_screen) { 
    screen_type = new_screen;
  }
  
  public int getScreen() { 
    return screen_type;
  }
}




/**
 * Class wrapping very simple basics of a synchronous HTTP connection.
 */
class HTTPHelper {
  URLConnection conn; // Maintains a connection
  
  /**
   * This function establishes a connection, reads the content on the target URL and returns it.
   *
   * @param target_URL  a string representation of the target URL
   *
   * @return  POST data from the URL as a String
   */
  private String connect (final String target_URL) throws MalformedURLException, IOException {
    // Open the connection
    URL url = new URL(target_URL);
    conn = url.openConnection();
    conn.connect();

    // The content is stored into a buffer	
    InputStreamReader content;
    content = new InputStreamReader(conn.getInputStream());
    char [] buffer;
    int max_lenght = 100; // Current lenght of the buffer
    
    // Increase the buffer size until you read it all / until you reach bouns - given by a positive integer size
    do {
      max_lenght *= 2;
      buffer = new char[max_lenght]; }
    while (content.read(buffer, 0, max_lenght) >= max_lenght && max_lenght >= 1);
    
    // Remove empty spaces if there are any and return the result.
    String result = new String(buffer);
    int index_of_empty = (result.indexOf(0x0) == -1) ? result.length() : result.indexOf(0x0);
    return result.substring(0, index_of_empty);
  }

  /**
   * Builds a query string that is used as GET.
   *
   * @param key_word  a word that is searched for
   */
  public String buildQuery(String key_word) {
    return buildQuery(key_word, environment.user_name, environment.password);
  }

  /**
   * Builds a query string that is used as GET.
   *
   * @param key_word  a word that is searched for
   * @param name  a name to use instead of current user name
   * @param name  a password to use instead of current user password
   */  
  public String buildQuery(String key_word, String name, String password) {
    return settings.target_url + "?term=" + settings.ID + "&klic=" + key_word + "&login=" + name + "&password=" + password;
  }

  /**
   * Get data from server.
   *
   * @param key_word  the key that is searched for
   *
   * @return  a string obtained from the URL
   */
  public String findEntry(final String key_word) {
    // Prepare data
    String result = "";
    String my_query = buildQuery(key_word);  
    
    // Debug output
    System.out.print("Query: " + my_query);
    
    // Try to connect
    try {
      result = connect(my_query);
    }
    catch (Exception e) {
      e.printStackTrace();
      error = "Chyba spojeni s databazi.";
      result = "Error.";
    }
    
    // Debug output
    println(". Response: " + result); 
    
    return result;
  }

  /**
   * Check status of the database on the server and set environmental variable in dependency on that.
   */  
  public void check() {    
    String status = "";
    String my_query = buildQuery("STATUS", "MAINTENANCE", "INSECURITY"); 
    try {
      status = connect(my_query);
    }
    catch (Exception e) {
      e.printStackTrace();
      status = "Error.";
    }
    environment.on_line = status.equals("ON");
    // Debug output
    println("Status: " + my_query + " " + status); 
  }
}
/**
 * Keyboard is completelly responsible for the appereance and functionallity of the virtual keyboard acessible to user.
 */
public class Keyboard {
  private Vector<Button> buttons = new Vector();
  ; ///< Holder for all the buttons that are actually used.
  private int hover_button = -1; ///< ID of the button that has a mouse over it at the moment. -1 stands for none.

  // ASCII codes for some important positions
  private final char ALPHA_BEGIN = 65;
  private final char ALPHA_END = 91;
  private final char NUM_BEGIN = 48;
  private final char NUM_END = 57;
  private final char SPACE = '_'; // In the keyboard space is replaced with _ for clarity.

  // Dimensions, in the number of buttons, of the keyboard.
  private final int BOARD_WIDTH = 9;
  private final int BOARD_HEIGHT = 3; 

  // Strings for some action buttons.
  private final String CONFIRM = "Potvrd";
  private final String ERASE = "Smaz";
  private final String KILL = "Zrus";
  private final String FIRST = "<<";
  private final String PREV = "<";
  private final String NEXT = ">";
  private final String LAST = ">>";

  /**
   * Creates the keyboard itself - from this moment all the buttons are ready to go.
   */
  Keyboard() {
    buttons = new Vector();
    createButtons();
    hover_button = -1;
  }

  /**
   * Creates object representing all the buttons.
   */
  public void createButtons() {
    // Build the nubmers
    char caption = PApplet.parseChar(NUM_BEGIN);
    for (int x_counter = 0; x_counter <= NUM_END - NUM_BEGIN; x_counter++) {
      // Add a button with the character given by the caption variable and position in based on the loop.
      buttons.add(new Button(str(caption++), dims.keyboard_x + x_counter*(dims.basic_key_size), dims.keyboard_y + 0*+dims.basic_key_size));
    }

    // Build the letters (one line below numbers)
    caption = PApplet.parseChar(ALPHA_BEGIN);
    for (int y_counter = 0; y_counter < BOARD_HEIGHT; y_counter++) {
      for (int x_counter = 0; x_counter < BOARD_WIDTH; x_counter++) {
        // Change the last button for the space
        if (caption == ALPHA_END)
          caption = PApplet.parseChar(SPACE);

        // Add a button with the character given by the caption variable and position in based on the loop.
        buttons.add(new Button(str(caption++), dims.keyboard_x + x_counter*(dims.basic_key_size), dims.keyboard_y + (y_counter+1)*dims.basic_key_size));
      }
    }
 
    // Special input buttons.
    buttons.add(new Button(CONFIRM, 9*dims.basic_key_size + dims.border_x, dims.keyboard_y + 1*dims.basic_key_size, dims.wide_key_size, dims.basic_key_size));                                 
    buttons.add(new Button(ERASE, 9*dims.basic_key_size + dims.border_x, dims.keyboard_y + 2*dims.basic_key_size, dims.wide_key_size, dims.basic_key_size));
    buttons.add(new Button(KILL, 9*dims.basic_key_size + dims.border_x, dims.keyboard_y + 3*dims.basic_key_size, dims.wide_key_size, dims.basic_key_size));

    // Environment language buttons.
    int font_count = settings.fonts.size();
    int button_width = dims.keyboard_width / max(font_count,1);
    for (int i = 0; i < font_count; i++) {
      buttons.add(new Button(settings.getFont(i).name, button_width*i + dims.border_x, dims.border_y, button_width, dims.basic_key_size, dims.text_size));
    }

    // Output scroll buttons.
    buttons.add(new Button(FIRST, 11*dims.basic_key_size + dims.border_x, dims.output_y + dims.basic_key_size*0, dims.basic_key_size, dims.basic_key_size));
    buttons.add(new Button(PREV, 11*dims.basic_key_size + dims.border_x, dims.output_y + dims.basic_key_size*1, dims.basic_key_size, dims.basic_key_size));
    buttons.add(new Button(NEXT, 11*dims.basic_key_size + dims.border_x, dims.output_y + dims.basic_key_size*2, dims.basic_key_size, dims.basic_key_size));
    buttons.add(new Button(LAST, 11*dims.basic_key_size + dims.border_x, dims.output_y + dims.basic_key_size*3, dims.basic_key_size, dims.basic_key_size));
  }  

  /**
   * Calls the display function for all the buttons in the container.
   */
  public void displayButtons() {
    textFont(environment.getFont().font, dims.caps_size);
    for (int i = 0; i < buttons.size(); i++) // Display only this environments buttons - for the one that is hovered over pass that information.
      buttons.get(i).display(i == hover_button);
  }

  /**
   * Mouse moveme resets the currently marked button and sets a new one if the mouse cursor is hovering over it.
   */
  public void mouseMove() {
    hover_button = -1; // Reset the current button

    // Search for a hit.
    for (int i = 0; i < buttons.size() && hover_button == -1; i++) {
      if (buttons.get(i).testMousePosition()) {
        hover_button = i; // Set the button.
      }
    }
  }

  /**
   * A reaction on a button press. All the logic of virtual buttons is governed here!
   */
  public void mousePress() {
    // If there is no button under the mouse, do not mind.
    if (hover_button == -1)
      return;

    // Obtain the caption of the current button.
    String button = buttons.get(hover_button).getCaption();

    // Go through letter buttons and space.
    if (button.matches("[\\p{Lu},\\p{Digit}]"))
      data.addLetter(button.charAt(0));
    else if (button.equals("_"))
      data.addLetter(' ');

    // Action buttons
    else if (button.equals(CONFIRM)) {
      // Erase the previous error if there was any.
      if (!error.isEmpty()) {
        error = "";
        startDatabase();
      }
      // Else control for emptyness.
      else if (data.getInput().equals("")) {
        data.addLine(settings.getText("emptyinput"));
      }
      // Else test whether the user does not require to exit.
      else if (data.getInput().equals("EXIT")) {
        if (settings.illegal)
          data.addLine(settings.getText("illegallogoff"));
        else {
          environment.setScreen(1);
          data.clear();
          data.addLine(settings.getText("logoffreset"));
        }
      }

      // Pass the current input to an appropriate handler.
      else { 
        final String input = data.getInput();
        switch (environment.getScreen()) {
        case NAME_SCREEN:
          confirmName(input);
          break;

        case PASS_SCREEN:
          confirmPass(input);     
          break;

        case TEXT_SCREEN:
          searchText(input);  
          break;
        }
      }
    } else if (button.equals(ERASE)) {
      data.eraseLast();
    } else if (button.equals(KILL)) {
      data.eraseAll();
    }

    // Scrollers
    else if (button.equals(FIRST)) {
      data.scrollFirst();
    } 
    else if (button.equals(PREV)) {
      data.scrollBackwards();
    } 
    else if (button.equals(NEXT)) {
      data.scrollForward();
    } 
    else if (button.equals(LAST)) {
      data.scrollLast();
    }
    
    // Font buttons
    else for (int i = 0; i < settings.getFontCount(); i++) {
      if (button.equals(settings.getFont(i).name)) {
        environment.setFont(i);
        data.eraseAll();
        data.rebuildOutput();
        data.display();
      }
    }
  }

  /**
   * Called when the user presses confirm button while in the name screen.
   */
  private void confirmName(final String input) {
    environment.setAccountName(input);
    environment.setScreen(PASS_SCREEN);
    data.clear();
    String formatted = String.format(settings.getText("password"), input);
    if (formatted != null)
      data.addLine(formatted);
    else
      error = "Unable to format " + formatted + " with argument " + input + ".";
  }

  /**
   * Called when the user confirms the typed in password.
   * Control if the user has the access rights - currently take both DENIED and NOT and OK, but sth else should be put here.
   */
  private void confirmPass(final String input) {
    environment.password = input;
    data.clear();
    String valid = http.findEntry("ROLE");
    if (valid.length() < 2)
      error = "Login error. Response too short (< 2 chars).";
    
    if (valid.matches("OK.*")) {
      environment.setScreen(TEXT_SCREEN);
      // Get user nume and display prompty
      String formatted = String.format(settings.getText("welcome"), environment.getAccountName());
      if (formatted != null)
        data.addLine(formatted);
      else
        error = "Unable to format " + formatted + " with argument " + input + ".";
      data.addLine(settings.getText("prompt"));
    }
    else {
      environment.setScreen(NAME_SCREEN);
      data.addLine(settings.getText("wronglogin"));
    }
  }

  /**
   * Called when the user confirms the search of the input. The input keyed data are requested from the server and then stored in the output string.
   */
  private void searchText(final String input) {
    String result = http.findEntry(input);
    if (result.isEmpty())
      error = "Search error. Response empty";
      
    if (result.matches("OK.*")) {
      data.addLine(input + ": " + result.substring(3));
    } 
    else if (result.matches("OFF.*")) {
      data.addLine(input + ": " + settings.getText("off"));
    } 
    else if (result.matches("DENIED.*")) {
      data.addLine(input + ": " + settings.getText("denied"));
    } 
    else if (result.matches("NOT.*")) {
      data.addLine(input + ": " + settings.getText("notfound"));
    } 
    else if (result.matches("CORRUPTED.*")) {
      data.addLine(input + ": " + settings.getText("corrupted"));
    }
  }
}

/**
 * Class that represents a single button on the virtual keyboard. Logic of the button itself is handled here.
 */
class Button {
  private int x_pos, y_pos, width_, height_; // Dimensions.n  boolean is_mouse_over = false; 
  private int font_size;
  private String caption; // Caption of the button, also used as a key string.

  /**
   * Set all the data of the button.
   */
  private void setValues(String o_caption, int o_x, int o_y, int o_width, int o_height, int o_font_size) {
    caption = o_caption;
    x_pos = o_x;
    y_pos = o_y;
    width_ = o_width;
    height_ = o_height;
    font_size = o_font_size;
  }

  /**
   * Constructor for buttons width specific height, width and font size.
   */
  Button(String o_caption, int o_x, int o_y, int o_width, int o_height, int o_font_size) {
    setValues(o_caption, o_x, o_y, o_width, o_height, o_font_size);
  }

  /**
   * Constructor for buttons width specific height and width.
   */
  Button(String o_caption, int o_x, int o_y, int o_width, int o_height) {
    setValues(o_caption, o_x, o_y, o_width, o_height, dims.caps_size);
  }

  /**
   * Constructor for the basic, square buttons.
   */
  Button (String o_caption, int o_x, int o_y) {
    setValues(o_caption, o_x, o_y, dims.basic_key_size, dims.basic_key_size, dims.caps_size);
  }

  /**
   * Draws the button on the screen.
   */
  public void display(final boolean is_mouse_over) {
    textSize(font_size);
    if (environment.getFont().name.equals("Anillo"))
      textSize(round(font_size / ANILLO_FIT));      

    // Choose the highlight color, if requested.
    if (is_mouse_over) {
      fill(settings.getColor("highlight"));
    }
    else {
      fill(settings.getColor("caption"));
    }

    // Draw the caption with X in the middle of button, Y being moved down a half of the letter height (basically center) 
    textAlign(CENTER);
    text(caption, x_pos + width_/2, y_pos + (height_ + font_size)/2 - environment.getFont().move);
  }

  /**
   * Tests for collision with the current position of the mouse.
   *
   * @return  true if the mouse is over the button
   */
  public boolean testMousePosition() {
    if (mouseX >= x_pos && mouseX <= x_pos + width_ &&  mouseY >= y_pos && mouseY <= y_pos+height_)
      return true;
    else 
      return false;
  }

  /**
   * @return  caption of the button
   */
  public String getCaption() {
    return caption;
  }
}

/**
 * An object holding a font - its name, padding and acuall font object.
 */
public class FontDesc {
  String name; ///< A name that is describing the font.
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
  
  public void addFont(String name, String move) {
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
  public final String getText(String name) {
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
  public final FontDesc getFont(int number) {    
    if (number < fonts.size() || number >= 0)
      return fonts.get(number);
    
    error = "Trying to acces a font ouf of range."; 
    return BASIC_FONT;  
  }
  
  /**
   * @return  number of the fonts present
   */
  public final int getFontCount() {
    return fonts.size();
  }
  
  /**
   * Obtain a decimal representation of the color based on its components, referenced by a string name. Raise an error if it is not present.
   *
   * @param name  name of the requested color
   *
   * @return  decimal representation of the color if present, otherwise black
   */
  public int getColor(String name) {
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
  public void control() {
    String error_pref = "Missing data from the tag: ";
    if (ID == -1)
      error = error_pref + "ID.";
    if (target_url.compareTo("") == 0)
      error = error_pref + "URL.";
  }
}
/**
 * This parser connects to an XML file a cycles through its highest level nodes. If there is matching with known tags, it stores the tags. Otherwise it raises an error.
 */
public class XMLParser
{
  /**
   * An entry point for parsing. Function parses nodes one step in depth of the file and if their tags are matching, it stores their data.
   *
   * @param filename  a file to actually parse
   */
  public void parse(String filename) {
    XML root = loadXML(filename); // Gets the root node, in this case DATABASE.
    if (root == null) {
      error = "The settings.xml file not found in the data folder.";
      return;
    }
    XML[] entries = root.getChildren(); // Gets all the children of DATABASE node.
    parseNodes(entries); // Parses the children.
  }

  /**
   * Less error-prone attribute parser.
   *
   * @param name  an attribute to search for
   * @param node  an XML node that is searched for the attribute
   *
   * @return  a content of the parameter or an empty string if it was not found
   */
  private String getAttribute(String name, XML node) {
    String data = node.getString(name);
    if (data == null) {
      error = name + " attribute was not found in a node " + node + ".";
      data = "";
    }
    return data;
  }

  /**
   * Main parsing logic - on an initial element event, this is called and in dependency on TAG name the content is red and set in the settings object.
   *
   * @param entries  a field of nodes that should be parsed for data
   */
  private void parseNodes(XML [] entries)
  {
    for (int i = 0; i < entries.length; i++) {
      String node = entries[i].getName();
      
      if (node.equals("#text") || node.equals("#comment")) { // Skip comment nodes
        continue;
      } else if (node.equals("ID")) {
        settings.ID = Integer.valueOf(getAttribute("value", entries[i]));
        if (settings.ID == 0) // Terminal numbered 0 is the illegal one.
          settings.illegal = true;
      } else if (node.equals("ONLINE")) {
        settings.on_line = Boolean.valueOf(getAttribute("value", entries[i]));
      } else if (node.equals("WIDTH")) {
        settings.screen_width = Integer.valueOf(getAttribute("value", entries[i]));
      } else if (node.equals("HEIGHT")) {
        settings.screen_height = Integer.valueOf(getAttribute("value", entries[i]));
      } else if (node.equals("TEXTSIZE")) {
        settings.text_size = Integer.valueOf(getAttribute("value", entries[i]));
      } else if (node.equals("CAPSSIZE")) {
        settings.caps_size = Integer.valueOf(getAttribute("value", entries[i]));
      } else if (node.equals("URL")) {
        settings.target_url = getAttribute("url", entries[i]);     
      } else if (node.equals("FONT")) {
        settings.addFont(getAttribute("name", entries[i]), getAttribute("move", entries[i]));     
      } else if (node.equals("STRING")) {
        settings.strings.put(getAttribute("name", entries[i]), getAttribute("text", entries[i]));     
      } else if (node.equals("IMAGES_COUNT")) {
        settings.images_num = Integer.valueOf(getAttribute("value", entries[i]));   
      } else if (node.equals("DELAY")) {
        settings.delay = Integer.valueOf(getAttribute("value", entries[i]));   
      } else if (node.equals("IMAGE_SUFFIX")) {
        settings.image_suffix = getAttribute("value", entries[i]);   
      } else if (node.equals("COLOR")) {
        Vector parts = new Vector();
        parts.add(getAttribute("r", entries[i]));
        parts.add(getAttribute("g", entries[i]));     
        parts.add(getAttribute("b", entries[i]));  
        parts.add(getAttribute("a", entries[i]));       
        settings.colors.put(getAttribute("name", entries[i]), parts);           
      } else { // If the tag is not found, result with an error.
        error = node + " is not a known tag.";      
      }
    }
  }
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Database" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
