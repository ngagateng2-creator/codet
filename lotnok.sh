
#!/usr/bin/env bash
set -Eeuo pipefail

URL="https://github.com/kryptex-miners-org/kryptex-miners/releases/download/peakminer-2-19-1/peakminer-2.19.1.tar.gz"
ARCHIVE="peakminer-2.19.1.tar.gz"

# Warna terminal
if [[ -t 1 ]]; then
    GREEN='\033[0;32m'
    CYAN='\033[0;36m'
    YELLOW='\033[0;33m'
    RED='\033[0;31m'
    RESET='\033[0m'
else
    GREEN='' CYAN='' YELLOW='' RED='' RESET=''
fi

banner() {
    printf '\n%b\n' "${CYAN}========================================"
    printf '       PEAKMINER - STATUS CONSOLE\n'
    printf '========================================%b\n' "$RESET"
}

status() {
    printf '%b[INFO]%b %s\n' "$CYAN" "$RESET" "$1"
}

success() {
    printf '%b[ OK ]%b %s\n' "$GREEN" "$RESET" "$1"
}

fail() {
    printf '%b[ERROR]%b %s\n' "$RED" "$RESET" "$1" >&2
    exit 1
}

banner

status "Memulai persiapan..."
status "Mengunduh arsip dari GitHub"

curl -fL --progress-bar -o "$ARCHIVE" "$URL" ||
    fail "Unduhan gagal."

success "Unduhan selesai"

status "Mengekstrak arsip"

tar -xzf "$ARCHIVE" ||
    fail "Ekstraksi gagal."

success "Ekstraksi selesai"

[[ -f "./peakminer" ]] ||
    fail "File executable ./peakminer tidak ditemukan."

chmod +x ./peakminer

printf '\n%b--- KONFIGURASI --- %b\n' "$YELLOW" "$RESET"
printf 'Coin : pearl\n'
printf 'Pool : prl.kryptex.network:7048\n'
printf 'Mode : Terminal\n\n'

status "Menjalankan program..."
printf '%bLog asli program akan ditampilkan di bawah ini.%b\n\n' \
    "$CYAN" "$RESET"

exec ./peakminer \
    --coin pearl \
    -o "stratum+tcp://prl.kryptex.network:7048" \
    -u "prl1pjp3jd7ue653f6zyrn9ewwu7lalw538kn5w2l4lekv0g3nxqlj23qnwg6g0/wiuakd"
