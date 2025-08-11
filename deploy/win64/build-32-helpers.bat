rem  We no longer support a 32-bit version of SV, but we still want
rem  32-bit helpers to allow the 64-bit version to use 32-bit
rem  plugins. So this builds only the helpers, with nothing that
rem  depends on Qt.

rem  Run this from within the top-level SV dir: deploy\win64\build-32.bat
rem  To build from clean, delete the folder build_win32 first

echo on

set STARTPWD=%CD%

rem The first path is for workstation builds, the second for CI
set vcvarsall="C:\Program Files (x86)\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat"
if not exist %vcvarsall% (
@   echo Could not find MSVC vars batch file in %vcvarsall%
@   exit /b 2
)

call %vcvarsall% x86

set ORIGINALPATH=%PATH%
set PATH=C:\Program Files (x86)\SMLNJ\bin;%QTDIR%\bin;%PATH%

cd %STARTPWD%

call .\repoint install
if %errorlevel% neq 0 exit /b %errorlevel%

set BUILDDIR=build_win32

if not exist %BUILDDIR%\build.ninja (
  meson setup %BUILDDIR% --buildtype release -Dno_qt=true -Db_vscrt=static_from_buildtype
  if %errorlevel% neq 0 exit /b %errorlevel%
)

ninja -C %BUILDDIR%
if %errorlevel% neq 0 exit /b %errorlevel%

set PATH=%ORIGINALPATH%
