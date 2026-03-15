#!/bin/bash
# Toldya – Firebase Functions deploy
# Önce: firebase login (tarayıcıda casycorporate@gmail.com ile giriş yapın)
set -e
cd "$(dirname "$0")"
echo "Proje: casy-570c4"
npx --yes firebase-tools use casy-570c4
echo "Functions deploy ediliyor..."
npx --yes firebase-tools deploy --only functions
echo "Bitti."
