
# search and execute, via fzf, default search is ls, default execute is open
function sx
    if test (count $argv) -eq 0
        set cmd "ls"
    else
        set cmd $argv
    end
    
    set selection (eval $cmd | fzf)
    
    echo "Open with"
    set user_cmd
    read user_cmd
    
    if test -z "$user_cmd"
        set user_cmd "open"
    end
    
    eval $user_cmd $selection
end