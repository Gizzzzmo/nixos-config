function cdbuild
    set git_root (git rev-parse --show-toplevel)
    if test $status -ne 0
        return 1;
    end
    if not test -f $git_root/.cdbuild
        if test -d "$git_root"/build
            cd "$git_root"/build
        else
            cd "$git_root"
        end
        return
    end
    bass . "$git_root"/.cdbuild

    set first_char (string sub --length 1 "$cdbuild_dir")
    if test "$first_char" = "/"; and test -d "$cdbuild_dir"
        cd "$cdbuild_dir"
    else if test -d "$git_root"/"$cdbuild_dir"
        cd "$git_root"/"$cdbuild_dir" 
    else
        if test -d "$git_root"/build
            cd "$git_root"/build
        else
            cd "$git_root"
        end
    end
end
