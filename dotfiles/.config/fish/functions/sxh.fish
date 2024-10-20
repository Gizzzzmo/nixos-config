
# search and execute, via fzf, default search is ls, default execute is open
function sxh
    if test (count $argv) -eq 0
        set cmd "ls"
    else
        set cmd $argv
    end
    
    set selection (eval $cmd | fzf)
    
    echo "Open with"
    set user_cmd
    read user_cmd
    
    eval hyprctl dispatch exec $user_cmd $selection
end