# bash 4+ functions to help configure <TAB> completions using JSON

### requirements -

    jq - https://stedolan.github.io/jq/

https://stedolan.github.io/jq/download/

### time to add a JSON config and a 'complete' init script for your fn/app

1. clone this repo
2. checkout and tab-completion-sample-functions.sh for an example on how to add tab completion to kt and a function called tabTester (use emacs or not)
3. the important bit is at the top of the file. It defines the tab completion json config, key is the function/app name. Case sensitive, must match exactly.
4. add a config for each command you want tab completion for.  They can be in the same file, you don't need sep. configs for each fun. It's just JSON, comman sep.
5. with the json writting, Time to write the bash functions that provide either static (aka cached forever) and the dynamic data for functions arguments. The output of the data functions is very simple. Each line in the output (carriage return delimited ( '\n' )) is made available as a tab completion value. Checkout the tab-completion-sample-functions.sh has a complete example with docs.
6. source your functions file and tab-completion-lib.sh in your .bashrc etc.
7. for an example of dynamic data check out the tabTester function config. The option --random is bound to _sillyRandomFn. so if you were to type tabTester --random<tab><tab> it would print two random strings to match.
8. if you don't want to use a function to provide the static, checkout kt's -offsets config.  The values are placed directly in data sep. by \n

### REMEMBER - you don't run the script, you source it.

the functions need to be available in your existing shell, so you _source_ the file

source tab-completion-sample-functions.sh

yay(?)

### feel free to combine together as many functions in a single JSON file as makes sense

grouping your completion configs by task and not individual function makes a lot of sense. Do that.

### I currently store the staticDataFn results forever.

yes I know this stinks. Without a better in memory caching solution this is how it is. use an fn function instead (see --random in tabTester) and do your own cachine.


ENJOY! or don't I don't care...
