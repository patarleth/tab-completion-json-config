TAB_COMP_LIB_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

read -r -d '' KT_TAB_COMPLETION_JSON <<-"_EOF_"
{
    "kt": { 
        "none": { "data": "consume\nproduce\ntopic\ngroup\n-brokers\n-topic\n-filter\n-leaders\n-partitions\n-pretty\n-replicas\n-verbose\n-version\n-help" },
        "-brokers": { "data": "", "staticDataFn": "listKafkaBrokers" },
        "-offsets": { "data": "0\n0:0\n:0:0-10\nall=0\nall=0-10\nnewest\noldest" },
        "-topic": { "data": "", "staticDataFn": "listSourceKafkaTopics" },
        "-timeout": { "data": "0" },
        "-pretty": { "data": "true\nfalse" },
        "-filter": { "data": ".*-sdr-.*\n.*sw.*\n.*sportware.*\nid-graph.*" },
        "topic": { "data": "-brokers\n-filter\n-leaders\n-partitions\n-pretty\n-replicas\n-verbose\n-version" },
        "consume": { "data": "-brokers\n-filter\n-leaders\n-partitions\n-pretty\n-replicas\n-verbose\n-version" },
        "group": { "data": "-brokers\n-topic\n-offsets\n-filter\n-leaders\n-partitions\n-pretty\n-replicas\n-verbose\n-version" }
    }
}
_EOF_

# add kt tab completion config to the config directory
addTabCompletionConfig 'kt-completion.json' "$KT_TAB_COMPLETION_JSON"

read -r -d '' TABTESTER_TAB_COMPLETION_JSON <<-"_EOF_"
{
    "tabTester": {
        "none": { "data": "--source\n--dest" },
        "--source": { "data": "", "staticDataFn": "listSourceKafkaTopics" },
        "--dest": { "data": "", "staticDataFn": "listDestKafkaTopics" },
        "--random": { "data": "", "fn": "_sillyRandomFn" }
    }
}
_EOF_

_sillyRandomFn() {
    echo "randomVal-$((1 + RANDOM % 10))"
    echo "randomVal-$((1 + RANDOM % 10))"
}

# add tab completion config to the config directory
addTabCompletionConfig 'tab-completion.json' "$TABTESTER_TAB_COMPLETION_JSON"

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


