# name: clearance
# ---------------
# Based on idan. Display the following bits on the left:
# - Virtualenv name (if applicable, see https://github.com/adambrenecki/virtualfish)
# - Current directory name
# - Git branch and dirty state (if inside a git repo)
# - If inside the GOPATH, it displays a nice GO prompt

function _git_branch_name
  echo (command git symbolic-ref HEAD ^/dev/null | sed -e 's|^refs/heads/||')
end

function _git_is_dirty
  echo (command git status -s --ignore-submodules=dirty ^/dev/null)
end

function fish_prompt
  set -l last_status $status

  set -l cyan (set_color cyan)
  set -l yellow (set_color yellow)
  set -l red (set_color red)
  set -l blue (set_color blue)
  set -l green (set_color green)
  set -l normal (set_color normal)

  set -l cwd $blue(pwd | sed "s:^$HOME:~:")

  # Output the prompt, left to right

  # Add a newline before new prompts
  echo -e ''

  # Display [venvname] if in a virtualenv
  if set -q VIRTUAL_ENV
    echo -n -s (set_color cyan) '[🐍  ' (basename "$VIRTUAL_ENV") ']' $normal
  end

  # Display [go] if in a GOPATH
  if set -q GOPATH
    if test (string match -i -r "^$GOPATH" (pwd))
      echo -n -s (set_color cyan) '[  go!]' $normal
      end
  end

  if set -q OCAML_TOPLEVEL_PATH
    set -l opam_compiler (opam switch show)
    echo -n -s (set_color cyan) '[🐫  ' $opam_compiler ']' $normal
  end

  if set -q _KERL_ACTIVE_DIR
    echo -n -s (set_color cyan) '[' (set_color magenta) '  ' (set_color cyan)  (basename $_KERL_ACTIVE_DIR) ']'$normal
  end

  # Print pwd or full path
  echo -n -s ' ' $cwd $normal

  # Show git branch and status
  if [ (_git_branch_name) ]
    set -l git_branch (_git_branch_name)

    if [ (_git_is_dirty) ]
      set git_info '(' $yellow $git_branch "±" $normal ')'
    else
      set git_info '(' $green $git_branch $normal ')'
    end
    echo -n -s ' · ' $git_info $normal
  end

  set -l prompt_color $red
  if test $last_status = 0
    set prompt_color $normal
  end

  # Terminate with a nice prompt char
  echo -e ''
  echo -e -n -s $prompt_color '⟩ ' $normal
end
