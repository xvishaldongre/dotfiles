// Config docs:
//
//   https://glide-browser.app/config
//
// API reference:
//
//   https://glide-browser.app/api
//
// Default config files can be found here:
//
//   https://github.com/glide-browser/glide/tree/main/src/glide/browser/base/content/plugins
//
// Most default keymappings are defined here:
//
//   https://github.com/glide-browser/glide/blob/main/src/glide/browser/base/content/plugins/keymaps.mts
//
// Try typing `glide.` and see what you can do!
glide.g.mapleader = "<Space>";
glide.keymaps.set("normal", "<leader>r", "config_reload");
glide.keymaps.set(
  "command",
  "<c-j>",
  "commandline_focus_next",
);
glide.keymaps.set(
  "command",
  "<c-k>",
  "commandline_focus_back",
);

glide.prefs.set("browser.uidensity", 1); // compact mode
glide.addons.install("https://addons.mozilla.org/firefox/downloads/file/4629131/ublock_origin-1.68.0.xpi")
glide.addons.install("https://addons.mozilla.org/firefox/downloads/file/4640726/bitwarden_password_manager-2025.12.0.xpi")

