#!/bin/bash

# att repositories
sudo apt-get update -y

# install necessary packages/apps
sudo apt-get install git curl wget sed -y

# install ZSH shell, Oh-My-Zsh and Zsh-autosuggestions
VAR_SHELL=$(echo ${SHELL##*/})
if [ "$VAR_SHELL" == "zsh" ]; then
    echo -e "#####################\n"
    echo "ZSH já instalado e definido como padrao !!"
    echo -e "\n#####################\n"
    
    echo -e "### Iniciando Configuracao e instalação do Oh-My-Zsh ###\n"
    #sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -P /tmp
    sed -i 's/exec zsh -l/#exec zsh -l/g' /tmp/install.sh
    sh /tmp/install.sh

    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions)/g' ~/.zshrc
    echo -e "\n###########################################\n"
    echo "Instalação concluída, REINICIAR A MÁQUINA"
    echo -e "#########################################\n"
else
    echo -e "\n### Instalacao Zsh shell em andamento... ###\n"
    zsh --version || sudo apt install zsh -y
    chsh -s /bin/zsh # Command use for set standard shell
    #zsh # enter ZSH shell

    echo -e "\n### Iniciando Configuracao e instalação do Oh-My-Zsh ###\n"
    #sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" -y
    wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -P /tmp
    sed -i 's/exec zsh -l/#exec zsh -l/g' /tmp/install.sh
    sh /tmp/install.sh -y

    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions)/g' ~/.zshrc
    echo -e "\n###########################################\n"
    echo "Instalação concluída, REINICIAR A MÁQUINA"
    echo -e "\n#########################################\n"
fi