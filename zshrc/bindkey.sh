# ─────────────────────────────────────────────────────────────────────────────
# 1) Define two associative arrays of (key → shell‐command) pairs
#    • alt_actions: Alt+<key> → command
#    • ctrl_actions: Ctrl+<key> → command
#
# To add/remove/change a binding, just edit these arrays.
# ─────────────────────────────────────────────────────────────────────────────
typeset -A alt_actions
typeset -A ctrl_actions

alt_actions=(
  h 'zellij action new-pane --direction right && zellij action move-pane left'
  l 'zellij action new-pane --direction right'
  j 'zellij action new-pane --direction down'
  k 'zellij action new-pane --direction down && zellij action move-pane up'
  # t 'print -rn -- "Hello\n\n\n" > ~/test.txt'
)

ctrl_actions=(
  # h 'echo "You pressed Ctrl+H"  # replace with your command'
  # l 'echo "You pressed Ctrl+L"  # replace with your command'
  # j 'echo "You pressed Ctrl+J"  # replace with your command'
  # k 'echo "You pressed Ctrl+K"  # replace with your command'
  # t 'echo "You pressed Ctrl+T"  # replace with your command'
)

# ─────────────────────────────────────────────────────────────────────────────
# 2) Loop over alt_actions and generate:
#      • widget function alt_widget_<key>
#      • zle -N alt_widget_<key>
#      • bindkey '^[<key>' alt_widget_<key>
#    (In Zsh, '^[<key>' = Alt+<key>)
# ─────────────────────────────────────────────────────────────────────────────
for key cmd in ${(kv)alt_actions}; do
  eval "
    function alt_widget_${key}() {
      ${cmd}
      zle reset-prompt
    }
  "
  eval "zle -N alt_widget_${key}"
  bindkey "^[${key}" alt_widget_${key}
done

# ─────────────────────────────────────────────────────────────────────────────
# 3) Loop over ctrl_actions and generate:
#      • widget function ctrl_widget_<key>
#      • zle -N ctrl_widget_<key>
#      • bindkey '^<key>' ctrl_widget_<key>
#    (In Zsh, '^<key>'  = Ctrl+<key>  — e.g. '^h' is Ctrl+H)
# ─────────────────────────────────────────────────────────────────────────────
for key cmd in ${(kv)ctrl_actions}; do
  eval "
    function ctrl_widget_${key}() {
      ${cmd}
      zle reset-prompt
    }
  "
  eval "zle -N ctrl_widget_${key}"
  bindkey "^${key}" ctrl_widget_${key}
done

