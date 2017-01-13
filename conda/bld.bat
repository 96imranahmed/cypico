robocopy %RECIPE_DIR%\.. . /E /NFL /NDL

copy /y %LIBRARY_INC%\stdint.h cypico\pico\runtime\stdint.h

"%PYTHON%" setup.py install --single-version-externally-managed --record=%TEMP%record.txt

if errorlevel 1 exit 1
