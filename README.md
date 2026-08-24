# Disparos

Scripts de disparo em massa (e-mail e WhatsApp) com controle de fila e histórico para não repetir envios.

## Scripts

| Script | Função |
|---|---|
| `UOL.bat` | Disparo de e-mails pendentes via webmail UOL |
| `ZAP.bat` | Gera a fila de contatos e dispara mensagens de WhatsApp via Selenium |

## Como funciona

- Cada script monta uma **fila de envio** a partir de um CSV de contatos
- Consulta o **log de envios** antes de disparar, evitando repetições
- Registra cada envio concluído no log

## Requisitos

- Windows
- Python instalado
- Google Chrome (para o disparo via Selenium)

## Observação

Os caminhos dos scripts e bases são configuráveis nas variáveis no topo de cada `.bat`.
