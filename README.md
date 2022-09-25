# APIFuzzing

This is a plugin written in lua for cuberite. As the plugin name already indicates it's used for fuzzing and it can check the cuberite lua api.

There are two commands
* fuzzing
* checkapi

# Fuzzing
The runme file has to be copied to the root folder of Cuberite, before running it.

### Windows
Run the file runme.bat and it will startup Cuberite.

### Linux
Run the file runme.sh and it will startup Cuberite.

### Running
The server will be started and runs the console command `fuzzing`.
If an crash occurs:
* Under linux the script will automatically restart cuberite and run the command again
* Under windows, you need to close the debugger message box that will appear, then cuberite will start and run the command again

The message `Fuzzing completed!` will be printed in the console, if the plugin is finished.
If an crash has occured, in the home directory of the plugin will be a file named `crashed_table.txt`.
It contains the `class name`, `function name` and the `function call` of all crashes.

In file inputs.lua at line 103 there is a for loop that adds params from number -100 to 100.
When this part is enabled, fuzzing can take much more time.
I recommend to enable this part only under a linux based system.
Under windows it requires much more time to finish.

# CheckAPI
Start the server and run the console command `checkapi`. The plugin will be finished if the message `CheckAPI completed!` appears. The results, if any, are in the console output and in cuberite log files.

### Features
* It can catch:
* - Syntax errors, indicates a problem in code generation of this plugin
* - Incorrect parameters in APIDoc or not documented
* - Function exists in the API, but is not exported or doesn't exists
* - Function is missing flag IsStatic in APIDoc
* It can also compare the return types of the function call with the APIDoc
