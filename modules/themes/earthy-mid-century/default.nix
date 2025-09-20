# modules/themes/earthy-mid-century/default.nix
{ pkgs, ... }:

{
  # ---------------------------------------------------------------------------
  # Theme Definition: Earthy Mid-Century
  # ---------------------------------------------------------------------------
  # This theme is inspired by a room with lots of wood, black, red, and
  # accents of welsh green. It aims for a warm, inviting, and sophisticated
  # desktop environment.
  # ---------------------------------------------------------------------------

  config = {
    # Color Palette
    colors = {
      # Base Colors
      background = "#1a1a1a"; # Near black
      foreground = "#dcdcdc"; # Light grey for text
      cursor = "#dcdcdc";

      # Black Tones
      black = {
        base = "#000000";
        lighter = "#262626";
      };

      # White/Grey Tones
      white = {
        base = "#ffffff";
        darker = "#dcdcdc";
      };

      # Wood Tones (Browns)
      wood = {
        dark = "#3a2e28";  # Dark Walnut
        medium = "#6f4e37"; # Coffee
        light = "#9a7b60"; # Light Oak
      };

      # Red Accent
      red = "#9d2f2f"; # Earthy, muted red

      # Green Accent
      green = "#3c6e47"; # Welsh Green

      # Other Accent Colors
      blue = "#5f8787";
      yellow = "#d7a75f";
      magenta = "#8f5f87";
      cyan = "#5f8787";
    };

    # Fonts
    fonts = {
      sansSerif = {
        family = "Iosevka";
        size = 12;
      };
      serif = {
        family = "Noto Serif";
        size = 12;
      };
      monospace = {
        family = "Iosevka Term";
        size = 12;
      };
    };

    # Icons and Cursors
    icons = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    cursor = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = 24;
    };
  };
}
