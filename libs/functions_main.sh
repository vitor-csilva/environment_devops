#!/bin/bash

function _get_distro () {
  grep ^ID= /etc/os-release | cut -d = -f 2 | tr -d '"'
}

function _get_arch () {
  case "$(uname -m)" in
    x86_64)  echo "amd64" ;;
    aarch64) echo "arm64" ;;
    armv7l)  echo "arm"   ;;
    *)       echo "amd64" ;;
  esac
}

function _print_header () {
  echo -e "\n#####################"
  echo "$1"
  echo -e "#####################\n"
}

function _append_once () {
  local line="$1"
  local file="$2"
  grep -Fqx "$line" "$file" 2>/dev/null || echo "$line" >> "$file"
}

function _install_curl () {
  if ! command -v curl >/dev/null 2>&1; then
    case "$(_get_distro)" in
      ubuntu) sudo apt install curl -y ;;
      fedora) sudo yum install curl -y ;;
    esac
  fi
}

function _install_wget () {
  if ! command -v wget >/dev/null 2>&1; then
    case "$(_get_distro)" in
      ubuntu) sudo apt install wget -y ;;
      fedora) sudo yum install wget -y ;;
    esac
  fi
}

function _install_gpg () {
  if ! command -v gpg >/dev/null 2>&1; then
    case "$(_get_distro)" in
      ubuntu) sudo apt-get install gpg -y ;;
      fedora) sudo yum install gnupg -y ;;
    esac
  fi
}

function _install_sed () {
  if ! command -v sed >/dev/null 2>&1; then
    case "$(_get_distro)" in
      ubuntu) sudo apt install sed -y ;;
      fedora) sudo yum install sed -y ;;
    esac
  fi
}

function _install_git () {
  if ! command -v git >/dev/null 2>&1; then
    _print_header "Starting Git installation"
    case "$(_get_distro)" in
      ubuntu) sudo apt install git -y ;;
      fedora) sudo yum install git -y ;;
    esac
  fi
}

function _install_prerequisites () {
  _print_header "Installing prerequisites"
  case "$(_get_distro)" in
    ubuntu) sudo apt-get update -y ;;
  esac
  _install_curl
  _install_wget
  _install_sed
  _install_gpg
  _install_git
}

function _install_docker () {
  if [ "$ENABLE_DOCKER" -eq 1 ]; then
    _print_header "Starting Docker installation"
    _install_curl
    # Official remote install script: https://get.docker.com
    curl -fsSL https://get.docker.com | sudo sh
    sudo systemctl enable docker
    sudo systemctl start docker.socket
    sudo systemctl start docker.service
    sudo usermod -a -G docker "$USER"
  fi
}

function _install_Oh_My_Zsh () {
  _print_header "Starting Oh My Zsh installation..."
  wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -P /tmp
  sed -i 's/exec zsh -l/#exec zsh -l/g' /tmp/install.sh
  y | sh /tmp/install.sh
  _install_zsh-syntax-highlighting
  _configure_plugins_zsh
  _configure_theme_zsh
}

function _configure_plugins_zsh () {
  local custom_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  if [ ! -d "$custom_dir/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$custom_dir/plugins/zsh-autosuggestions"
  fi
  sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions kubectl zsh-syntax-highlighting)/g' ~/.zshrc
}

function _configure_theme_zsh () {
  sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="xiong-chiamiov-plus"/g' ~/.zshrc
}

function _install_kubectl () {
  if [ "$ENABLE_KUBECTL" -eq 1 ]; then
    _print_header "Starting Kubectl installation..."
    local arch
    arch="$(_get_arch)"
    _install_curl
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/${arch}/kubectl"
    chmod +x kubectl
    sudo mv -f kubectl /usr/local/bin/kubectl
  fi
}

function _install_krew () {
  if [ "$ENABLE_KREW" -eq 1 ]; then
    if ! command -v kubectl >/dev/null 2>&1; then
      echo "kubectl not found. Installing kubectl before krew..."
      ENABLE_KUBECTL=1
      _install_kubectl
    fi

    _print_header "Starting Krew installation (plugins: neat, get-all)..."
    (
      cd "$(mktemp -d)" &&
      OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
      ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
      KREW="krew-${OS}_${ARCH}" &&
      curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
      tar zxvf "${KREW}.tar.gz" &&
      ./"${KREW}" install krew
    )

    local krew_path_line='export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"'
    export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

    if [ -f "$HOME/.zshrc" ]; then
      _append_once "$krew_path_line" "$HOME/.zshrc"
    fi
    if [ -f "$HOME/.bashrc" ]; then
      _append_once "$krew_path_line" "$HOME/.bashrc"
    fi

    kubectl krew install neat
    kubectl krew install get-all
  fi
}

function _install_kind () {
  if [ "$ENABLE_KIND" -eq 1 ]; then
    _print_header "Starting Kind installation..."
    local arch kind_version
    arch="$(_get_arch)"
    _install_curl
    kind_version="$(curl -fsSL https://api.github.com/repos/kubernetes-sigs/kind/releases/latest | grep -oP '"tag_name":\s*"\K[^"]+' | head -1)"
    curl -Lo /tmp/kind "https://kind.sigs.k8s.io/dl/${kind_version}/kind-linux-${arch}"
    chmod +x /tmp/kind
    sudo mv /tmp/kind /usr/local/bin/kind
    kind --version
  fi
}

function _install_helm () {
  if [ "$ENABLE_HELM" -eq 1 ]; then
    _print_header "Starting Helm 4 installation..."
    local arch helm_version tmp_dir
    arch="$(_get_arch)"
    _install_curl
    # Ensure Helm 4.x (not the 3.x line)
    helm_version="$(curl -fsSL https://api.github.com/repos/helm/helm/releases | grep -oP '"tag_name":\s*"\Kv4\.[^"]+' | head -1)"
    if [ -z "$helm_version" ]; then
      echo "Could not resolve Helm 4 version."
      return 1
    fi
    tmp_dir="$(mktemp -d)"
    curl -fsSL "https://get.helm.sh/helm-${helm_version}-linux-${arch}.tar.gz" -o "${tmp_dir}/helm.tar.gz"
    tar -zxvf "${tmp_dir}/helm.tar.gz" -C "$tmp_dir"
    sudo mv "${tmp_dir}/linux-${arch}/helm" /usr/local/bin/helm
    sudo chmod +x /usr/local/bin/helm
    rm -rf "$tmp_dir"
    helm version
  fi
}

function _install_ferdium () {
  if [ "$ENABLE_FERDIUM" -eq 1 ]; then
    _print_header "Starting Ferdium installation..."
    local arch ferdium_tag ferdium_version deb_arch deb_file
    arch="$(_get_arch)"
    case "$arch" in
      amd64) deb_arch="amd64" ;;
      arm64) deb_arch="arm64" ;;
      *)
        echo "Architecture $arch is not supported for Ferdium (.deb)."
        return 1
        ;;
    esac

    _install_curl
    ferdium_tag="$(curl -fsSL https://api.github.com/repos/ferdium/ferdium-app/releases/latest | grep -oP '"tag_name":\s*"\K[^"]+' | head -1)"
    ferdium_version="${ferdium_tag#v}"
    deb_file="/tmp/Ferdium-linux-${ferdium_version}-${deb_arch}.deb"

    curl -fsSL \
      "https://github.com/ferdium/ferdium-app/releases/download/${ferdium_tag}/Ferdium-linux-${ferdium_version}-${deb_arch}.deb" \
      -o "$deb_file"
    sudo apt install "$deb_file" -y
    rm -f "$deb_file"
  fi
}

function _install_zsh-syntax-highlighting () {
  local plugin_dir="$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
  if [ ! -d "$plugin_dir" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$plugin_dir"
  fi
}

function _install_tilix () {
  if [ "$ENABLE_TILIX" -eq 1 ]; then
    _print_header "Starting Tilix installation..."
    sudo apt install tilix -y
    tilix --version
    sudo update-alternatives --config x-terminal-emulator
  fi
}

function _install_zsh () {
  if [ "$ENABLE_ZSH" -eq 1 ]; then
    _print_header "Starting Zsh installation"
    sudo apt install zsh -y
    chsh -s /bin/zsh
    _install_wget
    _install_sed
    _install_git
    _install_Oh_My_Zsh
  fi
}

function _install_vscode () {
  if [ "$ENABLE_CODE" -eq 1 ]; then
    _print_header "Starting Visual Studio Code installation..."
    _install_wget
    _install_gpg
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg && \
    sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg && \
    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list' && \
    rm -f packages.microsoft.gpg && \
    sudo apt install apt-transport-https -y && \
    sudo apt update && \
    sudo apt install code -y
  fi
}

function _install_sublime () {
  if [ "$ENABLE_SUBLIME" -eq 1 ]; then
    _print_header "Starting Sublime Text installation..."
    wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg > /dev/null
    echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
    sudo apt-get update
    sudo apt-get install sublime-text -y
  fi
}

function _install_yq () {
  if [ "$ENABLE_YQ" -eq 1 ]; then
    _print_header "Starting yq installation..."
    local arch
    arch="$(_get_arch)"
    sudo wget "https://github.com/mikefarah/yq/releases/latest/download/yq_linux_${arch}" -O /usr/local/bin/yq && \
      sudo chmod +x /usr/local/bin/yq
  fi
}

function _install_jq () {
  if [ "$ENABLE_JQ" -eq 1 ]; then
    _print_header "Starting jq installation..."
    sudo apt-get install jq -y
  fi
}

function _install_ansible () {
  if [ "$ENABLE_ANSIBLE" -eq 1 ]; then
    _print_header "Starting Ansible installation..."
    sudo DEBIAN_FRONTEND=noninteractive apt-add-repository --yes ppa:ansible/ansible
    sudo apt update
    sudo apt install ansible -y
  fi
}

function _install_flameshot () {
  if [ "$ENABLE_FLAMESHOT" -eq 1 ]; then
    _print_header "Starting Flameshot installation..."
    sudo apt install flameshot -y
  fi
}

function _install_anydesk () {
  if [ "$ENABLE_ANYDESK" -eq 1 ]; then
    _print_header "Starting AnyDesk installation..."
    sudo apt update
    sudo apt install ca-certificates curl -y
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://keys.anydesk.com/repos/DEB-GPG-KEY -o /etc/apt/keyrings/keys.anydesk.com.asc
    sudo chmod a+r /etc/apt/keyrings/keys.anydesk.com.asc

    echo "deb [signed-by=/etc/apt/keyrings/keys.anydesk.com.asc] http://deb.anydesk.com all main" | sudo tee /etc/apt/sources.list.d/anydesk-stable.list > /dev/null

    sudo apt update
    sudo apt install anydesk -y

    _disable_anydesk_autostart

    local CONFIG_FILE="/etc/gdm3/custom.conf"
    local BACKUP_FILE="/etc/gdm3/custom.conf.bak"

    if [ -f "$CONFIG_FILE" ]; then
      sudo cp "$CONFIG_FILE" "$BACKUP_FILE"
      echo "Backup created at $BACKUP_FILE"

      sudo sed -i \
          -e 's/#WaylandEnable=false/WaylandEnable=false/' \
          -e 's/#  AutomaticLoginEnable = true/AutomaticLoginEnable = true/' \
          -e "s|#  AutomaticLogin =.*|AutomaticLogin = ${USER}|" \
          "$CONFIG_FILE"

      echo -e "\nGDM for AnyDesk configuration updated successfully!"
    else
      echo "File $CONFIG_FILE not found. Skipping GDM adjustment."
    fi
  fi
}

function _disable_anydesk_autostart () {
  _print_header "Disabling AnyDesk autostart"

  # Stop and disable the systemd service (main autostart path)
  if systemctl list-unit-files anydesk.service >/dev/null 2>&1; then
    sudo systemctl disable --now anydesk.service 2>/dev/null || true
    echo "Disabled systemd unit: anydesk.service"
  fi

  # Hide XDG autostart entries (system and user)
  local desktop_file
  for desktop_file in \
    /etc/xdg/autostart/anydesk*.desktop \
    "$HOME"/.config/autostart/anydesk*.desktop
  do
    [ -f "$desktop_file" ] || continue
    if [[ "$desktop_file" == /etc/* ]]; then
      if ! grep -q '^Hidden=true' "$desktop_file"; then
        echo "Hidden=true" | sudo tee -a "$desktop_file" >/dev/null
      fi
    else
      if ! grep -q '^Hidden=true' "$desktop_file"; then
        echo "Hidden=true" >> "$desktop_file"
      fi
    fi
    echo "Disabled autostart desktop entry: $desktop_file"
  done

  # Remove AnyDesk's own autostart config if present
  if [ -f "$HOME/.anydesk/autostart.conf" ]; then
    rm -f "$HOME/.anydesk/autostart.conf"
    echo "Removed $HOME/.anydesk/autostart.conf"
  fi

  echo "AnyDesk will no longer start automatically with the OS."
}

function _install_terraform () {
  if [ "$ENABLE_TERRAFORM" -eq 1 ]; then
    _print_header "Starting Terraform installation..."
    wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt update && sudo apt install terraform -y
  fi
}

function _message () {
    cat <<EOF


#####################
# After Installation #
#####################

-> Flameshot:

After installation, configure the keyboard shortcut by following these steps:

  1. Go to Settings -> Keyboard -> Keyboard Shortcuts -> View and Customize Shortcuts -> Custom Shortcuts
  2. Add a new shortcut with the following details:

     Name: Flameshot
     Command: /bin/sh -c "flameshot gui > /dev/null &"
     Shortcut: Choose your preferred shortcut, e.g., Alt+P

-> Kubernetes (krew):

  Plugins installed: neat, get-all
  Examples:
    kubectl neat get -- pod <pod> -oyaml
    kubectl get-all

-> Kind:

  Requires Docker. After reboot (or newgrp docker), create a cluster with:
    kind create cluster

-> Ferdium:

  Open Ferdium and add Microsoft Teams (or other services) as needed.

-> Post-Script Execution:

  1. Reboot your system to apply the configurations!
  2. If Docker was installed, run: newgrp docker (or reboot)

EOF
}

function _help () {
    echo "
$ ./devops_tools.sh [options]

Accepted options:
  --no-zsh        - Skip Zsh installation.
  --no-vscode     - Skip Visual Studio Code installation.
  --no-docker     - Skip Docker installation.
  --no-kubectl    - Skip kubectl installation.
  --no-krew       - Skip Krew and plugins (neat, get-all).
  --no-kind       - Skip Kind installation.
  --no-helm       - Skip Helm 4 installation.
  --no-ferdium    - Skip Ferdium installation.
  --no-tilix      - Skip Tilix installation.
  --no-sublime    - Skip Sublime installation.
  --no-yq         - Skip yq installation.
  --no-jq         - Skip jq installation.
  --no-ansible    - Skip Ansible installation.
  --no-flameshot  - Skip Flameshot installation.
  --no-anydesk    - Skip AnyDesk installation.
  --no-terraform  - Skip Terraform installation.
  -h | --help     - Show this help menu.
    "
}

function _error () {
    echo "Option $1 does not exist."
    _help
    exit 1
}
