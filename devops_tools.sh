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
#
#
# ------------------------------------------------------------------------ #

source ./libs/functions_main.sh

# ------------------------------- VARIÁVEIS ----------------------------------------- #
VAR_SHELL=$(echo ${SHELL##*/})

[ -z "`which curl`" ]   &&  _install_curl
[ -z "`which wget`" ]   &&  _install_wget
[ -z "`which sed`" ]    &&  _install_sed
[ -z "`which git`" ]    &&  _install_git
#[ -z "`which zsh`" ||  $VAR_SHELL != "zsh" ] &&  _install_zsh
[ -z "`which zsh`" ] &&  _install_zsh