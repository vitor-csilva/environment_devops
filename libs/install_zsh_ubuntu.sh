#!/bin/bash
#
# install_zsh_ubuntu.sh - Standalone installer for Zsh + Oh My Zsh on Ubuntu.
#
# Usage:
#   ./libs/install_zsh_ubuntu.sh
#
set -euo pipefail

OMZ_INSTALL_URL="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
AUTOSUGGESTIONS_REPO="https://github.com/zsh-users/zsh-autosuggestions"
SYNTAX_HIGHLIGHTING_REPO="https://github.com/zsh-users/zsh-syntax-highlighting.git"
ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
PLUGINS="git zsh-autosuggestions kubectl zsh-syntax-highlighting"
THEME="xiong-chiamiov-plus"

function _print_header () {
  echo -e "\n#####################"
  echo "$1"
  echo -e "#####################\n"
}

function _install_prerequisites () {
  _print_header "Updating apt and installing prerequisites"
  sudo apt-get update -y
  sudo apt-get install -y git curl wget sed zsh
}

function _set_default_shell () {
  local current_shell="${SHELL##*/}"
  if [ "$current_shell" = "zsh" ]; then
    echo "Zsh is already the default shell."
    return 0
  fi

  _print_header "Setting Zsh as the default shell"
  if command -v zsh >/dev/null 2>&1; then
    chsh -s "$(command -v zsh)"
  else
    chsh -s /bin/zsh
  fi
}

function _install_oh_my_zsh () {
  if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "Oh My Zsh is already installed. Skipping."
    return 0
  fi

  _print_header "Installing Oh My Zsh"
  # Official unattended flags avoid interactive prompts and exec zsh
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL "$OMZ_INSTALL_URL")" "" --unattended
}

function _clone_plugin () {
  local name="$1"
  local repo="$2"
  local target="${ZSH_CUSTOM_DIR}/plugins/${name}"

  if [ -d "$target" ]; then
    echo "Plugin '${name}' already present. Skipping clone."
    return 0
  fi

  git clone "$repo" "$target"
}

function _configure_plugins () {
  _print_header "Configuring Oh My Zsh plugins"
  mkdir -p "${ZSH_CUSTOM_DIR}/plugins"

  _clone_plugin "zsh-autosuggestions" "$AUTOSUGGESTIONS_REPO"
  _clone_plugin "zsh-syntax-highlighting" "$SYNTAX_HIGHLIGHTING_REPO"

  if [ -f "$HOME/.zshrc" ]; then
    if grep -qE '^plugins=\(' "$HOME/.zshrc"; then
      sed -i "s/^plugins=(.*)/plugins=(${PLUGINS})/" "$HOME/.zshrc"
    else
      echo "plugins=(${PLUGINS})" >> "$HOME/.zshrc"
    fi
  fi
}

function _configure_theme () {
  _print_header "Configuring Oh My Zsh theme"
  if [ -f "$HOME/.zshrc" ]; then
    if grep -qE '^ZSH_THEME=' "$HOME/.zshrc"; then
      sed -i "s/^ZSH_THEME=\".*\"/ZSH_THEME=\"${THEME}\"/" "$HOME/.zshrc"
    else
      echo "ZSH_THEME=\"${THEME}\"" >> "$HOME/.zshrc"
    fi
  fi
}

function _done_message () {
  cat <<EOF

###########################################
 Installation finished.
 Please reboot (or open a new login shell)
 for the default shell change to take effect.
###########################################

EOF
}

function main () {
  _install_prerequisites
  _set_default_shell
  _install_oh_my_zsh
  _configure_plugins
  _configure_theme
  _done_message
}

main "$@"
