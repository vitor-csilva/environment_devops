function _get_distro () {
	grep ^ID= /etc/os-release | cut -d = -f 2
}

function _install_curl () {
	case "$(_get_distro)" in
  	ubuntu) sudo apt install curl -y ;;
  	fedora) sudo yum install curl -y ;;
	esac
}

function _install_git () {
    case "$(_get_distro)" in
    ubuntu) sudo apt install git -y ;;
    fedora) sudo yum install git -y ;;
    esac
}

function _install_sed () {
    case "$(_get_distro)" in
    ubuntu) sudo apt install sed -y ;;
    fedora) sudo yum install sed -y ;;
    esac
}

function _install_wget () {
    case "$(_get_distro)" in
    ubuntu) sudo apt install wget -y ;;
    fedora) sudo yum install wget -y ;;
    esac
}

function _install_Oh_My_Zsh () {
    wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -P /tmp
    sed -i 's/exec zsh -l/#exec zsh -l/g' /tmp/install.sh
    y | sh /tmp/install.sh
    _configure_autosuggestions
}

function _configure_autosuggestions () {
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions)/g' ~/.zshrc
}

function _install_zsh () {
    echo -e "#####################\n"
    echo "Iniciando instalação do ZSH "
    echo -e "\n#####################\n"
    sudo apt install zsh -y
    chsh -s /bin/zsh # Command use for set standard shell
    #zsh # enter ZSH shell
    _install_Oh_My_Zsh
}