# bash 4+ functions to help wire together <TAB> completions using JSON config

### requirements -

    jq - https://stedolan.github.io/jq/

https://stedolan.github.io/jq/download/

### with jq installed, add the JSON config and the script to init the completion

1. clone this repo
2. copy AND rename tab-completion.json to the funtion you want to add. YOU NEED TO NAME THE FILE like so <fn_name>-completion.json in the same folder as tab-completion-lib.sh
3. for each of the command line args of your function add a config
4. for completions that need to be dynamic, write functions that take no arguments to provide values, carriage return delimited ( '\n' )
4.a tab-completion-sample-functions.sh has a complete example with docs
5. source your functions file and tab-completion-lib.sh

### REMEMBER you don't run the script. You source the functions into your existing shell like so

source tab-completion-sample-functions.sh

### feel free to combine together as many functions in the JSON file as you like.

ENJOY! or don't I don't care...
