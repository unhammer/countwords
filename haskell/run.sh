#!/bin/bash

stack build || exit 1

stack --bash-completion-index 2 --bash-completion-word stack --bash-completion-word build --bash-completion-word countwordsHS:exe: \
    | while read -r cexe; do
    exe=${cexe##countwordsHS:exe:}
    if command -V nix &>/dev/null; then
        nix run nixpkgs.hyperfine -c hyperfine \
            "stack exec \"$exe\" -- < ../kjvbible_x10.txt"
    else
        time stack exec "$exe" -- < ../kjvbible_x10.txt >/dev/null
        echo "↑ $exe ↑"
    fi
done
