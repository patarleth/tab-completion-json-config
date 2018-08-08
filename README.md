# bash 4+ functions to help configure <TAB> completions using JSON

### requirements -

    jq - https://stedolan.github.io/jq/

https://stedolan.github.io/jq/download/

### time to add a JSON config and an init script for your fn/app

1. clone this repo
2. copy AND rename completion-config/tab-completion.json to the funtion you want to add. THE name of the file _MUST_ be in this form: <fn_name>-completion.json AND placed in the same folder as completion-config/tab-completion.json. <fn_name> can be anything you like. The only thing that matters is the file ends in -completion.json
3. add a config for each of the command line args of your function
4. write bash functions that provide the dynamic data for functions arguments. Output is very simple. Each line in the output (carriage return delimited ( '\n' )) is made available as a tab completion value. Checkout the tab-completion-sample-functions.sh has a complete example with docs.
5. source your functions file and tab-completion-lib.sh in your .bashrc etc.

### REMEMBER - you don't run the script, you source it.

the functions need to be available in your existing shell, so you _source_ the file

source tab-completion-sample-functions.sh

yay(?)

### feel free to combine together as many functions in a single JSON file as makes sense

grouping your completion configs by task and not individual function makes a lot of sense. Do that.

### I currently cache the dynamic completions ONLY ONCE for the staticDataFn field

yes I know this stinks. Without the in memory caching, the original functions were too slow when they hit the source systems each time.  Feel free to change the code to run the fn everytime ;) 

for V0.2 my plan is to add a simple TTL based on the merge-completion.json file update time.


ENJOY! or don't I don't care...
