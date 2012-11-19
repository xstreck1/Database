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
  String buildQuery(String key_word) {
    return buildQuery(key_word, environment.user_name, environment.password);
  }

  /**
   * Builds a query string that is used as GET.
   *
   * @param key_word  a word that is searched for
   * @param name  a name to use instead of current user name
   * @param name  a password to use instead of current user password
   */  
  String buildQuery(String key_word, String name, String password) {
    return settings.target_url + "?term=" + settings.ID + "&klic=" + key_word + "&login=" + environment.user_name + "&password=" + environment.password;
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
  void check() {    
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
    println("Status: " + status); 
  }
}
