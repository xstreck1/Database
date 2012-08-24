import org.xml.sax.XMLReader;
import org.xml.sax.Attributes;
import org.xml.sax.InputSource;

public class XMLParse extends DefaultHandler
{
  Settings settings;
  
  public XMLParse (Settings _settings)
  {
    super();
    settings = _settings;
  }

  String getAttribute(String name, Attributes atts) {
    if (atts.getValue(name) == null) {
      System.out.println(name.concat(" attribute was not found where expected."));
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
    } else if (qName.equals("FULLSCREEN")) {
      settings.fullscreen = Boolean.valueOf(getAttribute("value", atts));
    } else if (qName.equals("WIDTH")) {
      settings.screen_width = Integer.valueOf(getAttribute("value", atts));
    } else if (qName.equals("HEIGHT")) {
      settings.screen_height = Integer.valueOf(getAttribute("value", atts));
    } else if (qName.equals("USER")) {
      settings.users.put(getAttribute("name", atts), getAttribute("pass", atts));     
    } else {
      System.out.println(qName.concat(" is not a known tag."));      
    }
  }
}
