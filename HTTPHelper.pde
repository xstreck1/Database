import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;

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
   * @return  POST data from the URL
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
    while (content.read(buffer, 0, max_lenght) >= max_lenght && content >= 1);
    
    return new String(buffer);
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
    String my_query = new String(settings.target_url + "?klic=" + key_word + "&login=" + environment.user_name + "&password=" + environment.password);  
    
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
    
    // Remove empty spaces if there are any
    int index_of_empty = (result.indexOf(0x0) == -1) ? result.length() : result.indexOf(0x0);
    result = result.substring(0, index_of_empty);
    
    // Debug output
    System.out.println(". Response: " + result); 
    
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
