#!/usr/bin/env fish

# Functions from functions.sh
function project_root
    set -g ROOT $argv[1]
end

function session_name
    set -g SESSION_NAME $argv[1]
end

function session_exists
    tmux has-session -t "$argv[1]" 2>/dev/null
end

function set_current_window
  set -g CURRENT_WINDOW $argv[1]
end

function set_current_pane
  set -g CURRENT_PANE $argv[1]
end

function select_window
  tmux select-window -t "$SESSION_NAME:$argv[1]"
end

function new_window
  tmux new-window -t "$SESSION_NAME" -c "$ROOT" -n $argv[1]
  set_current_window $argv[1]
end

function split_vertical
  tmux split-window -t "$SESSION_NAME:$CURRENT_WINDOW.$CURRENT_PANE" -c "$ROOT" -v -l $argv[1]
  set_current_pane (math $CURRENT_PANE + 1)
end

function split_horizontal
  tmux split-window -t "$SESSION_NAME:$CURRENT_WINDOW.$CURRENT_PANE" -c "$ROOT" -h -l $argv[1]
  set_current_pane (math $CURRENT_PANE + 1)
end

function rename_window
  tmux rename-window -t "$SESSION_NAME:$CURRENT_WINDOW" $argv[1]
  set_current_window $argv[1]
end

function run_command
    echo "$SESSION_NAME:$CURRENT_WINDOW.$CURRENT_PANE" 
  tmux send-keys -t "$SESSION_NAME:$CURRENT_WINDOW.$CURRENT_PANE" "$argv[1]" C-m
end

function new_session
    if not session_exists $SESSION_NAME
        set dir (realpath $ROOT)
        tmux new-session -d -s $SESSION_NAME -c $ROOT
    end
end

function attach_to_session
    tmux attach-session -t $SESSION_NAME
end

# Functions from management.sh
function check_for_project
    set project_file ~/Projects/$argv[1].sh
    if not test -f $project_file
        echo "Project not found: $project_file"
        echo "Did you spell it right or did you mess this up, like you always do?"
        return 1
    end
end

function load_project
    if check_for_project $argv[1]
        if session_exists $argv[1]
            tmux attach-session -t $argv[1]
        else
            source ~/Projects/$argv[1].sh
        end
    else
        return 1
    end
end

# Make load_project available to the shell
funcsave load_project
