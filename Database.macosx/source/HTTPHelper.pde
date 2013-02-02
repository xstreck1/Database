import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;
import java.io.InputStreamReader;

/**
 * Class wrapping very simple basics of a synchronous HTTP connection.
 */
class HTTPHelper implements Runnable { 
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
    URLConnection conn = url.openConnection();
    conn.connect();

    // The content is stored into a buffer	
    InputStreamReader content = new InputStreamReader((InputStream) conn.getContent());
    BufferedReader buff = new BufferedReader(content);
    
    String full_text = "", new_line = buff.readLine();
    while (new_line != null) {
      full_text = full_text + new_line + "\n";
      new_line = buff.readLine();
    };

    return full_text.trim();    
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
      result = "CONN_ERR";
    }
    
    // Debug output
    println(". Response: " + result); 
    
    return result;
  }

  /**
   * Check status of the database on the server and set environmental variable in dependency on that.
   */  
  @Override
  void run() {    
    String status = "";
    String my_query = buildQuery("STATUS", "MAINTENANCE", "INSECURITY"); 
    try {
      status = connect(my_query);
    }
    catch (Exception e) {
      e.printStackTrace();
    }
    environment.on_line = status.replace('\n',' ').matches("ON.*");
    // Debug output
    println("Status: " + my_query + " " + status); 
  }
}
