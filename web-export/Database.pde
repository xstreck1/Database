import org.xml.sax.XMLReader;
import org.xml.sax.helpers.XMLReaderFactory;
import org.xml.sax.helpers.DefaultHandler;
import org.xml.sax.Attributes;
import org.xml.sax.InputSource;

// Number of frames per second
final int FRAME_RATE = 50; 
// Counter of repetitions of display operation
int draw_count = 0;

// Singular objects that will be used during the computation
// THESE ARE SHARED PROJECT-WISE!
Keyboard    keyboard;
Environment environment;
Data        data;
HTTPHelper  http;
Settings    settings;
Dimensions  dims;

// A list of images cycling on the background
PImage [] background_images;

// A string that is filled if something goes wrong - basically non-intrusive version of an exception. Mainly would be raised if a parsed tag in the settings.xml is unknown.
String error = "";

/**
 * THE ENTRY FUNCTION OF THE APPLICATION
 */ 
@Override
void setup() {
  // Load data
  parseSettings();
  loadBackground();
  
  // Create handling objects
  dims        = new Dimensions();
  keyboard    = new Keyboard();
  environment = new Environment();
  data        = new Data();
  http        = new HTTPHelper();
  
  // Setup graphics
  size(settings.screen_width, settings.screen_height, JAVA2D);
  PImage my_cursor = loadImage("Cursor.png");
  cursor(my_cursor, 16, 16);
  smooth();
  frameRate(FRAME_RATE);
  draw();  
  
  // Start the terminal as required
  environment.setScreen(settings.illegal ? 3 : 1);     
}

@Override
void draw() { 
  // Display error if there is some
  if (!error.isEmpty())
    environment.setScreen(4);  
    
  // Decide current BG image number
  int img_num = ((draw_count % (settings.delay * settings.images_num)) / settings.delay);
  
  // Display the image if there is one
  if (background_images[img_num] != null)
    background(background_images[img_num]);
  else
    background(settings.getColor("background")); 
  
  // Display buttons and data over the background
  keyboard.displayButtons();
  data.display();
  
  // Within a loop, check status from time to time (100 == 2 secs)
  if ((draw_count++ % 100) == 0) {
    // http.check();
  }
}

@Override
void mouseMoved() {
  keyboard.mouseMove();
}

@Override
void mousePressed() {
  keyboard.mousePress();
}

/**
 * Function to get settings from the settings file
 */
void parseSettings() {
  // Create a new settings object - up till now there was none.
  settings = new Settings();
  
  // Setup parser and parse settings.
  try {
    XMLReader xr = XMLReaderFactory.createXMLReader();
    XMLParse handler = new XMLParse();
    xr.setContentHandler(handler);
    xr.setErrorHandler(handler);
    xr.parse(new InputSource("settings.xml")); // This call causes the whole parsing process
  }
  catch (Exception e) {
    e.printStackTrace();
    error = e.getMessage(); // Set error if something happenss
  }
  
  // Control if everything that has to be set is set.
  settings.control();
  
  // Log out progress.
  System.out.println("Parsing finished correctly."); 
}

/**
 * Load (once) images that will be displayed as a background.
 * Images are to be in the form "width"x"height"_"animation index form 1"."suffix as given in settings"
 */
void loadBackground() {
  // Create space to store the images
  background_images = new PImage[settings.images_num];
  
  // Create prefix of files that will be read
  String file = String.valueOf(settings.screen_width);
  file = file.concat("x");
  file = file.concat(String.valueOf(settings.screen_height));
  
  // Obtain all images as described in the settings
  for (int i = 1; i <= settings.images_num; i++) {
    background_images[i-1] = loadImage(file + "_" + i + settings.image_suffix);
  }
}


/**
 * Class that handles I/0 and text formatting.
 */
class Data {
  ArrayList output_stream; // List of strings, each corresponding to a single line of the output
  String input_stream; // The string containing the user-given text
  int first_output; // Ordinal number of the first line that is displayed

  /**
   * Constructor just clears objects to the references
   */
  Data() {
    clear();
  }
  
  /**
   * Assigns new objects to the employed references
   */
  void clear() {
    output_stream = new ArrayList();
    input_stream = "";
    first_output = 0;
  }
  
  /**
   * Reset current data based on the screen you are in.
   * Options correspond to username, password, interactive mode and error.
   */
  void setScreenData() {
    switch (environment.getScreen()) {
      case 1: // Username
        clear();
        output(settings.getText("username"));       
        break;
        
      case 2: // Password
        clear();
        output(settings.getText("password") + environment.getAccountName());       
        break;
        
      case 3: // Interface
        clear();
        if (settings.illegal)
          output(settings.getText("welcome") + "???");
        else {
          output(settings.getText("welcome") + environment.getAccountName() + ".");
          output(settings.getText("logoff") );
        }       
        break;
        
      case 4: // Error
        clear();
        output(error);
        error = ""; // After error the user will be allowed to continue normally.      
        break;
    }
  }

  /**
   * Called when the user confirms his typed username.
   * Just moves to the password screen.
   * TODO: Move to Keyboard.
   */
  void username() {
    environment.setAccount(input_stream);
    environment.setScreen(2);
  }
  
  /**
   * Called when the user confirms the typed in password.
   * Control if the user has the access rights - currently take both DENIED and NOT and OK, but sth else should be put here.
   * TODO: Move to Keyboard.
   */
  void password() {
    environment.password = input_stream;
    String valid = http.findEntry("ACCOUNT_VALID");
    if (valid.substring(0,6).contentEquals("DENIED") || valid.substring(0,2).contentEquals("OK") || valid.substring(0,3).contentEquals("NOT")) {
      environment.setScreen(3);
    }
    else {
      environment.setScreen(1);   
      output(settings.getText("wronglogin"));
    }
  }
  
  /**
   * Called when the user confirms the search of the input.
   * TODO: Move to Keyboard.
   */
  void search() {
    if (input_stream.equals("EXIT")) {
      if (settings.illegal)
        output(settings.getText("illegallogoff"));
      else {
        environment.setScreen(1);
        clear();
        output(settings.getText("logoffreset"));
      }
    }
    else {
      String result = http.findEntry(input_stream);
      if (result.substring(0,2).contentEquals("OK")) {
        output(input_stream + ": " + result.substring(3));
      } else if (result.substring(0,6).contentEquals("DENIED")) {
        output(input_stream + ": " + settings.getText("denied"));
      } else if (result.substring(0,6).contentEquals("NOT FOUND")) {
        output(input_stream + ": " + settings.getText("notfound"));
      } else if (result.substring(0,6).contentEquals("CORRUPTED")) {
        output(input_stream + ": " + settings.getText("corrupted"));
      }
      display();
    }
  }
  
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Input stream manipulation
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  void addLetter(char letter) {
    input_stream = input_stream.concat(str(letter));
    if (textWidth(input_stream) > (dims.keyboard_width-2*dims.text_indent)) {
      eraseLast();
      output(settings.getText("outofbounds"));
    }
  }
  
  void eraseLast() {
    if (input_stream.length() > 0)
      input_stream = input_stream.substring(0,input_stream.length()-1);
  }
  
  void eraseAll() {
    input_stream = new String();
  }
  
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Output stream manipulation
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
  /**
   * Reformats the string and places it into the ouput container
   */
  void output(String new_text) {
    // Remove newline symbols from the string
    new_text.replace('\n', ' ');
    new_text.replace('\r', ' ');
    // Add the text to the output
    addToOutput(new_text);
    first_output = max (0, (output_stream.size() - dims.lines_count));
  }
  
  /**
   *
   */
  void addToOutput(String new_text) {
    if ((new_text.indexOf('\n') != -1) && (new_text.indexOf('\n') != new_text.length() - 1)) {
      if (new_text.indexOf('\n') != 0)
        addToOutput(new_text.substring(0,new_text.indexOf('\n')));
      addToOutput(new_text.substring(new_text.indexOf('\n')+1));     
    }
    else if (textWidth(new_text) <= (dims.output_width-2*dims.text_indent)) {
      output_stream.add(new_text + "\n");
    }
    else {
      int subset_length = 0;
      // while the substring is too long or can't be spliced, shorten it
      while ((textWidth(new_text.substring(0, subset_length)) < (dims.output_width-2*dims.text_indent)) && (subset_length < new_text.length()))
        subset_length++;
      subset_length--;
      while (subset_length > 0 && Character.isLetter(new_text.charAt(subset_length)))
        subset_length--;    
       
      boolean toAdd = false;
      for (int i = 0; i < subset_length; i++) {
          toAdd = Character.isLetter(new_text.charAt(i)) || Character.isDigit(new_text.charAt(i));
      }
      
      if (new_text.charAt(subset_length) == ' ')
        subset_length++;
      if (toAdd)
        output_stream.add(new_text.substring(0, subset_length));
      addToOutput(new_text.substring(subset_length));
    }
  }
  
  void reFormatOutput() {
    String output_content = new String();
    for (int i = 0; i < output_stream.size(); i++) {
      output_content = output_content.concat((String) output_stream.get(i));
    }
    output_stream.clear();
    
    textFont(environment.getCurrentFont(), dims.text_size);
    
    addToOutput(output_content);
  }

  void scrollFirst() {
    first_output = 0;
    display();  
  }
  
  void scrollBackwards() {
    first_output = max (first_output - 1, 0);
    display();  
  }
  
  void scrollForward() {
    first_output = max (min (first_output + 1, (output_stream.size() - dims.lines_count)), 0);
    display();  
  }
  
  void scrollLast() {
    first_output = max(0, output_stream.size() - dims.lines_count);
    display();  
  }

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Visual
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  void display() {
    textFont(environment.getCurrentFont(), dims.text_size);
    noStroke();
    fill(settings.getColor("field"));
    rect(dims.input_x, dims.input_y + int(dims.basic_key_size*0.25), dims.keyboard_width, dims.text_size); 
    rect(dims.input_x, dims.input_y + int(dims.basic_key_size*0.75), dims.output_width, dims.output_height); 
        
    switch (environment.getScreen()) {
      case 1: case 2:  case 3:
        fill(settings.getColor("text"));
        textAlign(LEFT);
        text(input_stream, dims.input_x + dims.text_indent, dims.input_y + int(dims.basic_key_size*0.25) + dims.text_size*0.8);
        for (int i = first_output; i < (min(output_stream.size(), (first_output + dims.lines_count))); i++) {
          text((String) output_stream.get(i), dims.input_x + dims.text_indent,  int(dims.basic_key_size*0.75) + dims.input_y + dims.text_size*(1 + i - first_output));
        }
      break;
      
      case 4:
        fill(settings.getColor("error"));
        textAlign(LEFT);
        for (int i = first_output; i < (min(output_stream.size(), (first_output + dims.lines_count))); i++) {
          text((String) output_stream.get(i), dims.input_x + dims.text_indent,  int(dims.basic_key_size*0.75) + dims.input_y + dims.text_size*(1 + i - first_output));
        }
      break;
      
      case 5:
        fill(settings.getColor("text"));
        textAlign(LEFT);
        text(input_stream, dims.input_x + dims.text_indent, dims.input_y + int(dims.basic_key_size*0.25) + dims.text_size*0.8);
        fill(settings.getColor("offline"));
        textAlign(CENTER);
        textSize(250);
        text("OFF", dims.input_x + dims.output_width/2,  int(dims.basic_key_size*0.75) + dims.input_y + dims.output_height/2 + 80);
      break;
    }
  }
}
/**
 * Class holds layout placement values.
 */
public class Dimensions {
  // Screen dimensions
  int width_;
  int height_;

  // Layout variables - THESE ARE SET
  int border_x; // Space between layout and window horizontally
  int border_y; // Space between layout and window vertically
  int basic_key_size; // Key size
  int caps_size; // GUI text
  int text_size; // I/O text
  final int text_indent = 3;  // Space between window and text
  final int buttons_count = 38; // How many buttons are active

  // Object placement variables - just for simplicity in reccurent uses - THESE ARE COMPUTED
  int keyboard_x; // Leftmost corner x position of the virtual keyboard
  int keyboard_y; // Leftmost corner y position of the virtual keyboard
  int keyboard_width; // Leftmost corner y position of the virtual keyboard
  int wide_key_size; // Size of the bigger key (e.g. "erase")
  int input_x; // Leftmost corner x position of the input filed
  int input_y; // Leftmost corner y position of the input filed
  int output_width; // Width of the output field
  int output_height; // Height of the output field
  int lines_count; // Number of lines in the output filed

  /**
   * The constructor sets the values.
   */
  Dimensions() {
    // Obtain the size from settings
    width_ = settings.screen_width;
    height_ = settings.screen_height;

    // Relate basic values to this setting
    border_y = round(height_ * 0.05);
    border_x = round(height_ * 0.05) + round((width_ - height_*1.3)/2.0);
    basic_key_size = round(height_ *0.1);
    caps_size = settings.caps_size;
    text_size = settings.text_size;

    // Compute helping values from the basic ones.
    keyboard_x     = border_x;
    keyboard_y     = height_ - basic_key_size*3 - border_y;
    keyboard_width = basic_key_size*12;
    wide_key_size  = basic_key_size*3;
    input_x        = border_x;
    input_y        = basic_key_size + border_y;
    output_width   = keyboard_width - basic_key_size;
    output_height  = basic_key_size*4;
    lines_count    = (int) ((float) (output_height - text_indent*2)  / (float) text_size);
  }
}

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

  void setAccount(String name) {
    user_name = name;
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
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;

/**
 * Class handles http comunication.
 */
class HTTPHelper {
  URL url;
  URLConnection conn;
  
  String connect (String URL) throws MalformedURLException, IOException {
    url = new URL(URL);
    conn = url.openConnection();
    conn.connect();
		
    InputStreamReader content;
    content = new InputStreamReader(conn.getInputStream());
    char [] buffer;
    int max_lenght = 100; // Current lenght of the buffer
    
    // Increase the buffer size until you read it all
    do {
      max_lenght *= 2;
      buffer = new char[max_lenght]; }
    while (content.read(buffer, 0, max_lenght) >= max_lenght);
    
    return new String(buffer);
  }

  /**
   * Get data from server. 
   */
  String findEntry(String key_word) {
    String result = "";
    String my_query = new String(settings.target_url + "?klic=" + key_word + "&login=" + environment.user_name + "&password=" + environment.password);  
    
    System.out.print("Query: " + my_query); // Debug output
    
    try {
      result = connect(my_query);
    }
    catch (Exception e) {
      e.printStackTrace();
      error = "Chyba spojeni s databazi.";
      result = "Error.";
    }
        
    int index_of_empty = (result.indexOf(0x0) == -1) ? result.length() : result.indexOf(0x0);
    result = result.substring(0, index_of_empty);
    
    System.out.println(". Response: " + result); // Debug output
    
    return result;
  }

  /**
   * Check status of the database on the server.
   */  
  void check() {    
    String status = "";
    try {
      status = connect(settings.target_url + "CHECK");
    }
    catch (Exception e) {
      e.printStackTrace();
      error = e.getMessage();
    }  
  }
}
/**
 * Keyboard is completelly responsible for the appereance and functionallity of the virtual keyboard acessible to user.
 */
class Keyboard {
  Button[] buttons; ///< Holder for all the buttons that are actually used.
  int hover_button; ///< ID of the button that has a mouse over it at the moment.

  /**
   * 
   */
  Keyboard() {
    createButtons();
    hover_button = dims.buttons_count;
  }

  void createButtons() {
    buttons = new Button [dims.buttons_count];
    int button_num = 0;

    // Basic input buttons
    char caption = char(64);
    for (int y_counter = 0; y_counter < 3; y_counter++) {
      for (int x_counter = 0; x_counter < 9; x_counter++, button_num++) {
        if (button_num != 26)
          caption += 1;
        else // Last button - space
        caption = char(95);
        buttons[button_num] = new Button(str(caption), dims.keyboard_x + x_counter*(dims.basic_key_size), dims.keyboard_y + y_counter*+dims.basic_key_size);
      }
    }

    // Special input buttons
    buttons[button_num++] = new Button("Potvrd", 9*dims.basic_key_size + dims.border_x, dims.keyboard_y + 0*dims.basic_key_size, 
    dims.wide_key_size, dims.basic_key_size);                                 
    buttons[button_num++] = new Button("Smaz"  , 9*dims.basic_key_size + dims.border_x, dims.keyboard_y + 1*dims.basic_key_size, 
    dims.wide_key_size, dims.basic_key_size);
    buttons[button_num++] = new Button("Zrus"  , 9*dims.basic_key_size + dims.border_x, dims.keyboard_y + 2*dims.basic_key_size, 
    dims.wide_key_size, dims.basic_key_size);

    // Environment language buttons
    buttons[button_num++] = new Button(settings.getFont(0), dims.wide_key_size*0 + dims.border_x, dims.border_y, dims.wide_key_size, dims.basic_key_size);                                 
    buttons[button_num++] = new Button(settings.getFont(1), dims.wide_key_size*1 + dims.border_x, dims.border_y, dims.wide_key_size, dims.basic_key_size);   
    buttons[button_num++] = new Button(settings.getFont(2), dims.wide_key_size*2 + dims.border_x, dims.border_y, dims.wide_key_size, dims.basic_key_size);  
    buttons[button_num++] = new Button(settings.getFont(3), dims.wide_key_size*3 + dims.border_x, dims.border_y, dims.wide_key_size, dims.basic_key_size);

    // Output scroll buttons
    buttons[button_num++] = new Button("<<", 11*dims.basic_key_size + dims.border_x, dims.input_y + int(dims.basic_key_size*0.75), dims.basic_key_size, dims.basic_key_size);
    buttons[button_num++] = new Button("<", 11*dims.basic_key_size + dims.border_x, dims.input_y + int(dims.basic_key_size*0.75) + dims.basic_key_size, dims.basic_key_size, dims.basic_key_size);
    buttons[button_num++] = new Button(">", 11*dims.basic_key_size + dims.border_x, dims.input_y + int(dims.basic_key_size*0.75) + dims.basic_key_size*2, dims.basic_key_size, dims.basic_key_size);
    buttons[button_num++] = new Button(">>",  11*dims.basic_key_size + dims.border_x, dims.input_y + int(dims.basic_key_size*0.75) + dims.basic_key_size*3, dims.basic_key_size, dims.basic_key_size);
  }  

  void displayButtons() {
    textFont(environment.getCurrentFont(), dims.caps_size);
    for (int i = 0; i < dims.buttons_count; i++) // Display only this environments buttons
      buttons[i].display();
  }

  void mouseMove() {
    // Turn of the current button
    buttons[hover_button].highlight(false);
    
    // Check if there is a button under the cursor - if so, turn it on.
    int current_button = -1;
    for (i = 0; i < dims.buttons_count && current_button == -1; i++)
      if (buttons[i].testMousePosition()) {
        current_button = i;
        buttons[i].highlight(true);
      }
  }
  
  void mousePress() {
    if (hover_button == dims.buttons_count)
      return;
    
    String button = buttons[hover_button].getCaption();
    if (hover_button >= 0 && hover_button < 27) {
      if (hover_button == 26)
        data.addLetter(' ');
      else
        data.addLetter(button.charAt(0));
    }
    else if (button.equals("Potvrd")) {
        switch (environment.getScreen()) {
        case 1:
          data.username();  
        break;
        case 2:
          data.password();      
        break;
        case 3:
          data.search();  
        break;
        case 4:
          environment.setScreen(settings.illegal ? 3 : 1);   
        break;
      }
    }
    else if (button.equals("Smaz")) {
      data.eraseLast();
    }
    else if (button.equals("Zrus")) {
      data.eraseAll();
    }
    
    else if (button.equals(settings.getFont(0)) || button.equals(settings.getFont(1)) || button.equals(settings.getFont(2)) || button.equals(settings.getFont(3))) {
      environment.changeFont(button);
      data.reFormatOutput(); 
      data.first_output = max(0, min(data.first_output, data.output_stream.size() - dims.lines_count));
    }
    else if (button.equals("<<")) {
      data.scrollFirst();
    }
    else if (button.equals("<")) {
      data.scrollBackwards();
    }
    else if (button.equals(">")) {
      data.scrollForward();
    }
    else if (button.equals(">>")) {
      data.scrollLast();
    }
  }
}

/**
 * Class for all button objects
 */
class Button {
  int x_pos, y_pos, x_size, y_size;
  boolean is_mouse_over = false;
  String caption;

  // Full constructor
  Button (String cap, int xp, int yp, int xs, int ys) {
    caption = cap;
    x_pos = xp;
    y_pos = yp;
    x_size = xs;
    y_size = ys;
  }

  // Basic constructor for simpliest buttons
  Button (String cap, int xp, int yp) {
    caption = cap;
    x_pos = xp;
    y_pos = yp;
    x_size = dims.basic_key_size;
    y_size = dims.basic_key_size;
  }

  void display() {    
    textAlign(CENTER);
    if (is_mouse_over) {
      fill(settings.getColor("highlight"));
    }
    else {
      fill(settings.getColor("caption"));
    }   
    text(caption, x_pos + (x_size/2), y_pos + (dims.basic_key_size + dims.caps_size*3/5)/2);
  }

  boolean testMousePosition() {
    if (mouseX >= x_pos && mouseX <= x_pos + x_size &&  mouseY >= y_pos && mouseY <= y_pos+y_size)
      return true;
    else 
      return false;
  }

  void highlight(boolean on) {
    is_mouse_over = on;
  }
  
  String getCaption() {
    return caption;
  }
}
/**
 * Contains settings load from the xml file. 
 * Most settings are not really that important or have default values, that are instantiated in the constructor. The mandatory ones can be checked using the "control" function.
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
   * This function controls if all the mandatory tags are set in the way sufficient for the sucessful run of the app.
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
/**
 * This class inherits its skills from the Default XML handler and is used for parsing an XML file.
 * Using the parse command (not even mentione here), the object parses data from the file to which it is connected and stores them in the settings object.
 */
public class XMLParse extends DefaultHandler
{ 
  /**
   * Constructor just calls its handler super-class.
   */
  public XMLParse ()
  {
    super();
  }

  /**
   * More error-prone attribute parser.
   */
  String getAttribute(String name, Attributes atts) {
    if (atts.getValue(name) == null) {
      error = (name.concat(" attribute was not found where expected."));
      return "";  
    }
    return atts.getValue(name);
  }

  /**
   * Main parsing logic - on an initial element event, this is called and in dependency on TAG name the content is red and set in the settings object.
   */
  @Override
  public void startElement (String uri, String name, String qName, Attributes atts)
  {
    if (qName.equals("DATABASE")) {
      System.out.println("Parsing started."); 
    } else if (qName.equals("ID")) {
      settings.ID = Integer.valueOf(getAttribute("value", atts));
    } else if (qName.equals("ILLEGAL")) {
      settings.illegal = Boolean.valueOf(getAttribute("value", atts));
    } else if (qName.equals("WIDTH")) {
      settings.screen_width = Integer.valueOf(getAttribute("value", atts));
    } else if (qName.equals("HEIGHT")) {
      settings.screen_height = Integer.valueOf(getAttribute("value", atts));
    } else if (qName.equals("TEXTSIZE")) {
      settings.text_size = Integer.valueOf(getAttribute("value", atts));
    } else if (qName.equals("CAPSSIZE")) {
      settings.caps_size = Integer.valueOf(getAttribute("value", atts));
    }  else if (qName.equals("URL")) {
      settings.target_url = getAttribute("url", atts);     
    } else if (qName.equals("FONT")) {
      settings.fonts.add(getAttribute("name", atts));     
    } else if (qName.equals("STRING")) {
      settings.strings.put(getAttribute("name", atts), getAttribute("text", atts));     
    } else if (qName.equals("IMAGES_COUNT")) {
      settings.images_num = Integer.valueOf(getAttribute("value", atts));   
    } else if (qName.equals("DELAY")) {
      settings.delay = Integer.valueOf(getAttribute("value", atts));   
    } else if (qName.equals("IMAGE_SUFFIX")) {
      settings.image_suffix = getAttribute("value", atts);   
    } else if (qName.equals("COLOR")) {
      Vector parts = new Vector();
      parts.add(getAttribute("r", atts));
      parts.add(getAttribute("g", atts));     
      parts.add(getAttribute("b", atts));  
      parts.add(getAttribute("a", atts));       
      settings.colors.put(getAttribute("name", atts), parts);           
    } else { // If the tag is not found, result with an error
      error = (qName.concat(" is not a known tag."));      
    }
  }
}

