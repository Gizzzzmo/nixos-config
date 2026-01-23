# Navigate to the root of the git repository furthers up the directory tree.
function ...g
    set path "/"
    for component in (string split '/' (pwd))
        set path "$path$component/"
        if test -d "$path/.git"
            cd $path
            return
        end
    end
end
