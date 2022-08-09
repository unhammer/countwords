#!/bin/bash

stack build || exit 1

stack --bash-completion-index 2 --bash-completion-word stack --bash-completion-word build --bash-completion-word countwordsHS:exe: \
    | while read -r cexe; do
    exe=${cexe##countwordsHS:exe:}
    if command -V nix &>/dev/null; then
      # echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
      stack exec nix -- run 'nixpkgs#hyperfine' -- --warmup 1 "\"$exe\" <../kjvbible_x10.txt"
    elif command -V hyperfine &>/dev/null; then
      stack exec hyperfine -- --warmup 1 "\"$exe\" <../kjvbible_x10.txt"
    else
      echo "$exe:"
      stack exec /usr/bin/env -- time "$exe" <../kjvbible_x10.txt >/dev/null
    fi
done
