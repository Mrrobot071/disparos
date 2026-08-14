@echo off
setlocal EnableExtensions
chcp 65001 >nul
title Disparar e-mails pendentes - Intec BA

set "DISPARADOR=C:\Users\LUCAS\Desktop\ct\disparo novo\disparo_obras_intecba_LUCAS.bat"

echo.
echo =======================================================
echo  DISPARO DE TODOS OS E-MAILS PENDENTES - INTEC BA
echo =======================================================
echo.
echo Este processo consolida os 754 registros captados,
echo confere o historico e envia somente para e-mails pendentes.
echo Contatos ja confirmados no log nao serao repetidos.
echo.

if not exist "%DISPARADOR%" (
  echo ERRO: disparador principal nao encontrado:
  echo %DISPARADOR%
  echo.
  pause
  exit /b 1
)

set "DISPARO_NOPAUSE=1"
:retomar
set /a TENTATIVA+=1
echo.
echo Tentativa automatica %TENTATIVA% de 12...
call "%DISPARADOR%" todos
set "RESULTADO=%ERRORLEVEL%"

if "%RESULTADO%"=="0" goto concluido
if %TENTATIVA% LSS 12 (
  echo.
  echo O Brave ou o UOL interrompeu a rodada. Retomando apenas os pendentes em 10 segundos...
  timeout /t 10 /nobreak >nul
  goto retomar
)

echo.
echo O processo terminou com codigo %RESULTADO% apos %TENTATIVA% tentativas.
echo Os envios confirmados foram preservados e os demais continuam pendentes.
echo Abra este mesmo BAT novamente para retomar sem duplicar.
goto fim

:concluido
echo.
echo Processo concluido. Consulte o log e a fila na pasta ct\leads\scripts.

:fim
echo.
pause
exit /b %RESULTADO%
