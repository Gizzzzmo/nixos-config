{ ... }:
{
  enable = true;
  settings = {
    general.import = [
      "/home/jonas/.config/alacritty/tokyo-night.toml"
      #"/home/jonas/.config/alacritty/catppuccin-mocha.toml"
    ];

    window = {
      padding = {
        x = 5;
        y = 5;
      };
      opacity = 0.9;
    };

    font = {
      normal = {
        family = "FiraCode Nerd Font";
        style = "Regular";
      };
      size = 11.3;
    };
  };
}
