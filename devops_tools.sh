#!/bin/bash
#
# devops_tools.sh - Ferramenta desenvolvida para instalações de ferramentas DevOps utilizadas no dia a dia.
#
# Autor: Vitor Costa
#
# ------------------------------------------------------------------------ #
# Descrição:
#   Instala e configura um conjunto de ferramentas DevOps em ambientes Linux
#   (Ubuntu), com flags para pular itens específicos.
#
# Exemplos:
#   ./devops_tools.sh
#   ./devops_tools.sh --no-anydesk --no-ferdium
#   ./devops_tools.sh --help
# ------------------------------------------------------------------------ #

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=libs/functions_main.sh
source "${SCRIPT_DIR}/libs/functions_main.sh"

# ------------------------------- VARIÁVEIS ----------------------------------------- #
VAR_SHELL="${SHELL##*/}"
ENABLE_ZSH=1
ENABLE_CODE=1
ENABLE_DOCKER=1
ENABLE_KUBECTL=1
ENABLE_KREW=1
ENABLE_KIND=1
ENABLE_HELM=1
ENABLE_FERDIUM=1
ENABLE_TILIX=1
ENABLE_SUBLIME=1
ENABLE_YQ=1
ENABLE_JQ=1
ENABLE_ANSIBLE=1
ENABLE_FLAMESHOT=1
ENABLE_ANYDESK=1
ENABLE_TERRAFORM=1

function trapped () {
  echo "Erro na linha $1."
  exit 1
}

trap 'trapped $LINENO' ERR

# ------------------------------- EXECUÇÃO ----------------------------------------- #

while [ -n "$1" ]; do
    case "$1" in
        --no-zsh)       ENABLE_ZSH=0      ;;
        --no-vscode)    ENABLE_CODE=0     ;;
        --no-docker)    ENABLE_DOCKER=0   ;;
        --no-kubectl)   ENABLE_KUBECTL=0  ;;
        --no-krew)      ENABLE_KREW=0     ;;
        --no-kind)      ENABLE_KIND=0     ;;
        --no-helm)      ENABLE_HELM=0     ;;
        --no-ferdium)   ENABLE_FERDIUM=0  ;;
        --no-tilix)     ENABLE_TILIX=0    ;;
        --no-sublime)   ENABLE_SUBLIME=0  ;;
        --no-yq)        ENABLE_YQ=0       ;;
        --no-jq)        ENABLE_JQ=0       ;;
        --no-ansible)   ENABLE_ANSIBLE=0  ;;
        --no-flameshot) ENABLE_FLAMESHOT=0;;
        --no-anydesk)   ENABLE_ANYDESK=0  ;;
        --no-terraform) ENABLE_TERRAFORM=0;;
        -h|--help)      _help; exit 0     ;;
        *)              _error "$1"       ;;
    esac
    shift
done

_install_prerequisites

[ "$ENABLE_ZSH" -eq 1 ] && { ! command -v zsh >/dev/null 2>&1 || [ "$VAR_SHELL" != "zsh" ]; } && _install_zsh
[ "$ENABLE_CODE" -eq 1 ] && ! command -v code >/dev/null 2>&1      && _install_vscode
[ "$ENABLE_DOCKER" -eq 1 ] && ! command -v docker >/dev/null 2>&1  && _install_docker
[ "$ENABLE_KUBECTL" -eq 1 ] && ! command -v kubectl >/dev/null 2>&1 && _install_kubectl
[ "$ENABLE_KREW" -eq 1 ] && [ ! -d "${KREW_ROOT:-$HOME/.krew}" ]   && _install_krew
[ "$ENABLE_KIND" -eq 1 ] && ! command -v kind >/dev/null 2>&1      && _install_kind
if [ "$ENABLE_HELM" -eq 1 ]; then
    if ! command -v helm >/dev/null 2>&1; then
        _install_helm
    else
        HELM_MAJOR="$(helm version --template='{{.Version}}' 2>/dev/null | sed 's/^v//;s/\..*//')"
        [ -z "$HELM_MAJOR" ] && HELM_MAJOR="$(helm version --short 2>/dev/null | sed 's/^v//;s/\..*//;s/+.*//')"
        [ "${HELM_MAJOR:-0}" -lt 4 ] && _install_helm
    fi
fi
[ "$ENABLE_FERDIUM" -eq 1 ] && ! command -v ferdium >/dev/null 2>&1 && _install_ferdium
[ "$ENABLE_TILIX" -eq 1 ] && ! command -v tilix >/dev/null 2>&1    && _install_tilix
[ "$ENABLE_SUBLIME" -eq 1 ] && ! command -v subl >/dev/null 2>&1   && _install_sublime
[ "$ENABLE_YQ" -eq 1 ] && ! command -v yq >/dev/null 2>&1          && _install_yq
[ "$ENABLE_JQ" -eq 1 ] && ! command -v jq >/dev/null 2>&1          && _install_jq
[ "$ENABLE_ANSIBLE" -eq 1 ] && ! command -v ansible >/dev/null 2>&1 && _install_ansible
[ "$ENABLE_FLAMESHOT" -eq 1 ] && ! command -v flameshot >/dev/null 2>&1 && _install_flameshot
[ "$ENABLE_ANYDESK" -eq 1 ] && ! command -v anydesk >/dev/null 2>&1 && _install_anydesk
[ "$ENABLE_TERRAFORM" -eq 1 ] && ! command -v terraform >/dev/null 2>&1 && _install_terraform

_message
