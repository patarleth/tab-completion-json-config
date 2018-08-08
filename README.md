# bash 4+ functions to help configure <TAB> completions using JSON

### requirements -

    bash 4.4 with 'complete' 
    jq - for json parsing

https://stedolan.github.io/jq/download/
bash 4.4 means a __brew upgrade bash && brew install bash-completion__ is in your future macos users. Ubuntu Et Al - you're set to go.

### time to add a JSON config and a 'complete' init script for your fn/app

1. clone this repo
2. tab-completion-sample-functions.sh contains examples for adding tab completion to an existing program - kt (https://github.com/fgeller/kt) __AND__ a bash function tabTester
3. the json config for both apps is at the top of the file. I inlined the config in the shell script for completeness. It config consists of a "key" (aka the function/program name for completion) and the program arguments and the function or static data the completion is mapped to. The key is case sensitive. It must match exactly.
4. After getting your head around how to configure completion, it's time to create your own script and add a config for each program/fn you want tab completion for.  The configuration can be in the same json config. It is not necessary to sep. configs the configurations. It's just JSON, comman sep. the commands and it'll work.
5. with the json written, it's time to code the bash functions that provide the completion data.  There are two ways to provide completion results. You can define a static function (aka the data will cached for the duration fo the shell session) and(!) as dynamic data where the function is called very time you press__<TAB><TAB>__. The output of the functions that provide tab completion is very simple - each option returned is separated on it's own line in the output (carriage return delimited ( '\n' ). Checkout __tab-completion-sample-functions.sh_ for a complete example with additional documentation.
6. With the json config and functions providing tab completion written, source them (and tab-completion-lib.sh) in your .bashrc etc.


For an example of dynamic generated data, check out the tabTester function json config in __tab-completion-sample-functions.sh_. The option --random is bound to the shell function _sillyRandomFn. You can test this by sourcing the file and typing 

  tabTester --random<tab><tab> 
  
This will print two random strings to match upon.

__tab-completion-sample-functions.sh__ also contains many examples of both functions that provide static data and inlined completion results. I recommend checking out __kt__'s -offsets config for an example of inlined tab completion data.  The values are placed directly in the data property, sep. by \n

### REMEMBER - you don't run the script, you source it.

source tab-completion-sample-functions.sh

To make functions available to your existing shell, you _source_ a file _NOT_ execute it

yay(?)

### feel free to combine together as many functions in a single JSON file as makes sense

grouping your completion configs by task and not individual function makes a lot of sense. Do that.

### I currently store the staticDataFn results forever.

yes I know this stinks. Without a better in memory caching solution this is how it is. use an fn function instead (see --random in tabTester) and do your own cachine.


ENJOY! or don't I don't care...
