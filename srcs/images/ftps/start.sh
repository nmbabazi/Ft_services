#!/bin/sh

#les user sont répertoriés dans /etc/passwd
adduser -D $USER  #adduser -D : ne met pas de mdp et le dir home est automatiquement crée
echo "$USER:$PASSWORD" | chpasswd #chpasswd modifie le mdp
echo "$USER" >/etc/vsftpd/chroot.list #ajouter à la changre root list pour que l'utilisateur n'ai acces qu'à son propre directory

 /usr/sbin/vsftpd -opasv_min_port=30000 -opasv_max_port=30009 -opasv_address=172.17.0.2 /etc/vsftpd/vsftpd.conf #demarrer avec les bon port et la bonne ip externe