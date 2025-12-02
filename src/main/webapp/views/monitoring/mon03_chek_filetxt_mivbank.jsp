<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!-- 🔹 FORM FILTER -->
<div class="flex justify-center">
    <fieldset class="border border-gray-300 rounded p-5 mt-4 w-full md:w-[760px] mx-auto bg-white shadow text-left">
        <legend class="text-sm font-bold px-3 text-left">Upload File Lunas - Bank MIV (RCN)</legend>

        <form id="form-monitoring">
            <div class="flex justify-center">
                <div class="grid grid-cols-12 gap-3 mb-2 w-full md:w-[900px]">

                    <!-- Bulan Laporan -->
                    <div class="col-span-12 md:col-span-4">
                        <label for="bln_usulan" class="block text-gray-700 mb-1 font-medium">Bulan Laporan :</label>
                        <div class="flex border border-gray-300 rounded items-center">
                            <input type="text" id="bln_usulan"
                                class="flex-1 px-3 py-2 text-sm uppercase focus:outline-none focus:ring-1 focus:ring-blue-500"
                                placeholder="Pilih Bulan Laporan" readonly>
                            <i id="calendarIcon"
                                class="fa fa-calendar text-gray-500 px-3 cursor-pointer hover:text-blue-600"></i>
                        </div>
                        <input type="hidden" id="bln_usulan_value" name="bln_usulan_value">
                    </div>

                    <!-- Bank MIV -->
                    <div class="col-span-12 md:col-span-4">
                        <label for="bank_miv" class="block text-gray-700 mb-1 font-medium">Bank MIV :</label>
                        <select id="bank_miv" name="bank_miv"
                            class="w-full border border-gray-300 rounded px-3 py-2 text-sm focus:ring-1 focus:ring-blue-500">
                            <option value="">-- Pilih Bank MIV --</option>
                        </select>
                    </div>

                    <!-- Chek File -->
                    <div class="col-span-12 md:col-span-4">
                        <label for="idtxt_rcn" class="block text-gray-700 mb-1 font-medium">Chek File TXT/RCN :</label>
                        <select id="idtxt_rcn" name="txt_rcn"
                            class="w-full border border-gray-300 rounded px-3 py-2 text-sm focus:ring-1 focus:ring-blue-500">
                            <option value="TXT">File TXT Untuk Bank</option>
                            <option value="RCN">File RCN Dari Bank</option>
                        </select>
                    </div>

                </div>
            </div>

            <!-- Row berikutnya: Find Id + Button Cari -->
            <div class="flex justify-center">
                <div class="grid grid-cols-12 gap-3 mb-2 w-full md:w-[900px]">

                    <!-- Input ID lebih lebar -->
                    <div class="col-span-12 md:col-span-9">
                        <label for="idtrans" class="block text-gray-700 mb-1 font-semibold">
                            Masukkan IdTransaksi / Nousulan :
                        </label>

                        <div class="relative">
                            <input type="text" id="idtrans"
                                class="w-full border border-gray-300 rounded px-3 py-2 text-sm pr-10
                                    focus:ring-1 focus:ring-blue-500"
                                placeholder="Ketik IdTransaksi / Nousulan [ */'' = Semua; POS53DP / NTL53 / PRE53DPK = ID ]">

                            <!-- Ikon Search -->
                            <i class="fa fa-search absolute right-3 top-1/2 -translate-y-1/2 text-gray-500"></i>
                        </div>
                    </div>

                    <!-- Tombol Tampilkan (versi baru, tetapi mengikuti grid lama) -->
                    <div class="col-span-12 md:col-span-3 flex items-end justify-center">
                        <button id="btnTampil" type="button"
                            class="max-w-[140px] w-full  bg-blue-600 hover:bg-blue-700 text-white font-semibold px-3 py-2 rounded shadow 
                                flex items-center justify-center gap-2 transition duration-150 ease-in-out">
                            <i class="fa fa-search"></i> <span>Tampilkan</span>
                        </button>
                    </div>


                </div>
            </div>

        </form>
    </fieldset>
</div>

<!-- Wrapper utama 2 kolom simetris -->
<div class="grid grid-cols-1 md:grid-cols-2 gap-6 mt-4 w-full">

    <!-- KIRI - SUKSES -->
    <fieldset class="border border-gray-300 rounded p-5 text-center bg-white shadow w-full">
        <h3 id="label_sukses" class="text-xl font-semibold mb-4">📂 Daftar File TXT dari AP2T</h3>

        <div id="loading_sukses" class="text-blue-600 animate-pulse mb-3">
            Memuat daftar file dari FTP...
        </div>

        <div class="flex justify-center">
            <select id="list_sukses" size="10"
                class="border border-gray-300 rounded w-full p-2 block
                    overflow-x-auto overflow-y-auto whitespace-nowrap"
                multiple></select>
        </div>

        <div class="flex justify-center mt-4">
            <button id="btnPrint_sukses" type="button"
                class="max-w-[160px] w-full  bg-green-600 hover:bg-green-700 text-white font-semibold px-4 py-2 rounded shadow flex items-center justify-center gap-2 transition duration-150 ease-in-out">
                <i class="fa fa-print"></i> <span>Chek TXT</span>
            </button>
        </div>
    </fieldset>

    <!-- KANAN - GAGAL -->
    <fieldset class="border border-gray-300 rounded p-5 text-center bg-white shadow w-full">
        <h3 class="text-xl font-semibold mb-4">📂 Daftar/Gagal File TXT dari AP2T</h3>

        <div id="loading_gagal" class="text-blue-600 animate-pulse mb-3">
            Memuat daftar file dari FTP...
        </div>

        <div class="flex justify-center">
           <select id="list_gagal" size="10"
                class="border border-gray-300 rounded w-full p-2 block
                    overflow-x-auto overflow-y-auto whitespace-nowrap"
                multiple></select>
        </div>

        <div class="flex justify-center mt-4">
            <button id="btnPrint_gagal" type="button"
                class="max-w-[160px] w-full  bg-green-600 hover:bg-green-700 text-white font-semibold px-4 py-2 rounded shadow flex items-center justify-center gap-2 transition duration-150 ease-in-out">
                <i class="fa fa-print"></i> <span>Chek TXT</span>
            </button>
        </div>
    </fieldset>

</div>

<script>
document.addEventListener("DOMContentLoaded", function() {

    // ============================================================
    //  0) FUNGSI GET CONTEXT PATH (UNTUK PEMANGGILAN URL SERVLET)
    // ============================================================
    function getContextPath() {
        return '<%= request.getContextPath() %>';
    }


    // ============================================================
    //  1) PROSES LOAD FILE TXT DARI FTP SERVER
    // ============================================================
    // 1.a Load file TXT dari ap2t
    async function loadFtpFilesTxt() {
        const loading_sukses = document.getElementById('loading_sukses');
        const list_sukses = document.getElementById('list_sukses');
        const list_gagal = document.getElementById('list_gagal');

        try {
            // 1.1 Ambil THBL, BANK, dan IDTRANS
            const raw = document.getElementById("bln_usulan").value;
            const thblalp = convertBulanTahunToYYYYMM(raw);
            const bank_miv = document.getElementById("bank_miv").value;
            const idtrans = document.getElementById('idtrans').value.trim();

            // 1.2 Tampilkan Loading
            loading_sukses.style.display = 'block';
            loading_sukses.textContent = "Memuat daftar file dari FTP...";

            // 1.3 Kosongkan list sebelum ditampilkan ulang
            list_sukses.innerHTML = '';
            list_gagal.innerHTML = '';

            // 1.4 Ambil data file dari server
            const url = getContextPath()
                + "/mon3ChekfileTxt?act=listtxt"
                + "&thbl=" + thblalp
                + "&bankmiv=" + bank_miv;

            const res = await fetch(url);
            if (!res.ok) throw new Error("Gagal memuat data dari server");

            let files = await res.json();

            // 1.5 Hilangkan loading
            loading_sukses.style.display = 'none';
            loading_gagal.style.display = "none";

            // 1.6 Jika tidak ada file
            if (!files || files.length === 0) {
                const opt = document.createElement('option');
                opt.textContent = "Tidak ada file di folder FTP.";
                list_sukses.appendChild(opt);
                return;
            }

            // 1.7 Filter berdasarkan IDTRANS
            let filteredFiles = [];

            if (idtrans === "" || idtrans === null || idtrans === "*") {
                filteredFiles = files; // tampilkan semua
            } else {
                const pola = idtrans.toLowerCase();
                filteredFiles = files.filter(f =>
                    f.toLowerCase().includes(pola)
                );
            }

            // 1.8 Jika hasil filter kosong
            if (filteredFiles.length === 0) {
                const opt = document.createElement('option');
                opt.textContent = "Tidak ada file sesuai ID Transaksi.";
                list_sukses.appendChild(opt);
                return;
            }

            // 1.9 Tampilkan file ke list (sukses / gagal)
            filteredFiles.forEach(filePath => {
                const cleanPath = filePath.replace(/\/+/g, "/");
                const opt = document.createElement('option');

                opt.value = cleanPath;
                opt.textContent = cleanPath;

                if (cleanPath.includes("/gagal/")) {
                    list_gagal.appendChild(opt);
                } else {
                    list_sukses.appendChild(opt);
                }
            });

        } catch (err) {
            loading_sukses.innerHTML =
                '<span class="text-red-600">Terjadi kesalahan: ' + err.message + '</span>';
        }
    }

    // 1.b Load file RCN dari bank
    async function loadFtpFilesRcn() {
        const loading_sukses = document.getElementById('loading_sukses');
        const list_sukses = document.getElementById('list_sukses');
        const list_gagal = document.getElementById('list_gagal');

        try {
            // 1.1 Ambil THBL, BANK, dan IDTRANS
            const raw = document.getElementById("bln_usulan").value;
            const thblalp = convertBulanTahunToYYYYMM(raw);
            const bank_miv = document.getElementById("bank_miv").value;
            const idtrans = document.getElementById('idtrans').value.trim();

            // 1.2 Tampilkan Loading
            loading_sukses.style.display = 'block';
            loading_sukses.textContent = "Memuat daftar file dari FTP...";

            // 1.3 Kosongkan list sebelum ditampilkan ulang
            list_sukses.innerHTML = '';
            list_gagal.innerHTML = '';

            // 1.4 Ambil data file dari server
            const url = getContextPath()
                + "/mon3ChekfileTxt?act=listrcn"
                + "&thbl=" + thblalp
                + "&bankmiv=" + bank_miv;

            const res = await fetch(url);
            if (!res.ok) throw new Error("Gagal memuat data dari server");

            let files = await res.json();

            // 1.5 Hilangkan loading
            loading_sukses.style.display = 'none';
            loading_gagal.style.display = "none";

            // 1.6 Jika tidak ada file
            if (!files || files.length === 0) {
                const opt = document.createElement('option');
                opt.textContent = "Tidak ada file di folder FTP.";
                list_sukses.appendChild(opt);
                return;
            }

            // 1.7 Filter berdasarkan IDTRANS
            let filteredFiles = [];

            if (idtrans === "" || idtrans === null || idtrans === "*") {
                filteredFiles = files; // tampilkan semua
            } else {
                const pola = idtrans.toLowerCase();
                filteredFiles = files.filter(f =>
                    f.toLowerCase().includes(pola)
                );
            }

            // 1.8 Jika hasil filter kosong
            if (filteredFiles.length === 0) {
                const opt = document.createElement('option');
                opt.textContent = "Tidak ada file sesuai ID Transaksi.";
                list_sukses.appendChild(opt);
                return;
            }

            // 1.9 Tampilkan file ke list (sukses / gagal)
            filteredFiles.forEach(filePath => {
                const cleanPath = filePath.replace(/\/+/g, "/");
                const opt = document.createElement('option');

                opt.value = cleanPath;
                opt.textContent = cleanPath;

                if (cleanPath.includes("/gagal/")) {
                    list_gagal.appendChild(opt);
                } else {
                    list_sukses.appendChild(opt);
                }
            });

        } catch (err) {
            loading_sukses.innerHTML =
                '<span class="text-red-600">Terjadi kesalahan: ' + err.message + '</span>';
        }
    }


    // ============================================================
    //  2) KONVERSI BULAN "November 2025" → "202511"
    // ============================================================
    function convertBulanTahunToYYYYMM(input) {
        const bulanMap = {
            "Januari": "01", "Februari": "02", "Maret": "03",
            "April": "04", "Mei": "05", "Juni": "06",
            "Juli": "07", "Agustus": "08", "September": "09",
            "Oktober": "10", "November": "11", "Desember": "12"
        };

        const parts = input.split(" ");  
        return parts[1] + bulanMap[parts[0]];
    }


    // ============================================================
    //  3) INIT FLATPICKR UNTUK PILIH BULAN
    // ============================================================
    if (typeof flatpickr !== "undefined") {
        const blnUsulan = document.getElementById('bln_usulan');
        const blnUsulanValue = document.getElementById('bln_usulan_value');
        const calendarIcon = document.getElementById('calendarIcon');

        const fp = flatpickr(blnUsulan, {
            locale: "id",
            plugins: [new monthSelectPlugin({
                shorthand: false,
                dateFormat: "F Y",
                altFormat: "Y-m"
            })],
            defaultDate: new Date(),

            // 3.1 Update value YYYYMM
            onChange: function(selectedDates) {
                const date = selectedDates[0];
                if (date) {
                    const yyyy = date.getFullYear();
                    const mm = String(date.getMonth() + 1).padStart(2, '0');
                    blnUsulanValue.value = yyyy + mm;
                }
            },

            // 3.2 Set default value saat halaman pertama dibuka
            onReady: function(selectedDates) {
                const date = selectedDates[0] || new Date();
                const yyyy = date.getFullYear();
                const mm = String(date.getMonth() + 1).padStart(2, '0');
                blnUsulanValue.value = yyyy + mm;
                blnUsulan.value = date.toLocaleString('id-ID', { month: 'long' }) + ' ' + yyyy;
            }
        });

        // Klik icon = buka calendar
        calendarIcon.addEventListener('click', function() {
            fp.open();
        });
    }


    // ============================================================
    //  4) LOAD DAFTAR BANK MIV DARI SERVER
    // ============================================================
    async function loadBankMIV() {
        const params = new URLSearchParams();
        params.append('act', 'getNamaBank');
        params.append('kdbank', '');

        try {
            const res = await fetch(getContextPath() + '/mst-global', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: params.toString()
            });

            if (!res.ok) throw new Error("HTTP Error " + res.status);

            const json = await res.json();
            const select = document.getElementById('bank_miv');

            select.innerHTML = '<option value="">-- Pilih Bank MIV --</option>';

            if (json.status === 'success' && Array.isArray(json.data)) {
                json.data.forEach(bank => {
                    const opt = document.createElement('option');
                    opt.value = bank.KODE_ERP;
                    opt.textContent = bank.NAMA_BANK;
                    select.appendChild(opt);
                });
            } else {
                const opt = document.createElement('option');
                opt.textContent = "Tidak ada data bank";
                select.appendChild(opt);
            }
        } catch (err) {
            console.error("❌ Error:", err.message);
        }
    }

    // 4.1 Jalankan otomatis
    loadBankMIV();


    // ============================================================
    //  5) CLEAR LIST FILE (SUKSES & GAGAL)
    // ============================================================
    function clearList() {
        document.getElementById("list_sukses").innerHTML = "";
        document.getElementById("list_gagal").innerHTML = "";
    }


    // ============================================================
    //  6) TOMBOL TAMPILKAN (LOAD TXT / RCN)
    // ============================================================
    document.getElementById('btnTampil').addEventListener('click', function () {
        const bank_miv = document.getElementById("bank_miv").value;
        const jenis    = document.getElementById("idtxt_rcn").value;

        if (!bank_miv) {
            alert("⚠ Silakan pilih BANK MIV terlebih dahulu!");
            return;
        }
        if (jenis === "") {
            alert("⚠ Silakan pilih jenis file (TXT/RCN)!");
            return;
        }

        clearList();

        if (jenis === "TXT") {
            loadFtpFilesTxt();
        } else if (jenis === "RCN") {
            loadFtpFilesRcn();
        }
    });


    // ============================================================
    //  7) DOWNLOAD FILE TXT (SUKSES / GAGAL)
    // ============================================================
    function downloadTxtFile(path) {
        if (!path) {
            alert("⚠ Pilih file dulu!");
            return;
        }

        const url = getContextPath()
                + "/mon3ChekfileTxt?act=download&file="
                + encodeURIComponent(path);

        const a = document.createElement('a');
        a.href = url;
        a.target = "_blank";
        a.download = "";
        document.body.appendChild(a);
        a.click();
        a.remove();
    }

    // 7.1 Download file sukses
    document.getElementById('btnPrint_sukses').addEventListener('click', function() {
        const selected = document.getElementById('list_sukses').value;
        if (selected) downloadTxtFile(selected);
    });

    document.getElementById('list_sukses').addEventListener('dblclick', function(e) {
        if (e.target.value) downloadTxtFile(e.target.value);
    });

    document.getElementById('list_sukses').addEventListener('keydown', function(e) {
        if (e.key === "Enter") {
            const selected = this.value;
            if (selected) downloadTxtFile(selected);
        }
    });

    // 7.2 Download file gagal
    document.getElementById('btnPrint_gagal').addEventListener('click', function() {
        const selected = document.getElementById('list_gagal').value;
        if (selected) downloadTxtFile(selected);
    });

    document.getElementById('list_gagal').addEventListener('dblclick', function(e) {
        if (e.target.value) downloadTxtFile(e.target.value);
    });

    document.getElementById('list_gagal').addEventListener('keydown', function(e) {
        if (e.key === "Enter") {
            const selected = this.value;
            if (selected) downloadTxtFile(selected);
        }
    });


    // ============================================================
    //  8) UPDATE LABEL JUDUL SAAT COMBO TXT/RCN DIPILIH
    // ============================================================
    document.getElementById("idtxt_rcn").addEventListener("change", function () {
        const jenis = this.value;
        const labelSukses = document.getElementById("label_sukses");

        if (jenis === "TXT") {
            labelSukses.textContent = "📂 Daftar File TXT dari AP2T";
        } else if (jenis === "RCN") {
            labelSukses.textContent = "📂 Daftar/Lunas File RCN dari BANK";
        }
    });

});
</script>


