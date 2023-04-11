#!/bin/bash

# Überprüfe, ob das Skript als root ausgeführt wird
if [[ $EUID -ne 0 ]]; then
   echo "Dieses Skript muss als root ausgeführt werden" 
   exit 1
fi

# Sicherstellen, dass das System auf dem neuesten Stand ist
pacman -Syu --noconfirm

# Entferne alle Pakete, die nicht im Base-System enthalten sind
pacman -Qne | pacman -Rs --noconfirm -

# Entferne alle Pakete, die nicht für das Base-System notwendig sind
pacman -Qdt | pacman -Rs --noconfirm -

# Entferne alle heruntergeladenen Paket-Dateien
pacman -Sc --noconfirm

# Entferne alle temporären Dateien
rm -rf /tmp/*

# Setze den Boot-Loader auf das Standard-System zurück
bootctl --path=/boot install

# Entferne alle benutzerdefinierten Konfigurationsdateien
find /etc -name '*.pacnew' -delete

# Setze den Computer zurück und starte ihn neu
echo "Das System wird jetzt zurückgesetzt und neu gestartet"
sleep 5
systemctl reboot
