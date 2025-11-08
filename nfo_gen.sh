#!/usr/bin/env bash
# nfo_single_auto_full.sh
# Génère un NFO + nom de release standard pour un seul fichier vidéo
# Année et source détectées automatiquement

VIDEO="$1"
if [ -z "$VIDEO" ]; then
    echo "Usage: $0 <fichier_video>"
    exit 1
fi

# Dépendances
for cmd in mediainfo figlet; do
    if ! command -v $cmd >/dev/null 2>&1; then
        echo "$cmd n'est pas installé. Installez-le (sudo apt install $cmd)"
        exit 1
    fi
done

# Paramètres
TAG="MYTAG"
DEFAULT_LANG="VFF"
DEFAULT_SOURCE="WEB"

# Nom de fichier et nettoyage
FILENAME=$(basename "$VIDEO")
BASENAME="${FILENAME%.*}"
NAME_CLEAN=$(echo "$BASENAME" | iconv -f utf8 -t ascii//TRANSLIT | sed 's/[^A-Za-z0-9 ]//g' | tr ' ' '.')

# Détection année
YEAR=$(echo "$NAME_CLEAN" | grep -oE '[0-9]{4}' | head -1)
if [ -z "$YEAR" ]; then
    read -p "Aucune année détectée dans le nom du fichier. Indiquez l'année de sortie : " YEAR
fi

# Détection source
UPPERNAME=$(echo "$NAME_CLEAN" | tr '[:lower:]' '[:upper:]')
if [[ "$UPPERNAME" =~ WEB ]]; then
    SOURCE="WEB"
elif [[ "$UPPERNAME" =~ BLURAY|BDRIP ]]; then
    SOURCE="BLURAY"
elif [[ "$UPPERNAME" =~ DVD|DVDRIP ]]; then
    SOURCE="DVD"
elif [[ "$UPPERNAME" =~ HDTV ]]; then
    SOURCE="HDTV"
else
    SOURCE="$DEFAULT_SOURCE"
fi

# Infos techniques avec valeurs par défaut
V_CODEC=$(mediainfo --Inform="Video;%Format%" "$VIDEO")
[ -z "$V_CODEC" ] && V_CODEC="AVC"

V_WIDTH=$(mediainfo --Inform="Video;%Width%" "$VIDEO")
[ -z "$V_WIDTH" ] && V_WIDTH=0

V_HEIGHT=$(mediainfo --Inform="Video;%Height%" "$VIDEO")
[ -z "$V_HEIGHT" ] && V_HEIGHT=0

V_FR=$(mediainfo --Inform="Video;%FrameRate%" "$VIDEO")
[ -z "$V_FR" ] && V_FR="23.976"

A_CODEC=$(mediainfo --Inform="Audio;%Format%" "$VIDEO")
[ -z "$A_CODEC" ] && A_CODEC="AAC"

A_CH=$(mediainfo --Inform="Audio;%Channel(s)%" "$VIDEO")
[ -z "$A_CH" ] && A_CH="2"

A_LANG=$(mediainfo --Inform="Audio;%Language%" "$VIDEO")
[ -z "$A_LANG" ] && A_LANG="$DEFAULT_LANG"

# Définition selon la résolution
if [ "$V_HEIGHT" -ge 1080 ] 2>/dev/null; then
    DEFINITION="1080p"
elif [ "$V_HEIGHT" -ge 720 ] 2>/dev/null; then
    DEFINITION="720p"
else
    DEFINITION="SD"
fi

# Nom release standard
RELEASE_NAME="${NAME_CLEAN}.${YEAR}.${A_LANG}.${DEFINITION}.${SOURCE}.${V_CODEC}-${TAG}"

# Nom du NFO
NFO_FILE="${VIDEO%.*}.nfo"

# Génération NFO
{
figlet -c "$RELEASE_NAME"
echo
echo "────────────────────────────── RELEASE INFO ──────────────────────────────"
echo "Nom de la release standard : $RELEASE_NAME"
echo "File Size        : $(mediainfo --Inform="General;%FileSize/String3%" "$VIDEO")"
echo "Duration         : $(mediainfo --Inform="General;%Duration/String3%" "$VIDEO")"
echo "Format           : $(mediainfo --Inform="General;%Format%" "$VIDEO")"
echo
echo "────────────────────────────── VIDEO INFO ───────────────────────────────"
echo "Codec            : $V_CODEC"
echo "Resolution       : ${V_WIDTH}x${V_HEIGHT}"
echo "Framerate        : $V_FR FPS"
echo
echo "────────────────────────────── AUDIO INFO ───────────────────────────────"
echo "Codec            : $A_CODEC"
echo "Channels         : $A_CH"
echo "Language         : $A_LANG"
echo
echo "────────────────────────────── LINKS / NOTE ──────────────────────────────"
echo "SOURCE      : $SOURCE (détectée automatiquement)"
echo "TMDB        : https://www.themoviedb.org/"
echo "IMDb        : https://www.imdb.com/"
echo "Thumbs      : https://ibb.co/"
echo
echo "────────────────────────────── KEEP MOVING FORWARD ───────────────────────"
} > "$NFO_FILE"

echo "NFO généré : $NFO_FILE"
echo "Nom de release standard appliqué : $RELEASE_NAME"

