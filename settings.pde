class Settings {
  int ID;
  int screen_width;
  int screen_height;
  HashMap users;
  HashMap strings;
  
  Settings () {
    ID = -1;
    screen_width = -1;
    screen_height = -1;
    users = new HashMap();
    strings = new HashMap();
  }
}
