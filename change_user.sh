#!/bin/bash

# Nome antigo e novo do usuário
OLD_USER="simulation"
NEW_USER="NovoUsuario"

# Verificar e matar processos do usuário
ps -u $OLD_USER | awk '{print $1}' | xargs sudo kill -9

# Forçar logout do usuário
sudo pkill -u $OLD_USER

# Renomear usuário
sudo usermod -l $NEW_USER $OLD_USER

# Renomear diretório home
sudo usermod -d /home/$NEW_USER -m $NEW_USER

# Renomear grupo
sudo groupmod -n $NEW_USER $OLD_USER

# Alterar senha do usuário
echo "$NEW_USER:NovaSenha" | sudo chpasswd
