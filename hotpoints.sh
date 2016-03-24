#!/bin/sh

alias _grep=`which grep`
alias grep="_grep --color -n"

give_misleading_indentation() {
    echo "$@"                                                \
        | xargs grep -n -A2 "\(if\|while\|for\).*[^(;]$"     \
        | tr '\n:' '#\n'                                     \
        | sed -n '/^.*#[0-9]\+-\(\s\+\)\S.*;#[0-9]\+-\1\S/p' \
        | sed 's/#\([0-9]\+\|$\)/\x0a\1/g'                   \
        | sed -n '2p'
}

give_unsafe_execution() {
    grep "\W\(system\|popen\|Popen\)(" "$@"
}

give_unsafe_serialization() {
    grep "\W\(Pickle.load\|yaml.load\)" "$@"
}

give_unsafe_string_use() {
    echo "$@" \
        | xargs grep "\(strcat\|strcpy\)"
}

# We'll just use find, it should be okay
functions="$(_grep "^give_\w\+(" "$0" | cut -d '(' -f 1)"
files="$(find "$@" -type f | xargs echo) /dev/null"

for func in $functions ; do
    echo "-- $func --"
    $func $(echo "$files")
done
true
