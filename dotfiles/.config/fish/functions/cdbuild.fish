function cdbuild
    set git_root (git rev-parse --show-toplevel)
    if not test -d $git_root/build
        cd $git_root
        return
    end
    if not test -e $git_root/build/.cdbuild
        cd $git_root/build
        return
    end
    bass source $git_root/build/.cdbuild
    cd $git_root
    if test -d $cdbuild_dir
        cd $cdbuild_dir
    else
        cd build
    end
end
