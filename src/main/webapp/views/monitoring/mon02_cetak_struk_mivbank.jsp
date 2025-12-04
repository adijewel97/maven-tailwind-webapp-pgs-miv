<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<style>
/* ----------
   Spinner CSS (versi kecil & mirip style sebelumnya)
   ----------
*/
#loadingSpinner {
    display: none;
    position: fixed;
    top: 22%;
    left: 50%;
    transform: translate(-50%, 0);
    z-index: 9999;
    padding: 12px 18px;
    border-radius: 6px;
    text-align: center;
}

#loadingSpinner .spinner-content {
    font-size: 0.9rem;
    color: #333;
    text-align: center;
}

/* Spinner bulat kecil */
.spinner-mini {
    border: 3px solid #3b82f6;
    border-top-color: transparent;
    border-radius: 50%;
    width: 22px;
    height: 22px;
    margin: 0 auto 6px auto;
    animation: spin 0.8s linear infinite;
}

/* Posisi overlay tambahan jika diperlukan */
.overlay-spinner {
    position: absolute;
    top: 40%;
    left: 45%;
    z-index: 1060;
}

@keyframes spin {
    100% { transform: rotate(360deg); }
}
</style>

<!-- ✅ Spinner universal (bisa dipakai rekap & detail) -->
<div id="spinnerOverlay"
     class="hidden fixed top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 
            z-[9999] flex-col items-center justify-center bg-white bg-opacity-80 
            p-4 rounded-lg shadow-lg pointer-events-none">
    <div class="border-4 border-blue-500 border-t-transparent rounded-full w-8 h-8 animate-spin"></div>
    <span class="text-xs text-gray-600 mt-2 font-medium">Loading...</span>
</div>

<!-- =========================
     FORM FILTER
     ========================= -->
<div class="flex justify-center">
    <fieldset class="border border-gray-300 rounded p-5 mt-4 w-full  mx-auto bg-white shadow text-left">
        <legend class="text-sm font-bold px-3 text-left">Download/Print Struk - Bank MIV</legend>

        <form id="form-monitoring" class="w-full">
            <!-- === ROW INPUT (1 BARIS, 4 KOLOM) === -->
            <div class="grid grid-cols-12 gap-4 mb-4">

                <!-- Bulan Laporan -->
                <div class="col-span-12 md:col-span-3">
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
                <div class="col-span-12 md:col-span-3">
                    <label for="bank_miv" class="block text-gray-700 mb-1 font-medium">Bank MIV :</label>
                    <select id="bank_miv" name="bank_miv"
                            class="w-full border border-gray-300 rounded px-3 py-2 text-sm focus:ring-1 focus:ring-blue-500">
                        <option value="">-- Pilih Bank MIV --</option>
                    </select>
                </div>

                <!-- Distribusi -->
                <div class="col-span-12 md:col-span-3">
                    <label for="diswil" class="block text-gray-700 mb-1 font-medium">Distribusi/Wilayah :</label>
                    <select id="diswil" name="diswil"
                            class="w-full border border-gray-300 rounded px-3 py-2 text-sm focus:ring-1 focus:ring-blue-500">
                        <option value="">-- Pilih Distribusi --</option>
                    </select>
                </div>

                <!-- UP3 -->
                <div class="col-span-12 md:col-span-3">
                    <label for="up3" class="block text-gray-700 mb-1 font-medium">UP3 :</label>
                    <select id="up3" name="up3"
                            class="w-full border border-gray-300 rounded px-3 py-2 text-sm focus:ring-1 focus:ring-blue-500">
                        <option value="">-- Pilih UP3 --</option>
                    </select>
                </div>

            </div>

            <!-- Tombol Tampilkan -->
            <div class="flex justify-center mt-2">
                <button id="btnTampil" type="button"
                        class="max-w-[160px] w-full bg-blue-600 hover:bg-blue-700 text-white font-semibold px-3 py-2 rounded shadow flex items-center justify-center gap-2 transition">
                    <i class="fa fa-search"></i> <span>Tampilkan</span>
                </button>
            </div>

        </form>

    </fieldset>
</div>

<!-- =========================
     DAFTAR FILE PDF
     ========================= -->
<div class="flex justify-center">
    <fieldset class="border border-gray-300 rounded p-5 mt-4 w-full text-center bg-white shadow">
        <h3 class="text-xl font-semibold mb-4">📂 Daftar File PDF</h3>

        <!-- loading text -->
        <div id="loading" class="text-blue-600 animate-pulse mb-3">Memuat daftar file dari FTP...</div>

        <!-- list -->
        <div class="flex justify-center">
            <select id="thelist" size="10" class="border border-gray-300 rounded w-full md:w-[980px] p-2" multiple></select>
        </div>

        <!-- tombol print/download -->
        <div class="flex justify-center mt-4">
            <button id="btnPrint" type="button"
                    class="max-w-[160px] w-full bg-green-600 hover:bg-green-700 text-white font-semibold px-4 py-2 rounded shadow flex items-center justify-center gap-2 transition duration-150 ease-in-out">
                <i class="fa fa-print"></i> <span>Print PDF</span>
            </button>
        </div>
    </fieldset>
</div>

<!-- =========================
     SCRIPT
     ========================= -->
<script>
document.addEventListener("DOMContentLoaded", function () {

    // helper - context path (tidak mengubah alur)
    function getContextPath() {
        return '<%= request.getContextPath() %>';
    }

    const spinner = document.getElementById('spinnerOverlay');

    function showSpinner(){ spinner.style.display='flex'; }
    function hideSpinner(){ spinner.style.display='none'; }

    // -------------------------
    // 1) Load FTP files (AJAX)
    // -------------------------
    async function loadStrukFiles() {
        // tampilkan loading
        const loading = document.getElementById('loading');
        const list = document.getElementById('thelist');

        // note: menjaga nama variable/ID sesuai request (tidak mengubah flow)
        // perhatikan: beberapa ID mungkin berbeda di versi lain, ini adalah versi rapih saja
        showSpinner();
        try {
            // ambil parameter dari form
            const raw = document.getElementById("bln_usulan").value;
            const thblalp = convertBulanTahunToYYYYMM(raw);
            const bank_miv = document.getElementById("bank_miv").value;
            const diswil = document.getElementById("diswil").value;
            const up3 = document.getElementById("up3").value;

            console.log("Param - thblalp:", thblalp, "bank_miv:", bank_miv, "diswil:", diswil, "up3:", up3);

            // tampilkan loading
            loading.style.display = 'block';
            loading.textContent = "Memuat daftar file dari FTP...";
            list.innerHTML = '';

            // bangun URL (sesuai flow Anda)
            const url = getContextPath()
                + "/mon2strukbank?act=list"
                + "&thbl=" + encodeURIComponent(thblalp)
                + "&bankmiv=" + encodeURIComponent(bank_miv)
                + "&upi=" + encodeURIComponent(diswil)
                + "&up3=" + encodeURIComponent(up3);

            // panggil API
            const res = await fetch(url);
            if (!res.ok) throw new Error("Gagal memuat data dari server");

            // response diharapkan { files: [...] } sesuai controller Anda
            const json = await res.json();
            const files = json.files || [];

            loading.style.display = 'none';

            if (!files || files.length === 0) {
                const opt = document.createElement('option');
                opt.textContent = "Tidak ada file di folder FTP.";
                list.appendChild(opt);
                return;
            }

            files.forEach(filePath => {
                const opt = document.createElement('option');
                opt.value = filePath;
                opt.textContent = filePath.split('/').pop();
                list.appendChild(opt);
            });

        } catch (err) {
            loading.innerHTML = '<span class="text-red-600">Terjadi kesalahan: ' + err.message + '</span>';
            console.error("ERROR loadStrukFiles:", err);
            hideSpinner();
        }finally{
            hideSpinner();
        }
    }

    // -------------------------
    // 2) Flatpickr (bulan)
    // -------------------------
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
            onChange: function (selectedDates) {
                const date = selectedDates[0];
                if (date) {
                    const yyyy = date.getFullYear();
                    const mm = String(date.getMonth() + 1).padStart(2, '0');
                    blnUsulanValue.value = yyyy + mm;
                }
            },
            onReady: function (selectedDates) {
                const date = selectedDates[0] || new Date();
                const yyyy = date.getFullYear();
                const mm = String(date.getMonth() + 1).padStart(2, '0');
                blnUsulanValue.value = yyyy + mm;
                blnUsulan.value = date.toLocaleString('id-ID', { month: 'long' }) + ' ' + yyyy;
            }
        });

        calendarIcon.addEventListener('click', function () {
            fp.open();
        });
    }

    // -------------------------
    // 3) convert bulan nama -> YYYYMM
    // -------------------------
    function convertBulanTahunToYYYYMM(input) {
        if (!input) return '';
        const bulanMap = {
            "Januari": "01", "Februari": "02", "Maret": "03",
            "April": "04", "Mei": "05", "Juni": "06",
            "Juli": "07", "Agustus": "08", "September": "09",
            "Oktober": "10", "November": "11", "Desember": "12"
        };

        const parts = input.split(" ");   // "November 2025" → ["November", "2025"]
        const bulan = bulanMap[parts[0]] || '';
        const tahun = parts[1] || '';

        return tahun + bulan; // "2025" + "11" → "202511"
    }

    // -------------------------
    // 4) Load Bank MIV
    // -------------------------
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

    // -------------------------
    // 5) Load DIS/WIL
    // -------------------------
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
            } else {
                const opt = document.createElement('option');
                opt.textContent = "Tidak ada data DISWIL";
                select.appendChild(opt);
            }
        } catch (err) {
            console.error("❌ Error JS:", err.message);
        }
    }

    // -------------------------
    // 6) Load UP3 berdasarkan DIS/WIL
    // -------------------------
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

    // -------------------------
    // 7) Init: load bank & diswil
    // -------------------------
    loadBankMIV();
    loadDisWilMIV();

    // -------------------------
    // 8) Event listeners
    // -------------------------
    document.getElementById('diswil').addEventListener('change', function () {
        const kd_dist = this.value;
        console.log("Distribusi terpilih:", kd_dist);
        if (kd_dist) {
            loadUP3MIV(kd_dist);
        } else {
            document.getElementById('up3').innerHTML = '<option value="">-- Pilih UP3 MIV --</option>';
        }
    });

    // Tombol Tampilkan
    document.getElementById('btnTampil').addEventListener('click', function () {

        const bank_miv = document.getElementById("bank_miv").value;
        if (!bank_miv || bank_miv.trim() === "") {
            alert("⚠ Silakan pilih BANK MIV terlebih dahulu!");
            return;
        }

        const diswil = document.getElementById("diswil").value;
        if (!diswil || diswil.trim() === "") {
            alert("⚠ Silakan pilih DISTRIBUSI/WILAYAH terlebih dahulu!");
            return;
        }

        const up3 = document.getElementById("up3").value;
        if (!up3 || up3.trim() === "") {
            alert("⚠ Silakan pilih PILIH UP3 dahulu!");
            return;
        }

        // lanjut proses
        loadStrukFiles();
    });

    // Tombol Print (download multiple)
    document.getElementById("btnPrint").addEventListener("click", function () {
        const list = document.getElementById("thelist");
        const selected = Array.from(list.selectedOptions).map(opt => opt.value);

        if (selected.length === 0) {
            alert("⚠ Silakan pilih minimal 1 file PDF!");
            return;
        }

        selected.forEach((filePath, index) => {
            console.log("DOWNLOAD:", filePath);

            setTimeout(function () {
                window.open(getContextPath() + "/mon2strukbank?act=download&file=" + encodeURIComponent(filePath), "_blank");
            }, index * 500);
        });

    });

}); // end DOMContentLoaded
</script>
