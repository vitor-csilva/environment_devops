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
  echo "Iniciando instalação do GIT "
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
  wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -P /tmp
  sed -i 's/exec zsh -l/#exec zsh -l/g' /tmp/install.sh
  y | sh /tmp/install.sh
  _install_zsh-syntax-highlighting
  _install_kubectl
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
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  chmod +x kubectl
  sudo mv -f kubectl /bin/
}

function _install_zsh-syntax-highlighting {
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
}

function _install_tilix {
  if [ $ENABLE_TILIX -eq 1 ]; then
    sudo apt install tilix -y
    tilix --version
    #sudo update-alternatives --config x-terminal-emulator   ## form manual set configure.
    sudo update-alternatives --set x-terminal-emulator /usr/bin/tilix
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
      echo "Iniciando instalação do Visual Studio Code"
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

function _help () {
    echo "
$ ./devops_tools.sh [parâmetros]

Parâmetros aceitos:
  --no-zsh      - Não fará a instalação do zsh.
  --no-vscode   - Não fará a instalação do Virtual Studio Code.
  --no-docker   - Não fará a instalação do docker.
  -h | --help   - Menu de ajuda.
    "
}

function _error () {
    echo "O parâmetro $1 não existe."
    _help
    exit 1
}