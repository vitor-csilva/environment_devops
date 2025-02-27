function _get_distro () {
	grep ^ID= /etc/os-release | cut -d = -f 2
}

function _install_curl () {
	case "$(_get_distro)" in
  	ubuntu) sudo apt install curl -y ;;
  	fedora) sudo yum install curl -y ;;
	esac
}

function _install_wget () {
  case "$(_get_distro)" in
  ubuntu) sudo apt install wget -y ;;
  fedora) sudo yum install wget -y ;;
  esac
}

function _install_gpg () {
  case "$(_get_distro)" in
  ubuntu) sudo apt-get install gpg -y ;;
  fedora) sudo yum install gnupg -y ;;
  esac
}

function _install_sed () {
  case "$(_get_distro)" in
  ubuntu) sudo apt install sed -y ;;
  fedora) sudo yum install sed -y ;;
  esac
}

function _install_git () {
  echo -e "#####################\n"
  echo "Iniciando instalação do Git "
  echo -e "\n#####################\n"
  case "$(_get_distro)" in
  ubuntu) sudo apt install git -y ;;
  fedora) sudo yum install git -y ;;
  esac
}

function _install_docker () {
  if [ $ENABLE_DOCKER -eq 1 ]; then
    echo -e "#####################\n"
    echo "Iniciando instalação do Docker "
    echo -e "\n#####################\n"
    _install_curl
    curl -fsSL https://get.docker.com -o get-docker.sh && \
    sudo sh get-docker.sh && \
    sudo systemctl enable docker && \
    sudo systemctl start docker.socket && \
    sudo systemctl start docker.service && \
    sudo usermod -a -G docker $USER #&& \
  fi
	#echo ">> Execute 'newgrp docker' e inicie o script novamente." && \
	#exit
}

function _install_Oh_My_Zsh () {
  echo -e "\n#####################\n"
  echo "Iniciando instalação do Oh My Zsh..."
  echo -e "\n#####################\n"
  wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -P /tmp
  sed -i 's/exec zsh -l/#exec zsh -l/g' /tmp/install.sh
  y | sh /tmp/install.sh
  _install_zsh-syntax-highlighting
  _configure_plugins_zsh
  _configure_theme_zsh
}

function _configure_plugins_zsh () {
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions kubectl zsh-syntax-highlighting)/g' ~/.zshrc
}

function _configure_theme_zsh () {
  sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="xiong-chiamiov-plus"/g' ~/.zshrc
}

function _install_kubectl {
  if [ $ENABLE_KUBECTL -eq 1 ]; then
    echo -e "\n#####################\n"
    echo "Iniciando instalação do Kubectl..."
    echo -e "\n#####################\n"
    _install_curl
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    sudo mv -f kubectl /usr/bin/
    echo "export PATH=$PATH:~/usr/bin/" >> ~/.zshrc
  fi
}

function _install_zsh-syntax-highlighting {
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
}

function _install_tilix {
  if [ $ENABLE_TILIX -eq 1 ]; then
    echo -e "#####################\n"
    echo "Iniciando instalação do Tilix..."
    echo -e "\n#####################\n"
    sudo apt install tilix -y
    tilix --version
    sudo update-alternatives --config x-terminal-emulator   ## form manual set configure.
    #sudo update-alternatives --set x-terminal-emulator /usr/bin/tilix
  fi
}

function _install_zsh () {
  if [ $ENABLE_ZSH -eq 1 ]; then
      echo -e "#####################\n"
      echo "Iniciando instalação do ZSH "
      echo -e "\n#####################\n"
      sudo apt install zsh -y
      chsh -s /bin/zsh # Command use for set standard shell
      #zsh # enter ZSH shell
      _install_wget
      _install_sed
      _install_git
      _install_Oh_My_Zsh
  fi
}

function _install_vscode () {
  if [ $ENABLE_CODE -eq 1 ]; then
      echo -e "#####################\n"
      echo "Iniciando instalação do Visual Studio Code..."
      echo -e "\n#####################\n"
      #sudo apt-get install wget gpg
      _install_wget
      _install_gpg
      wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg &&\
      sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg &&\
      sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list' &&\
      rm -f packages.microsoft.gpg &&\
      sudo apt install apt-transport-https &&\
      sudo apt update &&\
      sudo apt install code -y
  fi
}

function _install_sublime () {
  if [ $ENABLE_SUBLIME -eq 1 ]; then
    echo -e "#####################\n"
    echo "Iniciando instalação do Sublime Text..."
    echo -e "\n#####################\n"
    wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg > /dev/null
    echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
    sudo apt-get update
    sudo apt-get install sublime-text -y
  fi
}

function _install_yq () {
  if [ $ENABLE_YQ -eq 1 ]; then
    echo -e "#####################\n"
    echo "Iniciando instalação do yq..."
    echo -e "\n#####################\n"
    sudo wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq &&\
      sudo chmod +x /usr/bin/yq
  fi
}

function _install_jq () {
  if [ $ENABLE_JQ -eq 1 ]; then
    echo -e "#####################\n"
    echo "Iniciando instalação do jq..."
    echo -e "\n#####################\n"
    sudo apt-get install jq -y
  fi
}

function _install_ansible () {
  if [ $ENABLE_ANSIBLE -eq 1 ]; then
    echo -e "#####################\n"
    echo "Iniciando instalação do Ansible..."
    echo -e "\n#####################\n"
    sudo apt-add-repository ppa:ansible/ansible
    sudo apt update
    sudo apt install ansible -y
  fi
}

function _install_flameshot () {
  if [ "$ENABLE_FLAMESHOT" -eq 1 ]; then
    echo -e "#####################\n"
    echo "Iniciando instalação do Flameshot..."
    echo -e "\n#####################\n"
    sudo apt install flameshot -y
  fi
}

function _install_anydesk () {
  if [ "$ENABLE_ANYDESK" -eq 1 ]; then
    #http://deb.anydesk.com/howto.html
    echo -e "#####################\n"
    echo "Iniciando instalação do Anydesk..."
    echo -e "\n#####################\n"
    # Add the AnyDesk GPG key
    sudo apt update
    sudo apt install ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://keys.anydesk.com/repos/DEB-GPG-KEY -o /etc/apt/keyrings/keys.anydesk.com.asc
    sudo chmod a+r /etc/apt/keyrings/keys.anydesk.com.asc

    # Add the AnyDesk apt repository
    echo "deb [signed-by=/etc/apt/keyrings/keys.anydesk.com.asc] http://deb.anydesk.com all main" | sudo tee /etc/apt/sources.list.d/anydesk-stable.list > /dev/null

    # Update apt caches and install the AnyDesk client
    sudo apt update
    sudo apt install anydesk
    
    CONFIG_FILE="/etc/gdm3/custom.conf"
    BACKUP_FILE="/etc/gdm3/custom.conf.bak"

    # Create a backup before modifying
    sudo cp "$CONFIG_FILE" "$BACKUP_FILE"
    echo "Backup created at $BACKUP_FILE"

    # Modify the file
    sudo sed -i \
        -e 's/#WaylandEnable=false/WaylandEnable=false/' \
        -e 's/#  AutomaticLoginEnable = true/AutomaticLoginEnable = true/' \
        -e 's|#  AutomaticLogin =.*|AutomaticLogin = $USERNAME|' \
        "$CONFIG_FILE"

    echo -e "\nGDM for Anydesk configuration updated successfully!"
  fi
}


function _install_terraform () {
  if [ "$ENABLE_TERRAFORM" -eq 1 ]; then
    echo -e "#####################\n"
    echo "Iniciando instalação do Terraform..."
    echo -e "\n#####################\n"
    wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt update && sudo apt install terraform
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

-> Post-Script Execution:

  1. Reboot your system to apply the configurations!

EOF
}



function _help () {
    echo "
$ ./devops_tools.sh [parâmetros]

Parâmetros aceitos:
  --no-zsh        - Não fará a instalação do zsh.
  --no-vscode     - Não fará a instalação do Virtual Studio Code.
  --no-docker     - Não fará a instalação do docker.
  --no-kubectl    - Não fará a instalação do kubectl.
  --no-tilix      - Não fará a instalação do Tilix.
  --no-sublime    - Não fará a instalação do Sublime.
  --no-yq         - Não fará a instalação do yq.
  --no-jq         - Não fará a instalação do jq.
  --no-ansible    - Não fará a instalação do Ansible.
  --no-flameshot  - Não fará a instalação do Flameshot.
  --no-anydesk    - Não fará a instalação do Anydesk.
  --no-terraform  - Não fará a instalação do terraform.
  -h | --help     - Menu de ajuda.
    "
}

function _error () {
    echo "O parâmetro $1 não existe."
    _help
    exit 1
}