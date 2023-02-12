@echo off
echo ==================================================
echo 2023 Guilherme Vieira Dutra - PE builder with MASM
echo ==================================================
set lib_path="C:\Program Files (x86)\Windows Kits\10\Lib\10.0.22000.0\um\x86"

:start
    echo.
    if "%1"=="" goto input_basename
    set id=%1
    goto assemble

:input_basename
    set /p id=">> Enter basename: "

:assemble
    del %id%.exe
    echo.
    "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC\14.34.31933\bin\Hostx64\x86\ml.exe" /Fo %id%.obj /c /coff %id%.asm
    echo.
    if exist %id%.rc goto embed_res
    "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC\14.34.31933\bin\Hostx64\x86\link.exe" /subsystem:windows /LIBPATH:%lib_path% /OUT:%id%.exe %id%.obj
    goto res_finish

:embed_res
    "C:\Program Files (x86)\Windows Kits\10\bin\10.0.22000.0\x86\RC.exe" /r %id%.rc
    "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC\14.34.31933\bin\Hostx64\x86\link.exe" /subsystem:windows /LIBPATH:%lib_path% /OUT:%id%.exe %id%.obj %id%.res
    del %id%.res
    echo Resource embedded.

:res_finish
    del %id%.obj
    echo.
    if not exist %id%.exe.manifest goto mf_finish
    "C:\Program Files (x86)\Windows Kits\10\bin\10.0.22000.0\x86\mt.exe" -nologo -manifest %id%.exe.manifest /outputresource:%id%.exe;1
    echo Manifest embedded.

:mf_finish
    FOR /F "usebackq" %%A IN ('%id%.exe') DO set size=%%~zA
    echo File size is %size% bytes
    %id%.exe
    echo.
    echo Return code: %errorlevel%

if "%1"=="" goto start