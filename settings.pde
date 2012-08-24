class Settings {
  int ID;
  int screen_width;
  int screen_height;
  boolean fullscreen;
  HashMap users;
  HashMap strings;
  
  Settings () {
    ID = -1;
    screen_width = -1;
    screen_height = -1;
    fullscreen = false;
    users = new HashMap();
    strings = new HashMap();
  }
}
