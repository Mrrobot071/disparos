@echo off
setlocal EnableExtensions
chcp 65001 >nul
title Disparar WhatsApp pendentes - Intec BA

set "SCRIPTS_DIR=C:\Users\LUCAS\Desktop\ct\leads\scripts"
set "GERADOR=%SCRIPTS_DIR%\gerar_fila_whatsapp_intecba.py"
set "SENDER=%SCRIPTS_DIR%\enviar_whatsapp_selenium_intecba.py"
set "CSV=%SCRIPTS_DIR%\fila_whatsapp_intecba.csv"
set "LOG=%SCRIPTS_DIR%\log_envios_whatsapp_intecba.csv"
set "ENTRADA=%SCRIPTS_DIR%\numeros_obras_whatsapp.csv"
set "DEPS_DIR=%SCRIPTS_DIR%\.disparo_deps"
set "PY_CMD=C:\Users\LUCAS\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"

set "PYTHONDONTWRITEBYTECODE=1"

if not exist "%PY_CMD%" (
  where python >nul 2>nul
  if not errorlevel 1 (
    set "PY_CMD=python"
  ) else (
    where py >nul 2>nul
    if not errorlevel 1 (
      set "PY_CMD=py"
    ) else (
      echo ERRO: Python nao encontrado.
      echo Instale o Python ou corrija o caminho em PY_CMD neste BAT.
      goto erro
    )
  )
)

if not exist "%SCRIPTS_DIR%" (
  echo ERRO: pasta dos scripts nao encontrada:
  echo %SCRIPTS_DIR%
  goto erro
)

if not exist "%GERADOR%" (
  echo ERRO: gerador da fila nao encontrado:
  echo %GERADOR%
  goto erro
)

if not exist "%SENDER%" (
  echo ERRO: disparador do WhatsApp nao encontrado:
  echo %SENDER%
  goto erro
)

if not exist "%ENTRADA%" (
  echo ERRO: arquivo de contatos nao encontrado:
  echo %ENTRADA%
  goto erro
)

if not exist "%DEPS_DIR%" mkdir "%DEPS_DIR%"
set "PYTHONPATH=%DEPS_DIR%;%PYTHONPATH%"

echo.
echo =======================================================
echo  DISPARO WHATSAPP PENDENTES - INTEC BA
echo =======================================================
echo.
echo [0] Abrir WhatsApp Web e salvar login
echo [1] Conferir primeiro pendente sem enviar
echo [2] Enviar teste com 1 contato
echo [3] Enviar ate 20 pendentes
echo [4] Enviar TODOS os pendentes
echo [5] Apenas gerar/sincronizar fila
echo [6] Gerar fila incluindo fixos tambem
echo.
set /p "OPCAO=Opcao [2]: "
if "%OPCAO%"=="" set "OPCAO=2"

if not "%OPCAO%"=="0" if not "%OPCAO%"=="1" if not "%OPCAO%"=="2" if not "%OPCAO%"=="3" if not "%OPCAO%"=="4" if not "%OPCAO%"=="5" if not "%OPCAO%"=="6" (
  echo ERRO: opcao invalida.
  goto erro
)

echo.
echo Conferindo dependencias basicas...
"%PY_CMD%" -c "import pandas" >nul 2>nul
if errorlevel 1 (
  echo Instalando pandas...
  "%PY_CMD%" -m pip install --disable-pip-version-check --target "%DEPS_DIR%" pandas openpyxl
  if errorlevel 1 goto erro
)

echo.
echo Gerando/sincronizando fila de WhatsApp...
if "%OPCAO%"=="6" (
  "%PY_CMD%" "%GERADOR%" --saida "%CSV%" --log "%LOG%" --incluir-fixos
) else (
  "%PY_CMD%" "%GERADOR%" --saida "%CSV%" --log "%LOG%"
)
if errorlevel 1 goto erro

if "%OPCAO%"=="5" goto fim
if "%OPCAO%"=="6" goto fim

"%PY_CMD%" -c "import selenium" >nul 2>nul
if errorlevel 1 (
  echo Instalando Selenium...
  "%PY_CMD%" -m pip install --disable-pip-version-check --target "%DEPS_DIR%" selenium
  if errorlevel 1 goto erro
)

if "%OPCAO%"=="0" "%PY_CMD%" "%SENDER%" --csv "%CSV%" --log "%LOG%" --login-only
if "%OPCAO%"=="1" "%PY_CMD%" "%SENDER%" --csv "%CSV%" --log "%LOG%" --validar
if "%OPCAO%"=="2" "%PY_CMD%" "%SENDER%" --csv "%CSV%" --log "%LOG%" --limite 1 --pausa 12
if "%OPCAO%"=="3" "%PY_CMD%" "%SENDER%" --csv "%CSV%" --log "%LOG%" --limite 20 --pausa 12
if "%OPCAO%"=="4" "%PY_CMD%" "%SENDER%" --csv "%CSV%" --log "%LOG%" --limite TODOS --pausa 12
if errorlevel 1 goto erro

goto fim

:erro
echo.
echo ERRO: processo interrompido. Leia a mensagem acima para saber o motivo.
echo.
pause
exit /b 1

:fim
echo.
echo Processo finalizado.
echo Fila: %CSV%
echo Log:  %LOG%
echo.
pause
exit /b 0
