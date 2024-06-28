typedef GameData = Map<String, dynamic>;

mixin HasGameData {
  void load_state(GameData data);

  GameData save_state(GameData data);
}

mixin GameObject implements HasGameData {
  void on_start_new_game() {}

  void on_start_playing() {}

  void on_resume_game() {}

  void on_end_of_level() {}

  void on_end_of_game() {}
}
