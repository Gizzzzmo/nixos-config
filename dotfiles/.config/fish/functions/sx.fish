
# search and execute, via fzf, default search is ls, default execute is open
function sx
    if test (count $argv) -eq 0
        set cmd "ls"
    else
        set cmd $argv
    end
    
    set selection ($cmd | fzf)
    if test $status -ne 0
	return
    end
    echo "Open with"
    set user_cmd (eval complete -C"" | awk "{print \$1}" | fzf) 
    
    if test $status -ne 0
	return
    end

    if test -z "$user_cmd"
        set user_cmd "echo"
    end
    
    eval $user_cmd "$selection"
end
