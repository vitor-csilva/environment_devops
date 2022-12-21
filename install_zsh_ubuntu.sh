#!/bin/bash

# att repositories
sudo apt-get update -y

# install necessary packages/apps
sudo apt-get install git curl wget sed -y

# install ZSH shell
VAR_SHELL=$(echo $SHELL) 
if [ "$VAR_SHELL" == "/bin/zsh" ]; then
    echo "#####################\n"
    echo "ZSH já instalado e definido como padrao !!"
    echo "#####################\n"
    
    echo "### Iniciando Configuracao e instalação do Oh-My-Zsh ###\n"
    #sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -P /tmp
    sed -i 's/exec zsh -l/#exec zsh -l/g' /tmp/install.sh
    sh /tmp/install.sh

    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions)/g' ~/.zshrc
    echo "########################################### \n"
    echo "Instalação concluída, REINICIAR A MÁQUINA"
    echo "\n#########################################"
else
    echo "### Instalacao Zsh shell em andamento... ###"
    zsh --version || sudo apt install zsh -y
    chsh -s /bin/zsh # Command use for set standard shell
    #zsh # enter ZSH shell

    echo "### Iniciando Configuracao e instalação do Oh-My-Zsh ###\n"
    #sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" -y
    wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -P /tmp
    sed -i 's/exec zsh -l/#exec zsh -l/g' /tmp/install.sh
    sh /tmp/install.sh

    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions)/g' ~/.zshrc
    echo "########################################### \n"
    echo "Instalação concluída, REINICIAR A MÁQUINA"
    echo "\n#########################################"
fi








