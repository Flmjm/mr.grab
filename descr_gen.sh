#!/usr/bin/env bash
# film_fiche.sh <fichier_video>
VIDEO="$1"
if [ -z "$VIDEO" ]; then
    echo "Usage: $0 <fichier_video>"
    exit 1
fi

# Chemin absolu pour gérer accents et espaces
VIDEO=$(realpath "$VIDEO")

# Nom / année / release standard
FILENAME=$(basename "$VIDEO")
BASENAME="${FILENAME%.*}"
NAME_CLEAN=$(echo "$BASENAME" | iconv -f utf8 -t ascii//TRANSLIT | sed 's/[^A-Za-z0-9 ]//g' | tr ' ' '.')
YEAR=$(echo "$NAME_CLEAN" | grep -oE '[0-9]{4}' | head -1)
[ -z "$YEAR" ] && read -p "Aucune année détectée. Indiquez l'année : " YEAR
LANG="VFF"
SOURCE="WEB"
TAG="MYTAG"
RELEASE_NAME="${NAME_CLEAN}.${YEAR}.${LANG}.${SOURCE}-${TAG}"

# Infos techniques
SIZE=$(mediainfo --Inform="General;%FileSize/String3%" "$VIDEO")
DURATION=$(mediainfo --Inform="General;%Duration/String3%" "$VIDEO")
V_CODEC=$(mediainfo --Inform="Video;%Format%" "$VIDEO")
[ -z "$V_CODEC" ] && V_CODEC="AVC"
V_RES=$(mediainfo --Inform="Video;%Width%x%Height%" "$VIDEO")
[ -z "$V_RES" ] && V_RES="SD"
V_BITRATE=$(mediainfo --Inform="Video;%BitRate/String3%" "$VIDEO")
A_CODEC=$(mediainfo --Inform="Audio;%Format%" "$VIDEO")
[ -z "$A_CODEC" ] && A_CODEC="AAC"
A_CH=$(mediainfo --Inform="Audio;%Channel(s)%" "$VIDEO")
[ -z "$A_CH" ] && A_CH="2"
A_LANG=$(mediainfo --Inform="Audio;%Language%" "$VIDEO")
[ -z "$A_LANG" ] && A_LANG="$LANG"

# Sous-titres (si existants)
SUBS=$(mediainfo --Inform="Text;%Language%" "$VIDEO")
[ -z "$SUBS" ] && SUBS="Aucun"

# Synopsis vide à compléter
SYNOPSIS="À remplir manuellement ou via TMDb/IMDb."

# Génération fiche
NFO_FILE="${VIDEO%.*}_fiche.txt"
{
echo "────────────────────────────── RELEASE INFO ──────────────────────────────"
echo "Nom de la release standard : $RELEASE_NAME"
echo "Poids Total : $SIZE"
echo "Durée : $DURATION"
echo "Source / Release : $SOURCE"
echo
echo "────────────────────────────── VIDEO INFO ───────────────────────────────"
echo "Qualité : $V_RES"
echo "Format : MKV"
echo "Codec Vidéo : $V_CODEC"
echo "Débit Vidéo : $V_BITRATE"
echo
echo "────────────────────────────── AUDIO INFO ───────────────────────────────"
echo "Codec Audio : $A_CODEC"
echo "Langue Audio : $A_LANG"
echo "Channels : $A_CH"
echo
echo "Sous-titres : $SUBS"
echo
echo "────────────────────────────── SYNOPSIS ───────────────────────────────"
echo "$SYNOPSIS"
echo
echo "────────────────────────────── Liens / Notes ─────────────────────────────"
echo "TMDb : https://www.themoviedb.org/"
echo "IMDb : https://www.imdb.com/"
echo "Thumbs : https://ibb.co/"
} > "$NFO_FILE"

echo "Fiche générée : $NFO_FILE"
echo "Nom de release standard : $RELEASE_NAME"

