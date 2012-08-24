import java.io.IOException;
import java.io.InputStreamReader;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;

class HTTPHelper {
  URL url;
  URLConnection conn;
  final static int max_lenght = 10000;
  
  HTTPHelper() {  }
  
  String connect (String URL) throws MalformedURLException, IOException {
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
  String findEntry(String key_word) {
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
  void check() {
    String result;
      
    try {
      result = http.connect(settings.target_url);
    }
    catch (Exception e) {
      e.printStackTrace();
      error = e.getMessage();
      result = "Error.";
    }  
  }
}
