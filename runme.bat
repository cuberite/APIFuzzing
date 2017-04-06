@echo off

if exist "stop.txt" (
	rm "stop.txt"
)

:loop
	Cuberite.exe
	
	REM If file stop.txt has been created, fuzzing is done
	if exist "stop.txt" (
		goto stop
	)
	
	REM If file current.txt exists, an crash occurred
	if exist "Plugins\APIFuzzing\current.txt" (
		move "Plugins\APIFuzzing\current.txt" "Plugins\APIFuzzing\crashed.txt"
	) else (
		REM Cuberite has been stopped and the command fuzzing was not run
		goto stop
	)
	
	goto loop

:stop
echo Fuzzing stopped.
