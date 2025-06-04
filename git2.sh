#!/bin/bash
set +H  # Nonaktifkan history expansion
clear

# Cek apakah direktori ini adalah repository git
if [ ! -d ".git" ]; then
    echo "Direktori ini belum diinisialisasi sebagai repository Git."
    read -p "Masukkan URL Git repository untuk di-clone: " repo_url

    # Cek URL kosong atau tidak
    if [ -z "$repo_url" ]; then
        echo "URL tidak boleh kosong. Keluar..."
        exit 1
    fi

    echo "Meng-clone repository..."
    git clone "$repo_url" .

    if [ $? -ne 0 ]; then
        echo "Gagal meng-clone repository. Periksa URL dan koneksi Anda."
        exit 1
    fi

    echo "Clone berhasil!"
fi

pilih_branch() {
    echo "==== Daftar Branch Lokal ===="
    git branch
    echo "============================="
    echo
    read -p "Ketik nama branch: " branch
    cek_branch
}

cek_branch() {
    if git show-ref --verify --quiet "refs/heads/$branch"; then
        echo
        echo "Branch \"$branch\" ditemukan, melakukan checkout..."
        git checkout "$branch"
    else
        echo
        echo "Branch \"$branch\" TIDAK ditemukan."
        echo "Pilihan:"
        echo "[1] Input ulang"
        echo "[2] Buat branch baru dengan nama \"$branch\""
        read -p "Pilihan Anda [1/2]: " pilihan
        case "$pilihan" in
            1) pilih_branch ;;
            2) git checkout -b "$branch" ;;
            *) echo "Pilihan tidak valid. Kembali ke input branch..."; pilih_branch ;;
        esac
    fi

    lanjutan
}

lanjutan() {
    echo
    echo "=== Apa yang ingin Anda lakukan? ==="
    echo "[1] Git Pull"
    echo "[2] Git Commit dan Push"
    echo "[3] Lewati"
    read -p "Pilihan Anda [1/2/3]: " aksi

    case "$aksi" in
        1) alert_pull ;;
        2)
            read -p "Masukkan pesan commit: " msg
            git add .
            git commit -m "$msg"
            git push origin "$branch"
            ;;
        3)
            echo "Tidak ada aksi lanjutan yang dipilih."
            ;;
        *)
            echo "Pilihan tidak valid. Silakan ulangi."
            lanjutan
            ;;
    esac

    read -n 1 -s -r -p "Tekan tombol apa saja untuk keluar..."
    echo
}

alert_pull() {
    echo
    echo "!!! PERINGATAN !!!"
    echo "Anda akan melakukan git pull, yang akan mengambil perubahan dari repository remote (GitHub)"
    echo "dan menimpa perubahan di lokal Anda."
    echo
    echo "[1] Lanjutkan"
    echo "[2] Kembali"
    read -p "Pilihan Anda [1/2]: " konfirmasi

    case "$konfirmasi" in
        1)
            echo "Melakukan git pull..."
            git reset --hard origin/main
            echo "Selesai. Happy coding!"
            ;;
        2)
            echo "Kembali ke menu sebelumnya..."
            ;;
        *)
            echo "Pilihan tidak valid. Kembali ke menu sebelumnya..."
            ;;
    esac

    lanjutan
}

pilih_branch
