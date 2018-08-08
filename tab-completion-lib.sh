TAB_COMPLETION_SCRIPT="${BASH_SOURCE[0]}"
TAB_COMPLETION_SCRIPT_DIR="$( cd "$( dirname "$TAB_COMPLETION_SCRIPT" )" >/dev/null && pwd )"

if [ ! "$(type addTabCompletionConfig 2> /dev/null )" == "" ]; then
    # echo tab-completion-lib already sourced
    return
fi

sourceTabCompletionFunctions() {
    unset addTabCompletionConfig
    source "$TAB_COMPLETION_SCRIPT"
}
# ######################## ######################## ######################## 
# globals for matching raw and populated json objects
# ######################## ######################## ######################## 
_comp_json_for_all=""
unset _comp_json_raw_map
unset _comp_json_loaded_map

declare -A _comp_json_raw_map
declare -A _comp_json_loaded_map

tabCompletionJsonConfigDirectory() {
    echo "$TAB_COMPLETION_SCRIPT_DIR/completion-config"
}

tabCompletionInit() {
    rm -f "$(tabCompletionJsonConfigDirectory)/merged_comp.json"
}

addTabCompletionConfig() {
    local config="$1"
    local data="$2"
    
    local bn="$(basename $config)"
    mkdir -p "$(tabCompletionJsonConfigDirectory)"

    local outputFile="$(tabCompletionJsonConfigDirectory)/$bn"
    #echo "adding tab completion config $outputFile"

    if [ -e "$config" ]; then
        #echo copying config file "$config"
        cp "$config" "$outputFile"
    else
        #echo creating config file
        echo "$data" > "$outputFile"
        #cat "$outputFile"
    fi
    tabCompletionInit
}
# ######################## ######################## ######################## 
# search the param list for the option name (or argument position)
# ######################## ######################## ######################## 
_get_function_option_value() {
    local optName="$1"

    declare -A _get_function_option_value_arg_map
    local args=(${@:2})

    local nonOptIndex=1
    local lastOpt=

    for arg in ${args[@]}; do
        if [[ "$arg" =~ --(.*) ]]; then
            #next val is result
            if [ ! "$lastOpt" == "" ]; then
                _get_function_option_value_arg_map[$lastOpt]="0"
            fi
            lastOpt="$arg"
        else
            if [ "$lastOpt" == "" ]; then
                # echo putting $arg into map as index _$nonOptIndex 
                _get_function_option_value_arg_map["_$nonOptIndex"]="$arg"
                nonOptIndex=$((nonOptIndex+1))
            else
                _get_function_option_value_arg_map[$lastOpt]="$arg"
            fi
            lastOpt=
        fi 
    done

    if [[ "$optName" =~ [0-9] ]]; then
        echo "${_get_function_option_value_arg_map["_$optName"]}"
    else
        echo "${_get_function_option_value_arg_map["$optName"]}"
    fi
}

_mergeCompletionJsonForFn() {
    local configDir="$(tabCompletionJsonConfigDirectory)"
    echo '{}' > "$configDir/merged_comp.json"
    local mergedJsonFile="$configDir/merged_comp.json"
    for compJsonFile in $(ls -1 $configDir/*completion.json); do
        # echo $compJsonFile
        echo "$(jq -s '.[0] + .[1]' "$mergedJsonFile" "$compJsonFile")" > "$mergedJsonFile"
    done
}

# ######################## ######################## ######################## 
# parse tab-completion-data.json (once) and place the nodes into global map
# using the raw map return the json for functions passed
# ######################## ######################## ######################## 
_rawCompletionJsonForFn() {    
    local configDir="$(tabCompletionJsonConfigDirectory)"
    local defaultResult='{ "none": { "data": "default\nresult" } }'
    if [ ! -e "$configDir/merged_comp.json" ]; then
        _mergeCompletionJsonForFn
    fi
    
    local dataFile="$configDir/merged_comp.json"
    local jsonResult="$defaultResult"
    
    local fnName="$1"
    if [ ! "${_comp_json_raw_map["$fnName"]}" == "" ]; then
        jsonResult="${_comp_json_raw_map["$fnName"]}"
    else    
        if [ "$_comp_json_for_all" == "" ]; then
            if [ -f "$dataFile" ]; then
                _comp_json_for_all="$(cat "$dataFile")"
                #echo "$_comp_json_for_all" >> "$TAB_COMPLETION_SCRIPT_DIR/log.txt"
            else
                _comp_json_for_all="{ \"default\": $default }"
            fi
        fi
        
        local v="$(echo "$_comp_json_for_all" | jq ".\"$fnName\"" 2> /dev/null)"
        if [[ "$v" == "" || "$v" == "null" ]]; then
            #echo "unknown fnName $fnName" >> "$TAB_COMPLETION_SCRIPT_DIR/log.txt"
            v="$jsonResult"
        fi
        jsonResult="$v"
        _comp_json_raw_map["$fnName"]="$jsonResult"
    fi
    echo "$jsonResult"
}

# ######################## ######################## ######################## 
# using the raw map, populate the map with dynamic data populated
# store the loaded data into a loaded map
# ######################## ######################## ######################## 
_loadedCompletionJsonForFn() {
    local fnName="$1"
    local jsonResult="${_comp_json_loaded_map[$fnName]}"
    if [ "$jsonResult" == "" ]; then
        # (>&2 echo "$fnName not found in _comp_json_loaded_map")
        local jsonStr="$(_rawCompletionJsonForFn "$fnName")"
        jsonResult="$(_setDynamicCompData "$jsonStr")"
        _comp_json_loaded_map[$fnName]="$jsonResult"
    fi
    echo "$jsonResult"
}

# ######################## ######################## ######################## 
# first get the keys of the json doc passed in
# for each key, retrieve the dynamic function property 'fn'
# if the fn exists (not null) run the function andt save results to a local var
# using the function results and jq, set the data property of the key with the dynamic data
# finally echo new completion json document 
# ######################## ######################## ######################## 
_setDynamicCompData() {
    local jsonStr="$1"

    local keys=
    IFS=$'\n' keys=($(echo "$jsonStr" | jq -r keys[]))

    for key in ${keys[@]}; do
        local fn="$(echo "$jsonStr" | jq -r ".\"$key\".staticDataFn")"
        if [ ! "$fn" == "null" ] && [ ! "$fn" == "" ]; then
            local jqSet=". .\"$key\".data |= "
            jqSet+="$( printf "$($fn)" | jq -c -s -R  .)"

            #echo "jqSet $jqSet" >> "$TAB_COMPLETION_SCRIPT_DIR/log.txt"
            jsonStr="$(echo "$jsonStr" | jq "$jqSet")"

            # (>&2 echo "staticDataFn found $fn")
            # (>&2 echo "- $jsonStr")
        fi
    done
    echo "$jsonStr"
}

# ######################## ######################## ######################## 
# FINALLY use the COMPREPLY, compgen 
# ######################## ######################## ######################## 
_opts_compare() {
    local listWordsFunction="$1"

    COMPREPLY=()
    local word="${COMP_WORDS[COMP_CWORD]}"
    local prev="${COMP_WORDS[COMP_CWORD-1]}"

    # only one word passed - dont filter the words
    if [ "$prev" == "" ]; then
        COMPREPLY=( $(compgen -W "$($listWordsFunction "none")" -- "$word") )
    else
        COMPREPLY=( $(compgen -W "$($listWordsFunction "$prev")" -- "$word") )
    fi
}

# ######################## ######################## ######################## 
# 
# ######################## ######################## ######################## 
_fetchCompWords() {
    local result=
    local topic=

    local _test_data_str=""
    local keyName="$1"
    local completionJsonStr="$2"
    local optionName=".\"$keyName\".data"
    local found=false

    local test_d="$(echo "$completionJsonStr" | jq -r "$optionName" 2> /dev/null)"

    if [ "$test_d" == "" ] || [ "$test_d" == "null" ]; then
        # when empty data, try looking for an fn field
        optionName=".\"$keyName\".fn"
        test_d="$(echo "$completionJsonStr" | jq -r "$optionName" 2> /dev/null)"
        if [ "$test_d" == "" ] || [ "$test_d" == "null" ]; then
            found=false
        else
            # fn field found execute fn save results
            _test_data_str="$($test_d)"
            found=true
        fi
    else
        _test_data_str="$test_d"
        found=true
    fi

    if [ ! "$found" == "true" ]; then
        _test_data_str="$(echo "$completionJsonStr" | jq -r .none.data)"
    fi
    
    for topic in $_test_data_str; do
        result+="$topic"
        result+=$'\n'
    done

    echo "$result"
}

read -r -d '' DEFAULT_TAB_COMPLETION_JSON <<-"_EOF_"
{
    "default": {
        "none": { "data": "what" }
    }
}
_EOF_

# add default tab completion config to the config directory
addTabCompletionConfig 'default-completion.json' "$DEFAULT_TAB_COMPLETION_JSON"
