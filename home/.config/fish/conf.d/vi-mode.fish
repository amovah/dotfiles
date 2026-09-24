# Edit the command line with vi keys.
#
# Setting $fish_key_bindings, rather than calling fish_vi_key_bindings, lets
# fish apply it through its own variable handler once the prompt starts. The
# global shadows any universal set by `fish_config`, so this file stays the
# single source of truth.
#
# The cursor shape shows the mode at a glance: a block in normal mode, a bar
# while inserting, an underscore for replace. Terminals that ignore the escape
# sequence (or run inside something that eats it) just keep their default.
#
# Interactive-gated: key bindings mean nothing to a script.

status is-interactive; or return

set -g fish_key_bindings fish_vi_key_bindings

set -g fish_cursor_default block
set -g fish_cursor_insert line
set -g fish_cursor_replace_one underscore
set -g fish_cursor_replace underscore
set -g fish_cursor_visual block
