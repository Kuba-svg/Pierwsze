#!/bin/bash

# Funkcja do sortowania według drugiego znaku
sortuj_wg_drugiego_znaku() {
  echo "$1" | awk -F"-" '{print substr($2,1,1) " " $0}' | \
  sort -k1,1 | \
  awk '{print substr($0, index($0,$2))}'
}

# Przykładowe dane wejściowe
dane="-a, --handle
-c, --check
-d, --debug
-e, --echo
-f, --file
-g, --gen-include-path
-h, --help
-I, --includepath
-i, --interactive
-j, --json
-n, --numeric
-N, --numeric-all
-s, --stateless
-S, --stateful
-y, --terse
-v, --version
-D, --define
-4, --ipv4
-6, --ipv6
-o, --output
-p, --pseudo
-r, --reversedns
-t, --tablename
-u, --uid
-x, --handleoutput
-T, --numeric-time
-l, --location
-m, --dump-mark
-M, --dynamic
-q, --quiet
-V, --verbose
-Z, --reset-counters
-A, --concatenations
-C, --no-comments
-E, --echo-echelon
-F, --fileter-flags
-G, --guid
-H, --highlight
-J, --json-nodes
-K, --key
-L, --list-counters
-O, --objagg
-P, --pretty
-Q, --quote
-R, --raw
-U, --undefined
-W, --echo-stmts
-X, --xml
-Y, --yaml
-Z, --null
"

# Sortowanie danych
posortowane_dane=$(sortuj_wg_drugiego_znaku "$dane")

# Wyświetlenie posortowanych danych
echo "Posortowane dane:"
echo "$posortowane_dane"

