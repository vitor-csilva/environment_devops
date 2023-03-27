#! /bin/bash
#
# devops_tools.sh - É um ferramenta desenvolvida para instalacoes de ferramentas DevOps utilizadas no dia a dia.
# 
# Autor: Vitor Costa
#
# ------------------------------------------------------------------------ #
# Descrição: 
# 
# Exemplos: 
#       
# ------------------------------------------------------------------------ #

source ./libs/functions_main.sh

# ------------------------------- VARIÁVEIS ----------------------------------------- #
VAR_SHELL=$(echo ${SHELL##*/})
ENABLE_ZSH=1
ENABLE_CODE=1
ENABLE_DOCKER=1

function trapped () {
  echo "Erro na linha $1."
  #_clean
  exit 1
}

trap 'trapped $LINENO' ERR

# ------------------------------- EXECUÇÃO ----------------------------------------- #

while [ -n "$1" ]; do
    case "$1" in
        --no-zsh)       ENABLE_ZSH=0    ;;
        --no-vscode)    ENABLE_CODE=0   ;;
        --no-docker)    ENABLE_DOCKER=0 ;;
        -h|--help)      _help; exit     ;;
        *)              _error "$1"     ;;
    esac
    shift
done 

# [ -z "`which curl`" ]                           &&  _install_curl
# [ -z "`which wget`" ]                           &&  _install_wget
# [ -z "`which sed`" ]                            &&  _install_sed
# [ -z "`which gpg`" ]                            &&  _install_gpg
# [ -z "`which git`" ]                            &&  _install_git
[ -z "`which zsh`" ] || [ $VAR_SHELL != "zsh" ] &&  _install_zsh
[ -z "`which code`" ]                           &&  _install_vscode
[ -z "`which docker`" ]                         &&  _install_docker