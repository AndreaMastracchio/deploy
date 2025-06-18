#!/bin/bash

# 🎯 Magento Deploy Helper per DDEV
# 👨‍💻 Developed by Andrea Gregorio Mastracchio
# 🗂 Posizione: .ddev/commands/web/deploy
# ▶️ Esegui con: ddev deploy [ucs|uc|c|s|v]

# 🎨 COLORI & ICONE
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
RESET=$(tput sgr0)
BOLD=$(tput bold)

ICON_OK="✅"
ICON_ERR="❌"
ICON_RUN="🔄"
ICON_INFO="⚙️"

i=1
upgrade=false
compile=false
static=false
verbose=false
deploy=true

space() { echo ""; }
increment() { ((i++)); }

intro() {
  space
  echo -e "${MAGENTA}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  echo -e "${MAGENTA}${BOLD}★ Deploy Magento 2 con DDEV - by Andrea G. Mastracchio ★${RESET}"
  echo -e "${MAGENTA}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  space
}

show_help() {
  echo -e "${BOLD}${BLUE}Modalità disponibili:${RESET}"
  echo -e "${GREEN}s  | staticonly ${RESET}→ Solo static content"
  echo -e "${GREEN}u  | upgrade     ${RESET}→ Solo setup:upgrade"
  echo -e "${GREEN}c  | compile     ${RESET}→ Solo di:compile"
  echo -e "${GREEN}uc | nostatic    ${RESET}→ upgrade + compile"
  echo -e "${GREEN}ucs| normal      ${RESET}→ upgrade + compile + static"
  echo -e "${GREEN}v  | verbose     ${RESET}→ Output dettagliato"
  echo -e "${GREEN}h  | help        ${RESET}→ Mostra questo aiuto"
  space
  echo "Esempi:"
  echo "  ddev deploy uc v     → Upgrade + compile in verbose"
  echo "  ddev deploy c        → Solo compile"
  space
  deploy=false
}

spinner() {
  local pid=$1
  local msg=$2
  local delay="0.1"
  local spinner_chars=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
  tput civis
  while kill -0 "$pid" 2>/dev/null; do
    for frame in "${spinner_chars[@]}"; do
      printf "\r${BLUE}${frame} ${msg}...${RESET}"
      sleep "$delay"
    done
  done
  tput cnorm
}

command_execution() {
  local cmd="$1"
  local label="$2"
  local success="$3"
  local error="$4"

  if [[ "$label" == "Compilazione DI" ]]; then
    rm -rf generated/code/* generated/metadata/* &>/dev/null
  fi

  if [ "$verbose" = true ]; then
    echo -e "${ICON_RUN} ${BLUE}${label}...${RESET}"
    echo -e "${BOLD}🔍 Output comando: ${cmd}${RESET}"
    bash -c "$cmd"
    local exitCode=$?
  else
    bash -c "$cmd" &>/dev/null &
    local pid=$!
    spinner "$pid" "$label"
    wait "$pid"
    local exitCode=$?
    printf "\r\033[K"
  fi

  if [ $exitCode -ne 0 ]; then
    echo -e "${ICON_ERR} ${RED}${error}${RESET}"
    space
    exit 1
  fi

  echo -e "\r${ICON_OK} ${GREEN}${success}${RESET}"
  increment
}

clear_var() {
  command_execution \
    "rm -rf var/log/* var/cache/* var/view_preprocessed/* generated/code/* generated/metadata/*" \
    "Pulizia file temporanei" \
    "Pulizia completata" \
    "Errore durante la pulizia"
}

# 🧠 PARSING PARAMETRI
for var in "$@"; do
  case "$var" in
    s|staticonly) static=true ;;
    u|upgrade) upgrade=true ;;
    c|compile) compile=true ;;
    uc|nostatic) upgrade=true; compile=true ;;
    ucs|normal) upgrade=true; compile=true; static=true ;;
    v|verbose) verbose=true ;;
    h|help|"") show_help ;;
    *) echo -e "${RED}Parametro sconosciuto: $var${RESET}"; deploy=false ;;
  esac
done

# 🚀 AVVIO
intro

if [ "$deploy" = true ]; then

  command_execution "xdebug off" "Disabilito Xdebug" "Xdebug disabilitato" "Errore disattivazione Xdebug"
  clear_var

  if [ "$upgrade" = true ]; then
    command_execution "magento setup:upgrade" "Eseguo setup:upgrade" "Upgrade completato" "Errore upgrade"
  fi

  if [ "$compile" = true ]; then
    command_execution "magento setup:di:compile" "Compilazione DI" "Compile completato" "Errore compile"
  fi

  if [ "$static" = true ]; then
    command_execution "magento setup:static-content:deploy -a frontend -a adminhtml -f" "Deploy statici" "Static completato" "Errore static"
  fi

  command_execution "magento cache:flush" "Cache flush" "Flush completato" "Errore flush"
  command_execution "magento cache:clean" "Cache clean" "Clean completato" "Errore clean"
  command_execution "magento deploy:mode:set developer" "Set developer mode" "Developer mode attivo" "Errore developer mode"
  command_execution "xdebug on" "Riattivo Xdebug" "Xdebug attivo" "Errore Xdebug"

  space
  echo -e "${ICON_OK} ${BOLD}${GREEN}Deploy completato con successo! 🎉${RESET}"
  space
fi
