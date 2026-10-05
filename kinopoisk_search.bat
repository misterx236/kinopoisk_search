@echo off
chcp 65001 >nul

rem 
if not "%~1"=="font" (
    powershell -NoProfile -Command "$k='HKCU:\Console\Поиск фильма на Кинопоиске'; New-Item $k -Force | Out-Null; Set-ItemProperty $k FaceName 'Consolas'; Set-ItemProperty $k FontFamily 54 -Type DWord; Set-ItemProperty $k FontWeight 400 -Type DWord; Set-ItemProperty $k FontSize 0x120000 -Type DWord; Set-ItemProperty $k WindowSize 0x0010003C -Type DWord; Set-ItemProperty $k ScreenBufferSize 0x0010003C -Type DWord"
    start "Поиск фильма на Кинопоиске" "%~f0" font
    exit /b
)

title Поиск фильма на Кинопоиске
mode con cols=60 lines=16

:menu
cls
echo ========================================
echo        ПОИСК ФИЛЬМА НА КИНОПОИСКЕ
echo ========================================
echo.
echo 1 - Инструкция
echo 2 - Точное название фильма
echo 3 - Поиск по слову
echo 4 - Вставить ссылку с Кинопоиска
echo 0 - Выход
echo.

set "choice="
set /p "choice=Выберите вариант: "

if "%choice%"=="1" goto help
if "%choice%"=="2" goto exact
if "%choice%"=="3" goto word
if "%choice%"=="4" goto link
if "%choice%"=="0" exit

goto menu


:exact
cls
echo ========================================
echo        ТОЧНОЕ НАЗВАНИЕ ФИЛЬМА
echo ========================================
echo.

set "film="
set /p "film=Введите название фильма: "
if not defined film goto menu
set "film=%film:"=%"

echo.
echo Ищу фильм...

rem PowerShell запускается в отдельном скрытом окне, чтобы не менять это окно
set "flag=%temp%\kp_found.flag"
del "%flag%" >nul 2>&1

start "" /wait /min powershell -NoProfile -WindowStyle Hidden -Command "$ProgressPreference='SilentlyContinue'; try { $q=[uri]::EscapeDataString('site:kinopoisk.ru/film/ '+$env:film); $r=Invoke-WebRequest -UseBasicParsing -TimeoutSec 15 -UserAgent 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/120.0 Safari/537.36' -Uri ('https://html.duckduckgo.com/html/?q='+$q); $m=[regex]::Match($r.Content,'kinopoisk\.ru(?:%%2F|/)film(?:%%2F|/)(\d+)'); if($m.Success){ Start-Process ('https://www.kinokino.win/film/'+$m.Groups[1].Value+'/'); New-Item $env:flag -Force | Out-Null } } catch { }"

if not exist "%flag%" goto exact_fallback
del "%flag%" >nul 2>&1
echo.
echo Фильм открыт.
goto exact_end

:exact_fallback
echo.
echo Не удалось найти ссылку на фильм. Открываю обычный поиск...
set "g=%film:&= %"
set "g=%g:#= %"
set "g=%g: =+%"
start "" "https://www.google.com/search?q=site:kinopoisk.ru/film/+%g%"

:exact_end
echo.
set /p "dummy=Нажмите Enter для возврата в главное меню..."
goto menu


:word
cls
echo ========================================
echo          ПОИСК ПО СЛОВУ
echo ========================================
echo.

set "word="
set /p "word=Введите слово: "
if not defined word goto menu
set "word=%word:"=%"
set "word=%word:&= %"
set "word=%word:#= %"
set "word=%word: =+%"

start "" "https://www.kinopoisk.ru/index.php?kp_query=%word%"

echo.
set /p "dummy=Нажмите Enter для возврата в главное меню..."
goto menu


:link
cls
echo ========================================
echo        ВСТАВКА ССЫЛКИ С КИНОПОИСКА
echo ========================================
echo.
echo Вставьте ссылку с Кинопоиска
echo и нажмите Enter.
echo.

set "url="
set /p "url=Ссылка: "
if not defined url goto menu
set "url=%url:"=%"

set "kind="
set "id="
set "t=%url:*kinopoisk.ru/=%"
for /f "tokens=1,2 delims=/?#& " %%a in ("%t%") do (
    set "kind=%%a"
    set "id=%%b"
)

if not defined kind goto link_bad
if not defined id goto link_bad
if /i not "%kind%"=="film" if /i not "%kind%"=="series" goto link_bad
echo %id%| findstr /r "^[0-9][0-9]*$" >nul || goto link_bad

start "" "https://www.kinokino.win/film/%id%/"
echo.
echo Фильм открыт.
goto link_end

:link_bad
echo.
echo Это не похоже на ссылку фильма Кинопоиска.
echo Пример: https://www.kinopoisk.ru/film/5494049/

:link_end
echo.
set /p "dummy=Нажмите Enter для возврата в главное меню..."
goto menu


:help
mode con cols=60 lines=24
cls
echo ========================================
echo         КАК ПОЛЬЗОВАТЬСЯ ПРОГРАММОЙ
echo ========================================
echo.
echo 2 - Точное название фильма
echo     Введите название, и скрипт сам найдёт фильм
echo     и сразу откроет его страницу.
echo.
echo 3 - Поиск по слову
echo     Введите слово или часть названия, и откроется
echo     список результатов на Кинопоиске.
echo.
echo 4 - Вставить ссылку с Кинопоиска
echo     Вставьте ссылку на фильм (правая кнопка мыши
echo     или Ctrl+V), и скрипт откроет этот фильм.
echo.
echo 0 - Выход
echo     Закрывает программу.
echo.
set /p "dummy=Нажмите Enter для возврата в главное меню..."
mode con cols=60 lines=16
goto menu