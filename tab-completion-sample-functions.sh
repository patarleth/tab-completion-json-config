SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

source "$SCRIPT_DIR/tab-completion-lib.sh"

# ######################## ######################## ######################## 
# sample function demonstration how tab completion could be added to a fn
# ######################## ######################## ######################## 
tabTester() {
    #echo args passed "$@"
    local source="$(_get_function_option_value "--source" "$@")"
    local dest="$(_get_function_option_value "--dest" "$@")"

    local firstParam="$(_get_function_option_value "1" "$@")"
    local secondParam="$(_get_function_option_value "2" "$@")"
    local thirdParam="$(_get_function_option_value "3" "$@")"
    
    echo the source was "$source"
    echo the dest was "$dest"
    echo "firstParam $firstParam - secondParam $secondParam - thirdParam $thirdParam"
}

# ######################## ######################## ######################## 
# required functions for the functions specified in tab-completion-data.json
# ######################## ######################## ######################## 
listSourceKafkaTopics() {
    echo $'topic-one\ntopic-two\ntopic-three'
}
listDestKafkaTopics() {
    echo $'topic-one\ntopic-two\ntopic-three'
}
listKafkaBrokers() {
    echo "localhost:9092"
}

# ######################## ######################## ######################## 
# function is called with the partial value to complete
#
# dynamic match functions for tabTester section of tab-completion-data.json
# wrapped into a function that takes no args
#
# _loadedCompletionJsonForFn searches the data.json file, runs the functions
# sepecified in the fn node. If fn node does not exist then nothing happens
# and the data node is returned for the params.
#
# ######################## ######################## ######################## 
_auto_completions_for_tabTester() {
    _fetchCompWords "$1" "$(_loadedCompletionJsonForFn "tabTester")"
}

# ######################## ######################## ######################## 
# finally(!) connect the complete functions to the tabTestser function
#
# the opts param offers the ability to have special match values for each
# param.
#
# This example has two params: --source and --dest
#
# In tab-completion-data.json, note the source and dest nodes that provide
# the values to match upon.
# ######################## ######################## ######################## 
_complete_fn_for_tabTester() {
    local opts='--source --dest'
    _opts_compare _auto_completions_for_tabTester "$opts"
}

# bind the completion function to the actual function with 'complete'
complete -F _complete_fn_for_tabTester tabTester



# ######################## ######################## ######################## 
# now do the same for an existing binary instead of a function (kt)
# kt is a golang based kafka tool to list, describe, produce to a topics
# https://github.com/fgeller/kt
# ######################## ######################## ######################## 
_auto_completions_for_kt() {
    _fetchCompWords "$1" "$(_loadedCompletionJsonForFn "kt")"
}

_complete_fn_for_kt() {
    local opts='--source --dest'
    _opts_compare _auto_completions_for_kt "$opts"
}

kt() {
    ~/go/bin/kt "$@"
}

# bind the completion function to the actual function with 'complete'
complete -F _complete_fn_for_kt kt


