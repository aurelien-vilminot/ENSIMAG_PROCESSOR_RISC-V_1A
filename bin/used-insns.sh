#! /bin/bash
# $1: path to executable from which extracting the used instructions is required
command -v riscv32-unknown-elf-objdump >/dev/null 2>&1 || { echo >&2 "Ajoutez le chemin d'accès aux executables risc-v dans votre PATH svp !"; exit 1; }
if test -z $1; then
   echo "Nom de fichier executable risc-v requis comme argument de $0"
elif test ! -e $1; then
   echo 'Ficher "'$1'" introuvable !'
   exit 1
else
   riscv32-unknown-elf-objdump --disassembler-options=no-aliases,numeric --disassemble $1 | awk '/^ *[0-9a-f]+:/{print $3}' | grep -v '^$' | sort -u | paste -sd' '
fi
