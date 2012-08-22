class Information {
  HashMap[] entries_sets;
  
  Information () {
    entries_sets = new HashMap [SEC_LEVELS];
    for (int i = 0; i < SEC_LEVELS; i++)
      entries_sets[i] = new HashMap();
    fillEntries();
  }

  void fillEntries() {
    // Filling level 0
    entries_sets[0].put("DEFAULT", "Nenalezeny ĹľĂˇdnĂ© informace o danĂ©m tĂ©matu.");
    entries_sets[0].put("T", "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum quis lectus vel nisi sodales tempus eget aliquam metus. Aenean porta metus venenatis orci eleifend tristique. Suspendisse tristique semper nulla, quis vestibulum felis sodales et. Sed dapibus urna non massa ullamcorper quis rhoncus nulla ultricies. Nunc scelerisque elementum scelerisque. Nunc tincidunt rutrum lectus sed gravida. Etiam sed massa vitae orci placerat suscipit. Phasellus nec tincidunt felis. Etiam facilisis quam quis neque fringilla sed venenatis enim bibendum. Proin consequat nisl sit amet augue pulvinar porta.");
    // Filling level 0
    entries_sets[1].put("DEFAULT", "Nenalezeny ĹľĂˇdnĂ© informace o danĂ©m tĂ©matu.");
    entries_sets[1].put("MOLOCH", "TovĂˇrna na orbitÄ›.");
    entries_sets[1].put("T", "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum quis lectus vel nisi sodales tempus eget aliquam metus. Aenean porta metus venenatis orci eleifend tristique. Suspendisse tristique semper nulla, quis vestibulum felis sodales et. Sed dapibus urna non massa ullamcorper quis rhoncus nulla ultricies. Nunc scelerisque elementum scelerisque. Nunc tincidunt rutrum lectus sed gravida. Etiam sed massa vitae orci placerat suscipit. Phasellus nec tincidunt felis. Etiam facilisis quam quis neque fringilla sed venenatis enim bibendum. Proin consequat nisl sit amet augue pulvinar porta.");
  }
  
  String findEntry(String key_word, int clereance) {
    if (!entries_sets[clereance].containsKey(key_word))
      key_word = "DEFAULT";
    return (String) entries_sets[clereance].get(key_word);
  }
}


