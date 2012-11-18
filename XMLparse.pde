import org.xml.sax.XMLReader;
import org.xml.sax.helpers.XMLReaderFactory;
import org.xml.sax.helpers.DefaultHandler;
import org.xml.sax.Attributes;
import org.xml.sax.InputSource;

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
  private String getAttribute(String name, Attributes atts) {
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
    } else { // If the tag is not found, result with an error.
      error = (qName.concat(" is not a known tag."));      
    }
  }
}
