@echo off
SETLOCAL

REM Define IDE names
SET IDE_NAMES="ALL" "WebStorm" "IntelliJ" "CLion" "Rider" "GoLand" "PhpStorm" "Resharper" "PyCharm"

CALL :INIT_GUI
REM Delete eval folder with license key and options.xml which contains a reference to it
FOR %%I IN (%IDE_NAMES%) DO (
    FOR /D %%a IN ("%USERPROFILE%\.%%I*") DO (
        IF EXIST "%%a\config\eval" (
            RD /S /Q "%%a\config\eval"
        )
        IF EXIST "%%a\config\options\other.xml" (
            DEL /Q "%%a\config\options\other.xml"
        )
    )
)

REM Delete registry key and JetBrains folder
IF EXIST "%APPDATA%\JetBrains" (
	RMDIR /S /Q "%APPDATA%\JetBrains"
)

REG DELETE "HKEY_CURRENT_USER\Software\JavaSoft" /f

REM End
EXIT


:INIT_GUI
	SET "INDEX_OPTION=0"
:GUI
	(
		ECHO.  ##  CHOOSE IDE TO RESET  ##
		ECHO.
		SET "NAMES_INDEX=0"
		FOR %%I IN (%IDE_NAMES%) DO CALL :PRINT_GUI_OPTIONS "%INDEX_OPTION%" "%%I"

		ECHO.
		CALL :PRINT "[S=Down, W=Up, C=Close] >"
	) >GUI.TXT
	
	CLS
	REM Print file GUI.TXT on screen
	TYPE GUI.TXT
	CALL :GET_KEY
	
	IF /I "%KEY%" == "W" CALL :UP
	IF /I "%KEY%" == "S" CALL :DOWN
	IF "%KEY%" == "" (
		CALL :ACCEPT
		EXIT/B
	)
	IF /I "%KEY%" == "C" (
		DEL GUI.TXT
		EXIT/B 1
	)
GOTO :GUI

:PRINT_GUI_OPTIONS
	SET "IDE_NAME=%~2"
	SET "INDEX_OPTION=%~1"
	IF "%NAMES_INDEX%" == "%INDEX_OPTION%" (
		ECHO.-^> %IDE_NAME%
	) ELSE (
		ECHO.   %IDE_NAME%
	)
	SET /A NAMES_INDEX+=1
EXIT/B

:UP
	IF "%INDEX_OPTION%" GTR "0" SET/A INDEX_OPTION-=1
EXIT/B

:DOWN
	REM In batch script, you cannot perform mathematical operations in an expression. It can only be resolved by SET/A
	SET/A "INDEX_OPTION_TEMP=%INDEX_OPTION% + 1"
	IF "%INDEX_OPTION_TEMP%" LSS "%NAMES_INDEX%" SET/A INDEX_OPTION+=1
EXIT/B

:ACCEPT
	REM IF "%INDEX_OPTION%" != "0"
	IF "%INDEX_OPTION%" NEQ "0" (
		CALL :FILTER_INDEX_ACCEPTED %INDEX_OPTION%
	)
	REM Remove first index = ALL
	CALL :FILTER_INDEX_ACCEPTED 0
EXIT/B

:FILTER_INDEX_ACCEPTED
	REM Remove all IDE names, except the one specified in parameter %1
	SET "FOR_I=-1"
	SET "RESULT_IDE_NAMES="
	SET "INDEX_SELECTED=%~1"
	FOR %%I IN (%IDE_NAMES%) DO CALL :LOOP_FILTER_INDEX_ACCEPTED %%I
	SET IDE_NAMES=%RESULT_IDE_NAMES%
	SET "RESULT_IDE_NAMES="
	EXIT/B
	
	
	:LOOP_FILTER_INDEX_ACCEPTED
		SET/A "FOR_I+=1"
		IF "%INDEX_SELECTED%" == "%FOR_I%" EXIT/B
		SET "RESULT_IDE_NAMES=%RESULT_IDE_NAMES% %1"
	EXIT/B
EXIT/B

REM This is just a workaround to get one character at a time, without getting stuck with "set/p".
REM The REPLACE.EXE command is used here to capture a single keystroke from the user.
REM Explanation:
REM - REPLACE.EXE is invoked with the parameters "? . /U /W".
REM - The "/U" flag ensures Unicode mode, and "/W" waits for user input.
REM - The "?" character is used as a placeholder to prompt the user for input.
REM - The FOR loop processes the output of REPLACE.EXE, skipping the first line (SKIP=1),
REM   and captures the first character entered by the user into the variable "KEY".
:GET_KEY
	FOR /F SKIP^=1^ DELIMS^=^ EOL^= %%# IN ('REPLACE.EXE ? . /U /W') DO SET "KEY=%%#"
EXIT/B

REM Print without skipping a line.
:PRINT
	SET/P "=%~1" <&2
EXIT/B
ENDLOCAL