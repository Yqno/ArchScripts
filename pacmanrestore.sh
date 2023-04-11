#!/bin/bash

# Überprüfen, ob das Skript als root ausgeführt wird
if [[ $EUID -ne 0 ]]; then
   echo "Dieses Skript muss als root ausgeführt werden" 
   exit 1
fi

# Erstelle einen Ordner mit dem aktuellen Datum und Uhrzeit
current_time=$(date "+%Y.%m.%d-%H.%M.%S")
folder_name="Pacman-Pakete-$current_time"
mkdir "$folder_name"

# Speichere eine Liste aller installierten Pakete in einer Datei
pacman -Qqe > "$folder_name/alle-pakete.txt"

# Erstelle einen temporären Ordner
temp_folder="temp-pacman-packages"
mkdir "$temp_folder"

# Extrahiere alle installierten Pakete in den temporären Ordner
for package in $(cat "$folder_name/alle-pakete.txt"); do
  pacman -Qlq "$package" | while read -r file; do
    cp --parents "$file" "$temp_folder/"
  done
done

# Packe den temporären Ordner in eine Tar-Datei und speichere sie im erstellten Ordner
tar -czvf "$folder_name/pacman-packages.tar.gz" "$temp_folder"

# Lösche den temporären Ordner
rm -rf "$temp_folder"

echo "Die Pacman-Pakete wurden erfolgreich wiederhergestellt und im Ordner '$folder_name' gespeichert."
