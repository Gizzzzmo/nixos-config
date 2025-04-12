{ ... }:
{
  enable = true;
  theme = ''
    (
      selected_tab: Some("White"),
      command_fg: Some("White"),
      selection_bg: Some("DarkGray"),
      selection_fg: Some("White"),
      cmdbar_bg: Some("DarkGray"),
      cmdbar_extra_lines_bg: Some("DarkGray"),
      disabled_fg: Some("#666666"),
      diff_line_add: Some("Green"),
      diff_line_delete: Some("Red"),
      diff_file_added: Some("LightGreen"),
      diff_file_removed: Some("LightRed"),
      diff_file_moved: Some("LightMagenta"),
      diff_file_modified: Some("Yellow"),
      commit_hash: Some("Magenta"),
      commit_time: Some("LightCyan"),
      commit_author: Some("Green"),
      danger_fg: Some("Red"),
      push_gauge_bg: Some("Blue"),
      push_gauge_fg: Some("Reset"),
      tag_fg: Some("LightMagenta"),
      branch_fg: Some("LightYellow"),
    )
  '';
  keyConfig = ''
    (
      move_left: Some(( code: Char('h'), modifiers: "")),
      move_right: Some(( code: Char('l'), modifiers: "")),
      move_up: Some(( code: Char('k'), modifiers: "")),
      move_down: Some(( code: Char('j'), modifiers: "")),
      open_help: Some(( code: F(1), modifiers: "")),
      home: Some(( code: Char('g'), modifiers: "")),
      end: Some(( code: Char('G'), modifiers: "SHIFT")),
      diff_hunk_prev: Some(( code: Char('N'), modifiers: "SHIFT"))
    )
  '';
}
