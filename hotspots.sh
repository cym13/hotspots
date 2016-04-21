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

give_execution() {
    grep "\W\(system\|popen\|Popen\|execve\|vfork\)(" "$@"
}

give_serialization() {
    grep "\W\(Pickle.load\|yaml.load\)" "$@"
}

give_tempfile() {
    grep "\Wmktemp(" "$@"
}

give_string_use() {
    grep '\(strcat\|strcpy\)([^,]\+,[^"]\+)' "$@"
}

give_unsafe_sizeof_use() {
    grep 'sizeof(\(this\|[!=<>]\))' "$@"
}

give_macro_cast() {
    grep '^#define \w\+(.*\s(\w\+)\w\+' "$@"
}

# We'll just use find, it should be okay
functions="$(_grep "^give_\w\+(" "$0" | cut -d '(' -f 1)"
files="$(find "$@" -type f | xargs echo) /dev/null"

for func in $functions ; do
    echo "-- $func --"
    $func $(echo "$files")
done
true
