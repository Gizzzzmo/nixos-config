{ pkgs, ... }:
{
  enable = true;
  themes = {
    tokyo-night = {
      src = pkgs.fetchFromGitHub {
        owner = "folke";
        repo = "tokyonight.nvim"; # Bat uses sublime syntax for its themes
        rev = "b262293ef481b0d1f7a14c708ea7ca649672e200";
        sha256 = "sha256-pMzk1gRQFA76BCnIEGBRjJ0bQ4YOf3qecaU6Fl/nqLE";
      };
      file = "extras/sublime/tokyonight_night.tmTheme";
    };
  };

  config = {
    theme = "tokyo-night";
  };
}
