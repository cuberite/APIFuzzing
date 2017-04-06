# APIFuzzing

This is a plugin writen in lua for cuberite. As the plugin name already indicates it's used for fuzzing and checking the cuberite lua api.

There are two commands
* fuzzing
* checkapi

# Fuzzing
### Windows
Run the file runme.bat and it will startup Cuberite.

### Linux
Run the file runme.sh and it will startup Cuberite.

### Running
If the server is started up run the console command `fuzzing`. After every restart you need to run the command again.
If an crash occurs:
* Under linux the script will automatically restart cuberite
* Under windows, you need to close the debugger message box that will appear and then cuberite will start again

The message `Fuzzing completed!` will be printed in the console, if the plugin is finished.
If an crash has occured, in the home directory of the plugin will be a file named `crashed_table.txt`.
It contains the `class name`, `function name` and the `function call` of all crashes.

# CheckAPI
Start the server and run the console command `checkapi`. The plugin will be finished if the message `CheckAPI completed!` appears. The results, if any, are in the console output and in cuberite log files.

### Features
* It can catch:
* - Syntax errors, indicates a problem in code generation of plugin
* - Runtime errors, function doesn't exists, is not exported or flag IsStatic is missing in APIDoc
* It checks the return types of the function call with the APIDoc
