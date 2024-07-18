set -x TZ "EUROPE/Bucharest"
set -x EDITOR "nvim"
set -x VISUAL "nvim"
set -x PATH ~/Projects $PATH 
set -x NVIM_APPNAME "nvim-web"

function tt
  taskwarrior-tui
end

bass source /usr/share/nvm/init-nvm.sh
bass source ~/Projects/functions.sh
bass source ~/Projects/management.sh

source ~/.config/fish/functions/tmux_project_manager.fish
