/**
 * Class parses data from the settings.xml file and stores them in settings object.
 */
public class XMLParse extends DefaultHandler
{ 
  public XMLParse ()
  {
    super();
  }

  String getAttribute(String name, Attributes atts) {
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
    } else if (qName.equals("ILLEGAL")) {
      settings.illegal = Boolean.valueOf(getAttribute("value", atts));
      System.out.print(settings.illegal);
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
