# Fish syntax and pager colors, mapped to the roles a code editor uses in Tokyo Night
# (functions blue, keywords magenta, strings green, attributes cyan, specials yellow, comments dim).
# ANSI slot names only, so the same file works for the Ghostty dark (TokyoNight Night) and
# light (TokyoNight Day) variants without a hard-coded hex palette.
status is-interactive; or return

set -g fish_color_normal normal
set -g fish_color_command blue
set -g fish_color_keyword magenta
set -g fish_color_option cyan
set -g fish_color_param normal
set -g fish_color_quote green
set -g fish_color_redirection yellow --bold
set -g fish_color_end magenta
set -g fish_color_operator yellow
set -g fish_color_escape magenta --bold
set -g fish_color_comment brblack --italics
set -g fish_color_error red --bold
set -g fish_color_valid_path --underline
set -g fish_color_autosuggestion brblack
set -g fish_color_selection --background=brblack
set -g fish_color_search_match --background=brblack
set -g fish_color_history_current --bold
set -g fish_color_cancel --reverse
set -g fish_color_status red
set -g fish_color_cwd blue
set -g fish_color_cwd_root red
set -g fish_color_user green
set -g fish_color_host blue
set -g fish_color_host_remote yellow

set -g fish_pager_color_progress brblack
set -g fish_pager_color_prefix cyan --bold
set -g fish_pager_color_completion normal
set -g fish_pager_color_description brblack
set -g fish_pager_color_selected_background --background=brblack
set -g fish_pager_color_selected_prefix cyan --bold
