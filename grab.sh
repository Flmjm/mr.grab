#!/usr/bin/env bash
# grab_hls.sh
# Demande l'URL d'une playlist master .m3u8 puis lance ffmpeg avec User-Agent et Referer.
# Usage: ./grab_hls.sh

set -eu

# Vérifier qu'on a ffmpeg
if ! command -v ffmpeg >/dev/null 2>&1; then
  echo "Erreur : ffmpeg n'est pas installé ou n'est pas dans le PATH." >&2
  exit 1
fi

# Lecture de l'URL
read -r -p "URL du master .m3u8 : " URL
if [ -z "$URL" ]; then
  echo "Aucune URL fournie — sortie." >&2
  exit 1
fi

# Valeurs par défaut (modifie si besoin)
DEFAULT_REFERER="https://darkibox.com/"
DEFAULT_UA="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Safari/537.36"

read -r -p "Referer [appuie Entrée pour utiliser $DEFAULT_REFERER] : " REFERER
REFERER=${REFERER:-$DEFAULT_REFERER}

read -r -p "User-Agent [appuie Entrée pour utiliser l'UA par défaut] : " UA
UA=${UA:-$DEFAULT_UA}

# Nom de sortie (timestamp + extension .mp4). Tu peux changer l'extension si tu veux .mkv, etc.
OUTFILE="$(date +%Y%m%d_%H%M%S).mp4"

echo
echo "URL : $URL"
echo "Referer : $REFERER"
echo "User-Agent : $UA"
echo "Fichier de sortie : $OUTFILE"
echo

# Construire les headers avec les retours chariot \r\n requis par ffmpeg
HEADERS="User-Agent: ${UA}\r\nReferer: ${REFERER}\r\n"

# Lancer ffmpeg
echo "Lancement de ffmpeg..."
ffmpeg -hide_banner -loglevel info -headers "$HEADERS" -i "$URL" -c copy -y "$OUTFILE"

RC=$?
if [ $RC -eq 0 ]; then
  echo "Terminé — $OUTFILE créé."
else
  echo "ffmpeg a échoué avec le code $RC." >&2
fi
