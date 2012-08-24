import processing.core.*; 
import processing.data.*; 
import processing.opengl.*; 

import org.xml.sax.XMLReader; 
import org.xml.sax.helpers.XMLReaderFactory; 
import org.xml.sax.helpers.DefaultHandler; 
import org.xml.sax.Attributes; 
import org.xml.sax.InputSource; 
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







Keyboard    keyboard;
Environment environment;
Data        data;
HTTPHelper  http;
Settings    settings;
Dimensions  dims;

PImage background_image;
String error;
int draw_count = 0;

public void parseSettings() {
  settings = new Settings();
  
  // Setup parser and parse settings
  try {
    XMLReader xr = XMLReaderFactory.createXMLReader();
    XMLParse handler = new XMLParse();
    xr.setContentHandler(handler);
    xr.setErrorHandler(handler);
    xr.parse(new InputSource("settings.xml"));
  }
  catch (Exception e) {
    e.printStackTrace();
    error = e.getMessage();
  } 
}

public void loadBackground() {
  String file = String.valueOf(settings.screen_width);
  file = file.concat("x");
  file = file.concat(String.valueOf(settings.screen_height));
  file = file.concat(".png");
  
  background_image = loadImage(file);
}

public void setup() {
  error = "";
  parseSettings();
  loadBackground();
  
  dims = new Dimensions();
  keyboard    = new Keyboard();
  environment = new Environment();
  data        = new Data();
  http        = new HTTPHelper();
  
  size(settings.screen_width, settings.screen_height, JAVA2D);
  PImage my_cursor = loadImage("Cursor.png");
  cursor(my_cursor, 16, 16);
  smooth();
       
  draw();  
  environment.setScreen(1);
}

public void draw() {
  if (!error.isEmpty())
    environment.setScreen(4);  
  if (background_image != null)
    background(background_image);
  keyboard.displayButtons();
  data.display();
  
  // Within a loop, check status from time to time
  if (draw_count++ > 50) {
    http.check();
    draw_count = 0;
  }
}

public void mouseMoved() {
  keyboard.mouseMove();
}

public void mousePressed() {
  keyboard.mousePress();
}


/**
 * Class that handles I/0 and text formatting 
 */
class Data {
  ArrayList output_stream;  
  String input_stream;
  int first_output;

  Data() {
    clear();
  }
  
  public void clear() {
    output_stream = new ArrayList();
    output_stream.add("");
    input_stream = new String();
    first_output = 0;
  }
  
  public void setScreenData() {
    switch (environment.getScreen()) {
      case 1:
        output_stream.clear();
        output(settings.getText("username"));       
      break;
      case 2:
        output_stream.clear();
        output(settings.getText("password") + environment.getAccountName());       
      break;
      case 3:
        output_stream.clear();
        output(settings.getText("welcome") + environment.getAccountName() + ".");
        output(settings.getText("logoff") );       
      break;
    }
  }
  
  // If in the third (database) screen, add data to output, otherwise replace current output with data
  public void output(String new_text) {
    if (environment.getScreen() == 3) {
      new_text.replace('\r', ' ');
      addToOutput(new_text);
      first_output = max (0, (output_stream.size() - dims.lines_count));
    }
    else {
      output_stream.clear();
      output_stream.add(new_text);
    }
  }
  
  public void addToOutput(String new_text) {
    if (new_text.indexOf('\n') != -1) {
      if (new_text.indexOf('\n') != 0)
        addToOutput(new_text.substring(0,new_text.indexOf('\n')));
      addToOutput(new_text.substring(new_text.indexOf('\n')+1));     
    }
    else if (textWidth(new_text) <= (dims.output_width-2*dims.text_indent)) {
      output_stream.add(new_text);
    }
    else {
      int subset_length = 0;
      // while the substring is too long or can't be spliced, shorten it
      while (textWidth(new_text.substring(0, subset_length)) < (dims.output_width-2*dims.text_indent))
        subset_length++;
      subset_length--;
      while (subset_length > 0 && Character.isLetter(new_text.charAt(subset_length)))
        subset_length--;    
       
      boolean toAdd = false;
      for (int i = 0; i < subset_length; i++) {
          toAdd = Character.isLetter(new_text.charAt(i)) || Character.isDigit(new_text.charAt(i));
      }     
      if (toAdd) output_stream.add(new_text.substring(0, subset_length));
      addToOutput(new_text.substring(new_text.charAt(subset_length) == ' ' ? subset_length + 1 : subset_length));
    }
  }
  
  public void reFormatOutput() {
    String output_content = new String();
    for (int i = 0; i < output_stream.size(); i++) {
      output_content = output_content.concat((String) output_stream.get(i));
    }
    output_stream.clear();
    
    textFont(environment.getCurrentFont(), dims.text_size);
    
    addToOutput(output_content);
  }
  
  public void username() {
    if (environment.accountExists(input_stream)) {
      environment.setAccount(input_stream);
      environment.setScreen(2);
      eraseAll();
    }
    else {
      output(settings.getText("noname"));
    }
  }
  
  public void password() {
    if (environment.passwordMatches(input_stream)) {
      environment.setScreen(3);
      eraseAll(); 
    }
    else {
      environment.setScreen(1);      
      output(settings.getText("wrongpass"));
      eraseAll();
    }
  }
  
  public void search() {
    if (input_stream.equals("EXIT")) {
      environment.setScreen(1);
      clear();
      data.output(settings.getText("logoffreset"));
    }
    else {
      output(input_stream + ": " + (http.findEntry(input_stream)));
      display();
    }
  }
  
  public void addLetter(char letter) {
    input_stream = input_stream.concat(str(letter));
    if (textWidth(input_stream) > (dims.keyboard_width-2*dims.text_indent)) {
      eraseLast();
      output(settings.getText("outofbounds"));
    }
  }
  
  public void eraseLast() {
    if (input_stream.length() > 0)
      input_stream = input_stream.substring(0,input_stream.length()-1);
  }
  
  public void eraseAll() {
    input_stream = new String();
  }
  
  public void scrollFirst() {
    first_output = 0;
    display();  
  }
  
  public void scrollBackwards() {
    first_output = max (first_output - 1, 0);
    display();  
  }
  
  public void scrollForward() {
    first_output = max (min (first_output + 1, (output_stream.size() - dims.lines_count)), 0);
    display();  
  }
  
  public void scrollLast() {
    first_output = max(0, output_stream.size() - dims.lines_count);
    display();  
  }

  public void display() {
    textFont(environment.getCurrentFont(), dims.text_size);
    fill(settings.getColor("field"));
    noStroke();
    
    switch (environment.getScreen()) {
      case 1:
        rect(dims.input_x, dims.input_y + (dims.keyboard_y - dims.input_y)/2, dims.output_width, dims.text_size); 
        fill(settings.getColor("text"));
        textAlign(CENTER);
        text((String) output_stream.get(0), (dims.input_x + dims.text_indent*2 + dims.output_width)/2, dims.input_y + (dims.keyboard_y - dims.input_y - dims.text_size)/2);
        textAlign(CENTER);    
        text(input_stream , (dims.input_x + dims.text_indent*2 + dims.output_width)/2, dims.input_y + (dims.keyboard_y - dims.input_y)/2 + (dims.text_size/5*4)); // Y is a little bit higher - whole field is not needed withoud diacritics
      break;      
      
      case 2:
        rect(dims.input_x, dims.input_y + (dims.keyboard_y - dims.input_y)/2, dims.output_width, dims.text_size); 
        fill(color(settings.getColor("text")));
        textAlign(CENTER);
        text((String) output_stream.get(0), (dims.input_x + dims.text_indent*2 + dims.output_width)/2, dims.input_y + (dims.keyboard_y - dims.input_y - dims.text_size)/2);
        textAlign(CENTER);    
        text(input_stream , (dims.input_x + dims.text_indent*2 + dims.output_width)/2, dims.input_y + (dims.keyboard_y - dims.input_y)/2 + (dims.text_size/5*4)); // Y is a little bit higher - whole field is not needed withoud diacritics
      break;   
      
      case 3:
        rect(dims.input_x, dims.input_y + PApplet.parseInt(dims.basic_key_size*0.25f), dims.keyboard_width, dims.text_size); 
        rect(dims.input_x, dims.input_y + PApplet.parseInt(dims.basic_key_size*0.75f), dims.output_width, dims.output_height); 
        fill(settings.getColor("text"));
        textAlign(LEFT);
        text(input_stream, dims.input_x + dims.text_indent, dims.input_y + PApplet.parseInt(dims.basic_key_size*0.25f) + dims.text_size*0.8f); // Y is a little bit higher - whole field is not needed withoud diacritics
        for (int i = first_output; i < (min(output_stream.size(), (first_output + dims.lines_count))); i++) {
          text((String) output_stream.get(i), dims.input_x + dims.text_indent,  PApplet.parseInt(dims.basic_key_size*0.75f) + dims.input_y + dims.text_size*(1 + i - first_output));
        }
      break;
      
      case 4:
        rect(dims.input_x, dims.input_y + PApplet.parseInt(dims.basic_key_size*0.25f), dims.output_width, dims.output_height + PApplet.parseInt(dims.basic_key_size*0.5f)); 
        fill(settings.getColor("error"));
        textAlign(LEFT);
        text(error, dims.input_x + dims.text_indent, dims.input_y + PApplet.parseInt(dims.basic_key_size*0.25f) + (dims.text_size*0.75f));
      break;    
    }
  }
}
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

  public void loadFonts() {
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
  
  public boolean accountExists(String name) {
    return settings.users.containsKey(name);
  } 

  public void setAccount(String name) {
    user_name = name;
  }
  
  public boolean passwordMatches(String pass) {
    return (0 == pass.compareToIgnoreCase((String) settings.users.get(user_name)));
  }
  
  public String getAccountName() {
    return user_name;
  }  

  public PFont getCurrentFont() {
    return (PFont) fonts.get(currentFont);
  }
  
  public int getScreen() { 
    return screen_type;
  }
  
  public void setScreen(int new_screen) { 
    screen_type = new_screen;
    buttons_count = (new_screen == 3) ? BUTTON_COUNT : (BUTTON_COUNT - 4);
    data.setScreenData();
  }
  
  public void changeFont(String font_name) {
    currentFont = font_name;
    data.reFormatOutput();
  }
  
  public int getButtonsCount() {
    return buttons_count;
  }
}




/**
 * Class handles http comunication.
 */
class HTTPHelper {
  URL url;
  URLConnection conn;
  final static int max_lenght = 10000;
    
  public String connect (String URL) throws MalformedURLException, IOException {
    url = new URL(URL);
    conn = url.openConnection();
    conn.connect();
		
    InputStreamReader content;
    content = new InputStreamReader(conn.getInputStream());
    
    char [] buffer = new char[max_lenght];
    if (content.read(buffer, 0, max_lenght) >= max_lenght)
      throw new IOException("Text too long");
    return new String(buffer);
  }

  /**
   * Get data from server. 
   */
  public String findEntry(String key_word) {
    String result;
      
    try {
      result = http.connect(settings.target_url);
    }
    catch (Exception e) {
      e.printStackTrace();
      error = e.getMessage();
      result = "Error.";
    }
    
    return result;
  }

  /**
   * Check status of the database on the server.
   */  
  public void check() {    
    try {
      http.connect(settings.target_url);
    }
    catch (Exception e) {
      e.printStackTrace();
      error = e.getMessage();
    }  
  }
}
/**
 * Class that creates and manages virtual keyboard and other buttons
 */
class Keyboard {
  Button[] buttons;
  int hover_button;

  Keyboard() {
    createButtons();
    hover_button = BUTTON_COUNT;
  }

  public void createButtons() {
    buttons = new Button [BUTTON_COUNT];
    int button_num = 0;

    // Basic input buttons
    char caption = PApplet.parseChar(64);
    for (int y_counter = 0; y_counter < BUTTON_ROWS; y_counter++) {
      for (int x_counter = 0; x_counter < BUTTON_COLUMNS; x_counter++, button_num++) {
        if (button_num != 26)
          caption += 1;
        else // Last button - space
        caption = PApplet.parseChar(95);
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
    buttons[button_num++] = new Button("\u25b2", 11*dims.basic_key_size + dims.border_x, dims.input_y + PApplet.parseInt(dims.basic_key_size*0.75f), dims.basic_key_size, dims.basic_key_size);
    buttons[button_num++] = new Button("\u2191", 11*dims.basic_key_size + dims.border_x, dims.input_y + PApplet.parseInt(dims.basic_key_size*0.75f) + dims.basic_key_size, dims.basic_key_size, dims.basic_key_size);
    buttons[button_num++] = new Button("\u2193", 11*dims.basic_key_size + dims.border_x, dims.input_y + PApplet.parseInt(dims.basic_key_size*0.75f) + dims.basic_key_size*2, dims.basic_key_size, dims.basic_key_size);
    buttons[button_num++] = new Button("\u25bc",  11*dims.basic_key_size + dims.border_x, dims.input_y + PApplet.parseInt(dims.basic_key_size*0.75f) + dims.basic_key_size*3, dims.basic_key_size, dims.basic_key_size);
  }  

  public void displayButtons() {
    textFont(environment.getCurrentFont(), dims.caps_size);
    for (int i = 0; i < environment.getButtonsCount(); i++) // Display only this environments buttons
      buttons[i].display();
  }

  public void mouseMove() {
    int i;
    for (i = 0; i < environment.getButtonsCount(); i++)
      if (buttons[i].testMousePosition())
        break;
    if (i != hover_button) {
      if (hover_button != BUTTON_COUNT) // Mouse was off buttons
        buttons[hover_button].highlight(false);
      if (i != BUTTON_COUNT) // Mouse is now off buttons
        buttons[i].highlight(true);
      hover_button = i;
    }
  }
  
  public void mousePress() {
    if (hover_button == BUTTON_COUNT)
      return;
    
    String button = buttons[hover_button].getCaption();
    if (hover_button >= 0 && hover_button < BUTTON_COLUMNS*BUTTON_ROWS) {
      if (hover_button == (BUTTON_COLUMNS*BUTTON_ROWS-1))
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
          error = "";
          environment.setScreen(1);  
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
      environment.setScreen(1);
      environment.changeFont(button);
      data.clear();
      data.output(settings.getText("alphareset"));
      keyboard.displayButtons();
      data.display();    
    }
    else if (button.equals("\u25b2")) {
      data.scrollFirst();
    }
    else if (button.equals("\u2191")) {
      data.scrollBackwards();
    }
    else if (button.equals("\u2193")) {
      data.scrollForward();
    }
    else if (button.equals("\u25bc")) {
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

  public void display() {
    // fill(BG_COLOR);
    // noStroke();
    // stroke(BUTTON_ACS);
    // rect(x_pos, y_pos, x_size, y_size); 
    
    textAlign(CENTER);
    if (is_mouse_over) {
      fill(settings.getColor("highlight"));
    }
    else {
      fill(settings.getColor("caption"));
    }   
    text(caption, x_pos + (x_size/2), y_pos + (dims.basic_key_size + dims.caps_size*3/5)/2);
  }

  public boolean testMousePosition() {
    if (mouseX >= x_pos && mouseX <= x_pos + x_size &&  mouseY >= y_pos && mouseY <= y_pos+y_size)
      return true;
    else 
      return false;
  }

  public void highlight(boolean on) {
    is_mouse_over = on;
  }
  
  public String getCaption() {
    return caption;
  }
}
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
  
  public String getText(String name) {
    if (strings.get(name) == null) {
      error = name.concat(" string was not found.");
      return "";
    }
    else 
      return (String)(strings.get(name));
  }
  
  public String getFont(int val) {
    String font_name = "";
    
    try {
      font_name = (String) fonts.elementAt(val);
    } catch (Exception e) {
      e.printStackTrace();
      error = e.getMessage();
    }
    
    return font_name;
  }
  
  public int getColor(String name) {
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
// Keyboard values
final int BUTTON_COLUMNS = 9;
final int BUTTON_ROWS    = 3;
final int BUTTON_COUNT   = BUTTON_COLUMNS*BUTTON_ROWS+11;

/**
 * Class holds layout placement values.
 */
public class Dimensions {
  // Screen sizes
  int width_;
  int height;
  
  // Layout variables
  int border_x; // Space between layout and window horizontally
  int border_y; // Space between layout and window vertically
  int basic_key_size; // Key size
  int caps_size; // GUI text
  int text_size; // I/O text
  int text_indent;  // Space between window and text
  
  // Object placement variables - just for simplicity in reccurent uses
  int keyboard_x;
  int keyboard_y;
  int keyboard_width;
  int wide_key_size;
  int input_x;
  int input_y;
  int output_width;
  int output_height;
  int lines_count;
  
  Dimensions() {
    width_ = settings.screen_width;
    height = settings.screen_height;
    
    border_y = PApplet.parseInt(height * 0.05f);
    border_x = PApplet.parseInt(height * 0.05f) + PApplet.parseInt((width_ - height*1.3f)/2.0f);
    basic_key_size = PApplet.parseInt(height *0.1f);
    caps_size = settings.caps_size;
    text_size = settings.text_size;
    text_indent = 3;
    
    keyboard_x     = border_x;
    keyboard_y     = height - basic_key_size*3 - border_y;
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
 * Class parses data from the settings.xml file and stores them in settings object.
 */
public class XMLParse extends DefaultHandler
{ 
  public XMLParse ()
  {
    super();
  }

  public String getAttribute(String name, Attributes atts) {
    if (atts.getValue(name) == null) {
      error = (name.concat(" attribute was not found where expected."));
      return "";  
    }
    return atts.getValue(name);
  }

  public void startElement (String uri, String name, String qName, Attributes atts)
  {
    if (qName.equals("DATABASE")) {
      System.out.println("Parsing started."); 
    } else if (qName.equals("ID")) {
      settings.ID = Integer.valueOf(getAttribute("value", atts));
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
    } else if (qName.equals("USER")) {
      settings.users.put(getAttribute("name", atts), getAttribute("pass", atts));     
    } else if (qName.equals("FONT")) {
      settings.fonts.add(getAttribute("name", atts));     
    } else if (qName.equals("STRING")) {
      settings.strings.put(getAttribute("name", atts), getAttribute("text", atts));     
    } else if (qName.equals("COLOR")) {
      Vector parts = new Vector();
      parts.add(getAttribute("r", atts));
      parts.add(getAttribute("g", atts));     
      parts.add(getAttribute("b", atts));  
      parts.add(getAttribute("a", atts));       
      settings.colors.put(getAttribute("name", atts), parts);           
    } else {
      error = (qName.concat(" is not a known tag."));      
    }
  }
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--full-screen", "--bgcolor=#666666", "--hide-stop", "Database" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
