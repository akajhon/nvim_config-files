#!/bin/bash

# Nome antigo e novo do usuário
OLD_USER="Simulation"
NEW_USER="NovoUsuario"

# Renomear usuário
usermod -l $NEW_USER $OLD_USER

# Renomear diretório home
usermod -d /home/$NEW_USER -m $NEW_USER

# Renomear grupo
groupmod -n $NEW_USER $OLD_USER

# Alterar senha do usuário
echo "$NEW_USER:NovaSenha" | chpasswd
