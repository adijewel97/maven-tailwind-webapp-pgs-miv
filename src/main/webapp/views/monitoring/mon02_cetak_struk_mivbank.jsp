<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!-- 1. Tambahkan Select2 CSS & jQuery jika belum ada di parent template Anda -->
<!-- <link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" /> -->

<style>
/* ---------- Spinner CSS ---------- */
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

.spinner-mini {
    border: 3px solid #3b82f6;
    border-top-color: transparent;
    border-radius: 50%;
    width: 22px;
    height: 22px;
    margin: 0 auto 6px auto;
    animation: spin 0.8s linear infinite;
}

.overlay-spinner {
    position: absolute;
    top: 40%;
    left: 45%;
    z-index: 1060;
}

@keyframes spin {
    100% { transform: rotate(360deg); }
}

/* 
   KUSTOMISASI SELECT2 AGAR MATCING DENGAN TAILWIND 
   Menggantikan style .ts-wrapper lama Anda
*/
.select2-container--default .select2-selection--single {
    border-color: #d1d5db !important; /* border-gray-300 */
    border-radius: 0.25rem !important; /* rounded */
    height: 38px !important; /* Menyesuaikan tinggi input default Tailwind */
    display: flex !important;
    align-items: center;
}

.select2-container--default .select2-selection--single .select2-selection__rendered {
    color: #374151 !important; /* text-gray-700 */
    font-size: 0.875rem !important; /* text-sm */
    padding-left: 0.75rem !important;
    padding-right: 0.75rem !important;
}

.select2-container--default .select2-selection--single .select2-selection__arrow {
    height: 36px !important;
}

.select2-container--default.select2-container--focus .select2-selection--single {
    box-shadow: 0 0 0 1px #3b82f6 !important; /* focus:ring-1 focus:ring-blue-500 */
    border-color: #3b82f6 !important;
}

/* atur tinggi imput sama sengan combo*/
/* 1. Samakan tinggi wrapper Bulan Laporan agar pas 38px */
#bln_usulan {
    height: 36px !important; /* Kurangi 2px untuk mengompensasi border atas & bawah div pembungkus */
}

/* Pastikan pembungkus Bulan Laporan (div flex) memiliki tinggi total tepat 38px */
#bln_usulanAndCalendarWrapper {
    height: 38px !important;
}

/* 2. Samakan tinggi input ID Transaksi agar pas 38px */
#id_transaksi {
    height: 38px !important;
}

/* 3. Penyelaras visual Select2 (Memastikan tepat 38px dengan padding yang pas) */
.select2-container--default .select2-selection--single {
    border-color: #d1d5db !important; /* border-gray-300 */
    border-radius: 0.25rem !important; /* rounded */
    height: 38px !important; 
    display: flex !important;
    align-items: center !important;
}

.select2-container--default .select2-selection--single .select2-selection__rendered {
    color: #374151 !important;
    font-size: 0.875rem !important;
    padding-left: 0.75rem !important;
    padding-right: 0.75rem !important;
    line-height: 36px !important; /* Menjaga teks di tengah secara vertikal */
}

.select2-container--default .select2-selection--single .select2-selection__arrow {
    height: 36px !important;
}

</style>

<!-- ✅ Spinner universal -->
<div id="spinnerOverlay"
     class="hidden fixed top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 
            z-[9999] flex-col items-center justify-center bg-white bg-opacity-80 
            p-4 rounded-lg shadow-lg pointer-events-none">
    <div class="border-4 border-blue-500 border-t-transparent rounded-full w-8 h-8 animate-spin"></div>
    <span class="text-xs text-gray-600 mt-2 font-medium">Loading...</span>
</div>

<!-- ========================= FORM FILTER ========================= -->
<div class="flex justify-center">
    <fieldset class="border border-gray-300 rounded p-5 mt-4 w-full mx-auto bg-white shadow text-left">
        <legend class="text-sm font-bold px-3 text-left">Download/Print Struk - Bank MIV</legend>

        <form id="form-monitoring" class="w-full">
            <div class="grid grid-cols-12 gap-4 mb-4">
                <!-- Bulan Laporan -->
                <div class="col-span-12 md:col-span-3">
                    <label for="bln_usulan" class="block text-gray-700 mb-1 font-medium">Bulan Laporan :</label>
                    <!-- TAMBAHKAN ID DISINI (bln_usulanAndCalendarWrapper) dan class h-[38px] -->
                    <div id="bln_usulanAndCalendarWrapper" class="flex border border-gray-300 rounded items-center h-[38px] bg-white">
                        <input type="text" id="bln_usulan"
                            class="flex-1 px-3 py-2 text-sm uppercase focus:outline-none focus:ring-1 focus:ring-blue-500"
                            placeholder="Pilih Bulan Laporan" readonly>
                        <i id="calendarIcon" class="fa fa-calendar text-gray-500 px-3 cursor-pointer hover:text-blue-600"></i>
                    </div>
                    <input type="hidden" id="bln_usulan_value" name="bln_usulan_value">
                </div>

                <!-- Bank MIV (Sekarang Menggunakan Select2) -->
                <div class="col-span-12 md:col-span-3">
                    <label for="bank_miv" class="block text-gray-700 mb-1 font-medium">Bank MIV :</label>
                    <!-- Hapus placeholder & autocomplete bawaan karena akan di-handle Select2 via JS -->
                    <select id="bank_miv" name="bank_miv" class="w-full text-sm">
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

                <!-- ID Transaksi -->
                <div class="col-span-12 md:col-span-3 mt-2">
                    <label for="id_transaksi" class="block text-gray-700 mb-1 font-medium">ID Transaksi :</label>
                    <input type="text" id="id_transaksi" name="id_transaksi"
                        class="w-full border border-gray-300 rounded px-3 py-2 text-sm focus:ring-1 focus:ring-blue-500"
                        placeholder="Isi ID Transaksi atau '*' untuk semua">
                </div>
            </div>

            <div class="flex justify-center mt-2">
                <button id="btnTampil" type="button"
                        class="max-w-[160px] w-full bg-blue-600 hover:bg-blue-700 text-white font-semibold px-3 py-2 rounded shadow flex items-center justify-center gap-2 transition">
                    <i class="fa fa-search"></i> <span>Tampilkan</span>
                </button>
            </div>
        </form>
    </fieldset>
</div>

<!-- ========================= DAFTAR FILE PDF ========================= -->
<fieldset class="border border-gray-300 rounded p-5 mt-4 w-full mx-auto bg-white shadow text-left">
    <legend class="text-sm font-bold px-3 text-left">List File Struk - MIV</legend>
        <div class="flex justify-center">
            <fieldset class="border border-gray-300 p-5 mt-4 w-full text-center bg-white shadow">
                <h3 class="text-xl font-semibold mb-4">📂 Daftar File PDF</h3>
                <div id="loading" class="text-blue-600 animate-pulse mb-3">Memuat daftar file dari FTP...</div>
                <div class="flex justify-center">
                    <select id="thelist" size="10" class="border border-gray-300 rounded w-full md:w-[980px] p-2" multiple></select>
                </div>
                <div class="flex justify-center mt-4">
                    <button id="btnPrint" type="button"
                            class="max-w-[160px] w-full bg-green-600 hover:bg-green-700 text-white font-semibold px-4 py-2 rounded shadow flex items-center justify-center gap-2 transition duration-150 ease-in-out">
                        <i class="fa fa-print"></i> <span>Print PDF</span>
                    </button>
                </div>
            </fieldset>
        </div>
</fieldset>

<!-- 2. Tambahkan Select2 JS Link jika belum ada -->
<!-- <script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script> -->

<!-- ========================= SCRIPT ========================= -->
<script>
document.addEventListener("DOMContentLoaded", function () {

    function getContextPath() {
        return '<%= request.getContextPath() %>';
    }

    const spinner = document.getElementById('spinnerOverlay');
    function showSpinner(){ spinner.style.display='flex'; }
    function hideSpinner(){ spinner.style.display='none'; }

    // -----------------------------------------------------
    // 0) Inisialisasi Instance Select2 untuk Bank MIV (Menggantikan Tom Select)
    // -----------------------------------------------------
    // Menggunakan jQuery ($) karena Select2 membutuhkan jQuery
    $('#bank_miv').select2({
        placeholder: "-- Pilih Bank MIV --",
        allowClear: true,
        width: '100%' // Memastikan lebar penuh mengikuti grid Tailwind
    }); 

    $('#diswil').select2({
        placeholder: "-- Pilih Distribusi/Wilayah --",
        allowClear: true,
        width: '100%' // Memastikan lebar penuh mengikuti grid Tailwind
    });
    
     $('#up3').select2({
        placeholder: "-- Pilih UP3 --",
        allowClear: true,
        width: '100%' // Agar mengikuti grid Tailwind Anda
    });

    // -------------------------
    // 1) Load FTP files (AJAX)
    // -------------------------
    async function loadStrukFiles() {
        const loading = document.getElementById('loading');
        const list = document.getElementById('thelist');
        showSpinner();
        loading.style.display = 'block';
        loading.textContent = "Memuat daftar file dari FTP...";
        list.innerHTML = '';

        try {
            const raw = document.getElementById("bln_usulan").value;
            const thblalp = convertBulanTahunToYYYYMM(raw);
            const bank_miv = document.getElementById("bank_miv").value;
            const diswil = document.getElementById("diswil").value;
            const up3 = document.getElementById("up3").value;
            const idTransaksiFilter = document.getElementById("id_transaksi").value.trim().toUpperCase();

            const url = getContextPath()
                + "/mon2strukbank?act=list"
                + "&thbl=" + encodeURIComponent(thblalp)
                + "&bankmiv=" + encodeURIComponent(bank_miv)
                + "&upi=" + encodeURIComponent(diswil)
                + "&up3=" + encodeURIComponent(up3);

            const res = await fetch(url);
            if (!res.ok) throw new Error("Gagal memuat data dari server");

            const json = await res.json();
            const files = json.files || [];
            let filteredFiles = files;

            if (idTransaksiFilter && idTransaksiFilter !== '*') {
                filteredFiles = files.filter(f => f.split('/').pop().includes(idTransaksiFilter));
            }

            if (!filteredFiles || filteredFiles.length === 0) {
                const opt = document.createElement('option');
                opt.textContent = "Tidak ada file sesuai filter.";
                list.appendChild(opt);
                return;
            }

            filteredFiles.forEach(filePath => {
                const opt = document.createElement('option');
                opt.value = filePath;
                opt.textContent = filePath.split('/').pop();
                list.appendChild(opt);
            });

            loading.style.display = 'none';
        } catch (err) {
            loading.innerHTML = '<span class="text-red-600">Terjadi kesalahan: ' + err.message + '</span>';
            console.error("ERROR loadStrukFiles:", err);
        } finally {
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
        const parts = input.split(" ");
        const bulan = bulanMap[parts[0]] || '';
        const tahun = parts[1] || '';
        return tahun + bulan;
    }

    // -------------------------
    // 4) Load Bank MIV (Diubah penuh ke Gaya Manipulasi DOM Select2)
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

            // Ambil element native select
            const $bankSelect = $('#bank_miv');
            
            // Bersihkan data lama dengan cara standard Select2
            $bankSelect.empty().trigger("change");
            
            // Tambahkan kembali default placeholder option
            $bankSelect.append(new Option('-- Pilih Bank MIV --', ''));

            if (json.status === 'success' && Array.isArray(json.data)) {
                // Loop data dan masukkan ke element via Select2 Option constructor
                json.data.forEach(bank => {
                    const newOption = new Option(bank.NAMA_BANK, bank.KODE_ERP, false, false);
                    $bankSelect.append(newOption);
                });
                
                // Beri tahu Select2 untuk me-render ulang UI-nya setelah DOM berubah
                $bankSelect.trigger('change');
                console.log("✅ Bank MIV berhasil dimuat ke Select2:", json.data.length, "data");
            } else {
                $bankSelect.append(new Option('Tidak ada data bank', ''));
                $bankSelect.trigger('change');
            }
        } catch (err) {
            console.error("❌ Error JS:", err.message);
        }
    }

    // -------------------------
    // 5) Load DIS/WIL (Disinkronkan dengan Select2)
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

            const $diswilSelect = $('#diswil');
            $diswilSelect.empty().trigger("change");
            $diswilSelect.append(new Option('-- Pilih Distribusi --', ''));

            if (json.status === 'success' && Array.isArray(json.data)) {
                json.data.forEach(diswil => {
                    const newOption = new Option(diswil.NAMA_DIST, diswil.KD_DIST, false, false);
                    $diswilSelect.append(newOption);
                });
                $diswilSelect.trigger('change');
                console.log("✅ DISWIL MIV berhasil dimuat ke Select2:", json.data.length, "data");
            } else {
                $diswilSelect.append(new Option('Tidak ada data DISWIL', ''));
                $diswilSelect.trigger('change');
            }
        } catch (err) {
            console.error("❌ Error JS:", err.message);
        }
    }

    // -------------------------
    // 6) Load UP3 berdasarkan DIS/WIL (Disinkronkan dengan Select2)
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

            const $up3Select = $('#up3');
            $up3Select.empty().trigger("change");
            $up3Select.append(new Option('-- Pilih UP3 --', ''));

            if (json.status === 'success' && Array.isArray(json.data)) {
                json.data.forEach(up3 => {
                    const newOption = new Option(up3.NAMA_AREA, up3.UNITAP, false, false);
                    $up3Select.append(newOption);
                });
                $up3Select.trigger('change');
                console.log("✅ UP3 MIV berhasil dimuat ke Select2:", json.data.length, "data");
            } else {
                $up3Select.append(new Option('Tidak ada data UP3', ''));
                $up3Select.trigger('change');
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
    // 8) Event listeners (Menggunakan Event Listener Select2 jQuery)
    // -------------------------
    $('#diswil').on('select2:select select2:unselect change', function (e) {
        const kd_dist = $(this).val();
        if (kd_dist) {
            loadUP3MIV(kd_dist);
        } else {
            const $up3Select = $('#up3');
            $up3Select.empty().append(new Option('-- Pilih UP3 --', '')).trigger('change');
        }
    });

    // Tombol Tampilkan
    document.getElementById('btnTampil').addEventListener('click', function () {
        const bank_miv = document.getElementById("bank_miv").value;
        if (!bank_miv || bank_miv.trim() === "") {
            alert("Silakan pilih BANK MIV terlebih dahulu!");
            return;
        }

        const diswil = document.getElementById("diswil").value;
        if (!diswil || diswil.trim() === "") {
            alert("Silakan pilih DISTRIBUSI/WILAYAH terlebih dahulu!");
            return;
        }

        const up3 = document.getElementById("up3").value;
        if (!up3 || up3.trim() === "") {
            alert("Silakan pilih PILIH UP3 dahulu!");
            return;
        }

        loadStrukFiles();
    });

    // Tombol Print
    document.getElementById("btnPrint").addEventListener("click", function () {
        const list = document.getElementById("thelist");
        const selected = Array.from(list.selectedOptions).map(opt => opt.value);

        if (selected.length === 0) {
            alert("Silakan pilih minimal 1 file PDF!");
            return;
        }

        selected.forEach((filePath, index) => {
            const safeURL = getContextPath() 
                + "/mon2strukbank?act=download&file=" 
                + encodeURIComponent(filePath);

            setTimeout(() => {
                window.open(safeURL, "_blank");
            }, index * 500);
        });
    });

});
</script>