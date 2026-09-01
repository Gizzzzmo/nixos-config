function __zoxide_git_root_bonus --on-variable PWD
  test -z "$fish_private_mode"; or return

  set -l path (__zoxide_pwd)
  set -l git_root (git -C "$path" rev-parse --show-toplevel 2>/dev/null)
  if test "$git_root" = "$path"
    command zoxide add --score 0.2 -- "$path"
  end
end
