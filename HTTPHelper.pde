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
