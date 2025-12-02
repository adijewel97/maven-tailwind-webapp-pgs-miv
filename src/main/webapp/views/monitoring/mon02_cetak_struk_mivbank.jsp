<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!-- 🔹 FORM FILTER -->
<div class="flex justify-center">
    <fieldset class="border border-gray-300 rounded p-5 mt-4 w-full md:w-[760px] mx-auto bg-white shadow text-left">
        <legend class="text-sm font-bold px-3 text-left">Download/Print Struk - Bank MIV</legend>

        <form id="form-monitoring">
            <div class="flex justify-center">
                <div class="grid grid-cols-12 gap-3 mb-2 w-full md:w-[640px]">

                    <!-- Bulan Laporan -->
                    <div class="col-span-12 md:col-span-6">
                        <label for="bln_usulan" class="block text-gray-700 mb-1 font-medium">Bulan Laporan :</label>
                        <div class="flex border border-gray-300 rounded items-center">
                            <input type="text" id="bln_usulan" class="flex-1 px-3 py-2 text-sm uppercase focus:outline-none focus:ring-1 focus:ring-blue-500" placeholder="Pilih Bulan Laporan" readonly>
                            <i id="calendarIcon" class="fa fa-calendar text-gray-500 px-3 cursor-pointer hover:text-blue-600"></i>
                        </div>
                        <input type="hidden" id="bln_usulan_value" name="bln_usulan_value">
                    </div>

                    <!-- Bank MIV -->
                    <div class="col-span-12 md:col-span-6">
                        <label for="bank_miv" class="block text-gray-700 mb-1 font-medium">Bank MIV :</label>
                        <select id="bank_miv" name="bank_miv" class="w-full border border-gray-300 rounded px-3 py-2 text-sm focus:ring-1 focus:ring-blue-500">
                            <option value="">-- Pilih Bank MIV --</option>
                        </select>
                    </div>

                </div>
            </div>

            <div class="flex justify-center">
                <div class="grid grid-cols-12 gap-3 mb-2 w-full md:w-[640px]">

                    <!-- Distribusi -->
                    <div class="col-span-12 md:col-span-6">
                        <label for="diswil" class="block text-gray-700 mb-1 font-medium">Distribusi/Wilayah :</label>
                        <select id="diswil" name="diswil" class="w-full border border-gray-300 rounded px-3 py-2 text-sm focus:ring-1 focus:ring-blue-500">
                            <option value="">-- Pilih Distribusi --</option>
                        </select>
                    </div>

                    <!-- UP3 -->
                    <div class="col-span-12 md:col-span-6">
                        <label for="up3" class="block text-gray-700 mb-1 font-medium">UP3 :</label>
                        <select id="up3" name="up3" class="w-full border border-gray-300 rounded px-3 py-2 text-sm focus:ring-1 focus:ring-blue-500">
                            <option value="">-- Pilih UP3 --</option>
                        </select>
                    </div>

                </div>
            </div>

            <!-- Tombol Tampilkan -->
            <div class="col-span-12 md:col-span-2 mt-4 flex justify-center">
                <button id="btnTampil" type="button" class="max-w-[140px] w-full bg-blue-600 hover:bg-blue-700 text-white font-semibold px-3 py-2 rounded shadow flex items-center justify-center gap-2 transition duration-150 ease-in-out">
                    <i class="fa fa-search"></i> <span>Tampilkan</span>
                </button>
            </div>

        </form>
    </fieldset>
</div>

<!-- Wrapper utama untuk daftar file PDF -->
<div class="flex justify-center">
    <fieldset class="border border-gray-300 rounded p-5 mt-4 w-full md:w-[760px] text-center bg-white shadow">
        <h3 class="text-xl font-semibold mb-4">📂 Daftar File PDF</h3>
        <div id="loading" class="text-blue-600 animate-pulse mb-3">Memuat daftar file dari FTP...</div>
        <div class="flex justify-center">
            <select id="thelist" size="10" class="border border-gray-300 rounded w-full md:w-[720px] p-2" multiple></select>
        </div>
        <div class="flex justify-center mt-4">
            <button id="btnPrint" type="button" class="max-w-[160px] w-full bg-green-600 hover:bg-green-700 text-white font-semibold px-4 py-2 rounded shadow flex items-center justify-center gap-2 transition duration-150 ease-in-out">
                <i class="fa fa-print"></i> <span>Print PDF</span>
            </button>
        </div>
    </fieldset>
</div>

<script>
document.addEventListener("DOMContentLoaded", function() {
    // 0) getContextPath
    function getContextPath() {
        return '<%= request.getContextPath() %>';
    }

    // 1) Load FTP files otomatis
    async function loadFtpFiles() {
        const loading = document.getElementById('loading');
        const list = document.getElementById('thelist');
        try {
            const raw = document.getElementById("bln_usulan").value;
            const thblalp   = convertBulanTahunToYYYYMM(raw);
            const bank_miv  = document.getElementById("bank_miv").value;
            const diswil    = document.getElementById("diswil").value;
            const up3       = document.getElementById("up3").value;

            console.log("thblalp =", thblalp);
            console.log("bank_miv =", bank_miv);
            console.log("diswil =", diswil);
            console.log("up3 =", up3);


            loading.style.display = 'block';
            loading.textContent = "Memuat daftar file dari FTP...";
            list.innerHTML = '';

            // const linkpathfile = '/mon2strukbank/list?thbl='     + thblalp  +
            //                                         '&bankmiv='  + bank_miv +
            //                                         '&upi='      + diswil   +
            //                                         '&up3='       + up3   ;
            const url = getContextPath()
                + "/mon2strukbank?act=list"
                + "&thbl=" + thblalp
                + "&bankmiv=" + bank_miv
                + "&upi=" + diswil
                + "&up3=" + up3;

            const res = await fetch(url);
            // const res = await fetch(getContextPath() + linkpathfile);
            if (!res.ok) throw new Error("Gagal memuat data dari server");

            const files = await res.json();
            loading.style.display = 'none';

            if (!files || files.length === 0) {
                const opt = document.createElement('option');
                opt.textContent = "Tidak ada file di folder FTP.";
                list.appendChild(opt);
                return;
            }

            files.forEach(filePath => {
                const opt = document.createElement('option');
                opt.value = filePath;   // path lengkap FTP
                opt.textContent = filePath.split('/').pop(); // tampilkan hanya nama file
                list.appendChild(opt);
            });

        } catch (err) {
            loading.innerHTML = '<span class="text-red-600">Terjadi kesalahan: ' + err.message + '</span>';
        }
    }

    // 2a) Flatpickr
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
            onChange: function(selectedDates) {
                const date = selectedDates[0];
                if (date) {
                    const yyyy = date.getFullYear();
                    const mm = String(date.getMonth() + 1).padStart(2, '0');
                    blnUsulanValue.value = yyyy + mm;
                }
            },
            onReady: function(selectedDates) {
                const date = selectedDates[0] || new Date();
                const yyyy = date.getFullYear();
                const mm = String(date.getMonth() + 1).padStart(2, '0');
                blnUsulanValue.value = yyyy + mm;
                blnUsulan.value = date.toLocaleString('id-ID', { month: 'long' }) + ' ' + yyyy;
            }
        });

        calendarIcon.addEventListener('click', function() {
            fp.open();
        });
    }

    // 2b) Flatpickr
    function convertBulanTahunToYYYYMM(input) {
        const bulanMap = {
            "Januari": "01", "Februari": "02", "Maret": "03",
            "April": "04", "Mei": "05", "Juni": "06",
            "Juli": "07", "Agustus": "08", "September": "09",
            "Oktober": "10", "November": "11", "Desember": "12"
        };

        const parts = input.split(" ");   // "November 2025" → ["November", "2025"]
        const bulan = bulanMap[parts[0]];
        const tahun = parts[1];

        return tahun + bulan; // "2025" + "11" → "202511"
    }

    // 3) Load Bank MIV
    async function loadBankMIV() {
        console.log("🔄 Memuat daftar bank MIV...");
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
                console.log("✅ Bank MIV berhasil dimuat:", json.data.length, "data");
            } else {
                const opt = document.createElement('option');
                opt.textContent = "Tidak ada data bank";
                select.appendChild(opt);
            }
        } catch (err) {
            console.error("❌ Error JS:", err.message);
        }
    }

    // 4) Load DIS/WIL
    async function loadDisWilMIV() {
        console.log("🔄 Memuat daftar DIS/WIL...");

        const params = new URLSearchParams();
        params.append('act', 'getNamaUnitUPI');
        params.append('kd_dist', 'ALL');

        try {
            const res = await fetch(getContextPath() + '/mst-global', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: params.toString()
            });
            if (!res.ok) throw new Error("HTTP Error " + res.status);
            const json = await res.json();

            const select = document.getElementById('diswil');
            select.innerHTML = '<option value="">-- Pilih DIS/WIL MIV --</option>';

            if (json.status === 'success' && Array.isArray(json.data)) {
                json.data.forEach(diswil => {
                    const opt = document.createElement('option');
                    opt.value = diswil.KD_DIST;
                    opt.textContent = diswil.NAMA_DIST;
                    select.appendChild(opt);
                });
                console.log("✅ DISWIL MIV berhasil dimuat:", json.data.length, "data");

                // Ambil DIS/WIL pertama otomatis
                // const firstKdDist = select.options[1]?.value;
                // if (firstKdDist) {
                //     select.value = firstKdDist;
                //     console.log("Distribusi pertama:", firstKdDist);
                //     loadUP3MIV(firstKdDist);
                // }
            } else {
                const opt = document.createElement('option');
                opt.textContent = "Tidak ada data DISWIL";
                select.appendChild(opt);
            }
        } catch (err) {
            console.error("❌ Error JS:", err.message);
        }
    }

    // 5) Load UP3
    async function loadUP3MIV(kd_dist) {
        console.log("🔄 Memuat daftar UP3 untuk kd_dist:", kd_dist);

        const params = new URLSearchParams();
        params.append('act', 'getNamaArea');
        params.append('kd_dist', kd_dist);

        try {
            const res = await fetch(getContextPath() + '/mst-global', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: params.toString()
            });
            if (!res.ok) throw new Error("HTTP Error " + res.status);

            const text = await res.text();
            if (!text) return;
            const json = JSON.parse(text);

            const select = document.getElementById('up3');
            select.innerHTML = '<option value="">-- Pilih UP3 MIV --</option>';

            if (json.status === 'success' && Array.isArray(json.data)) {
                json.data.forEach(up3 => {
                    const opt = document.createElement('option');
                    opt.value = up3.UNITAP;
                    opt.textContent = up3.NAMA_AREA;
                    select.appendChild(opt);
                });
                console.log("✅ UP3 MIV berhasil dimuat:", json.data.length, "data");
            } else {
                const opt = document.createElement('option');
                opt.textContent = "Tidak ada data UP3";
                select.appendChild(opt);
            }
        } catch (err) {
            console.error("❌ Error JS:", err.message);
        }
    }

    // --- Jalankan otomatis ---
    // loadFtpFiles();
    loadBankMIV();
    loadDisWilMIV();

    // 6)--- Event listener ---
    document.getElementById('diswil').addEventListener('change', function() {
        const kd_dist = this.value;
        console.log("Distribusi terpilih:", kd_dist);
        if (kd_dist) {
            loadUP3MIV(kd_dist);
        } else {
            document.getElementById('up3').innerHTML = '<option value="">-- Pilih UP3 MIV --</option>';
        }
    });

    // 7) tampilkan alert param sebelum neampilkan list struk
    document.getElementById('btnTampil').addEventListener('click', function () {

        const bank_miv = document.getElementById("bank_miv").value;
        if (!bank_miv || bank_miv.trim() === "") {
            alert("⚠ Silakan pilih BANK MIV terlebih dahulu!");
            return; // stop
        }

        const diswil    = document.getElementById("diswil").value;
        if (!diswil || diswil.trim() === "") {
            alert("⚠ Silakan pilih DISTRIBUSI/WILAYAH terlebih dahulu!");
            return; // stop
        }
        
        const up3       = document.getElementById("up3").value;
        if (!up3 || up3.trim() === "") {
            alert("⚠ Silakan pilih PILIH UP3 dahulu!");
            return; // stop
        }

        // lanjut proses jika bank_miv terisi
        loadFtpFiles();
    });

    // 8) === Event tombol PRINT/Download file struk ===
    // === Event tombol PRINT/Download multiple files ===
    document.getElementById("btnPrint").addEventListener("click", function () {
        const list = document.getElementById("thelist");
        const selected = Array.from(list.selectedOptions).map(opt => opt.value);

        if (selected.length === 0) {
            alert("⚠ Silakan pilih minimal 1 file PDF!");
            return;
        }

        selected.forEach((filePath, index) => {
            setTimeout(() => {
                window.open(
                    getContextPath()
                    + "/mon2strukbank?act=download&file="
                    + encodeURIComponent(filePath),
                    "_blank"
                );
            }, index * 500); // beri jeda 0.5 detik per file
        });
    });

});
</script>

