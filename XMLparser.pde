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
    if (node.getString(name) == null) {
      error = name + " attribute was not found in a node " + node + ".";
      return "";  
    }
    return node.getString(name);
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
      } else if (node.equals("ILLEGAL")) {
        settings.illegal = Boolean.valueOf(getAttribute("value", entries[i]));
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
        settings.fonts.add(getAttribute("name", entries[i]));     
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
