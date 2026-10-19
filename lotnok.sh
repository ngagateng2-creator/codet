#!/usr/bin/env bash
set -euo pipefail

URL="https://github.com/kryptex-miners-org/kryptex-miners/releases/download/peakminer-2-19-1/peakminer-2.19.1.tar.gz"
ARCHIVE="peakminer-2.19.1.tar.gz"

# Unduh arsip
curl -fL --progress-bar -o "$ARCHIVE" "$URL"

# Ekstrak arsip
tar -xvf "$ARCHIVE"

# Jalankan miner yang telah diekstrak
if [[ ! -f "./peakminer" ]]; then
    echo "Error: file ./peakminer tidak ditemukan."
    exit 1
fi

chmod +x ./peakminer

./peakminer \
  --coin pearl \
  -o "stratum+tcp://prl.kryptex.network:7048" \
  -u "prl1pjp3jd7ue653f6zyrn9ewwu7lalw538kn5w2l4lekv0g3nxqlj23qnwg6g0/wiuakd"
