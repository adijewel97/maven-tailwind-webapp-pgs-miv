<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<style>
/* Spinner bulat kecil (bawaan lama tetap dipertahankan jika dibutuhkan di modul lain) */
.spinner-mini {
    border: 3px solid #3b82f6;
    border-top-color: transparent;
    border-radius: 50%;
    width: 22px;
    height: 22px;
    margin: 0 auto 6px auto;
    animation: spin 0.8s linear infinite;
}

@keyframes spin {
    100% { transform: rotate(360deg); }
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
#idtrans {
    height: 38px !important;
}

</style>

<div id="spinnerOverlay"
     class="hidden fixed top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 
            z-[9999] flex-col items-center justify-center bg-white bg-opacity-90 
            p-5 rounded-lg shadow-xl border border-gray-100 pointer-events-none">
    <div class="border-4 border-blue-500 border-t-transparent rounded-full w-9 h-9 animate-spin"></div>
    <span class="text-xs text-gray-600 mt-3 font-medium tracking-wide">Memuat Data...</span>
</div>

<div class="flex justify-center w-full px-2">
    <fieldset class="border border-gray-300 rounded-xl p-5 mt-4 w-full max-w-[1100px] bg-white shadow-sm text-left">
        <legend class="text-sm font-bold px-3 text-gray-700 bg-white border border-gray-300 rounded-md shadow-sm">
            Upload File Lunas - Bank MIV (RCN/TXT)
        </legend>

        <form id="form-monitoring" class="space-y-4">
            <div class="grid grid-cols-1 md:grid-cols-3 gap-4">

                <div class="flex flex-col">
                    <label for="bln_usulan" class="block text-gray-700 mb-1 text-sm font-medium">Bulan Laporan :</label>
                    <div class="flex border border-gray-300 rounded bg-gray-50 focus-within:ring-1 focus-within:ring-blue-500 focus-within:border-blue-500 items-center transition">
                        <input type="text" id="bln_usulan"
                               class="flex-1 px-3 py-2 text-sm bg-transparent uppercase focus:outline-none"
                               placeholder="Pilih Bulan Laporan" readonly>
                        <i id="calendarIcon"
                           class="fa fa-calendar text-gray-400 px-3 cursor-pointer hover:text-blue-600 transition"></i>
                    </div>
                    <input type="hidden" id="bln_usulan_value" name="bln_usulan_value">
                </div>

                <div class="flex flex-col">
                    <label for="bank_miv" class="block text-gray-700 mb-1 text-sm font-medium">Bank MIV :</label>
                    <select id="bank_miv" name="bank_miv"
                            class="w-full border border-gray-300 rounded px-3 py-2 text-sm bg-white focus:outline-none focus:ring-1 focus:ring-blue-500 focus:border-blue-500 transition">
                        <option value="">-- Pilih Bank MIV --</option>
                    </select>
                </div>

                <div class="flex flex-col">
                    <label for="idtxt_rcn" class="block text-gray-700 mb-1 text-sm font-medium">Chek File TXT/RCN :</label>
                    <select id="idtxt_rcn" name="txt_rcn"
                            class="w-full border border-gray-300 rounded px-3 py-2 text-sm bg-white focus:outline-none focus:ring-1 focus:ring-blue-500 focus:border-blue-500 transition">
                        <option value="TXT">File TXT Untuk Bank</option>
                        <option value="RCN">File RCN Dari Bank</option>
                    </select>
                </div>

            </div>

            <div class="grid grid-cols-1 md:grid-cols-12 gap-4 items-end">

                <div class="md:col-span-9 flex flex-col">
                    <label for="idtrans" class="block text-gray-700 mb-1 text-sm font-semibold">
                        Masukkan IdTransaksi / Nousulan :
                    </label>
                    <div class="relative">
                        <input type="text" id="idtrans"
                               class="w-full border border-gray-300 rounded px-3 py-2 text-sm pr-10 focus:outline-none focus:ring-1 focus:ring-blue-500 focus:border-blue-500 transition"
                               placeholder="Ketik IdTransaksi / Nousulan [ */'' = Semua; POS53DP / NTL53 / PRE53DPK = ID ]">
                        <i class="fa fa-search absolute right-3 top-1/2 -translate-y-1/2 text-gray-400"></i>
                    </div>
                </div>

                <div class="md:col-span-3 flex justify-center md:justify-end">
                    <button id="btnTampil" type="button"
                            class="w-full max-w-[160px] bg-blue-600 hover:bg-blue-700 text-white font-semibold px-4 py-2 rounded shadow-sm
                                   flex items-center justify-center gap-2 transition duration-150 ease-in-out">
                        <i class="fa fa-search"></i> <span>Tampilkan</span>
                    </button>
                </div>

            </div>
        </form>
    </fieldset>
</div>

<div class="grid grid-cols-1 md:grid-cols-2 gap-6 mt-4 w-full max-w-[1100px] mx-auto px-2">

    <!-- FIELDSET SUKSES -->
    <fieldset class="border border-gray-300 rounded-xl p-5 bg-white shadow-sm w-full flex flex-col">
        <h3 id="label_sukses" class="text-base font-semibold mb-1 text-gray-800 text-center flex items-center justify-center gap-2">
            📂 Daftar File TXT dari AP2T
        </h3>

        <!-- ➕ LABEL TOTAL SUKSES -->
        <div class="flex justify-between items-center w-full mb-2 text-xs font-semibold text-green-700">
            <span id="count_sukses" class="bg-green-50 px-2 py-1 rounded border border-green-200">
                Total File Sukses: 0 file
            </span>
        </div>

        <div id="loading_sukses" class="text-sm text-blue-600 animate-pulse mb-2 text-center" style="display:none;">
            Memuat daftar file dari FTP...
        </div>

        <div class="w-full h-60 min-h-[240px] mb-4">
            <select id="list_sukses" size="10"
                    class="border border-gray-300 rounded-lg w-full h-full p-2 text-sm text-gray-700 bg-gray-50
                           focus:outline-none focus:ring-1 focus:ring-blue-500 overflow-auto whitespace-nowrap"
                    multiple></select>
        </div>

        <div class="flex justify-center mt-auto">
            <button id="btnPrint_sukses" type="button"
                    class="max-w-[160px] w-full bg-green-600 hover:bg-green-700 text-white font-semibold px-4 py-2 rounded shadow flex items-center justify-center gap-2 transition duration-150 ease-in-out">
                <i class="fa fa-download"></i> <span>Download</span>
            </button>
        </div>
    </fieldset>

    <!-- FIELDSET GAGAL -->
    <fieldset class="border border-gray-300 rounded-xl p-5 bg-white shadow-sm w-full flex flex-col">
        <h3 id="label_gagal" class="text-base font-semibold mb-1 text-gray-800 text-center flex items-center justify-center gap-2">
            📂 Daftar/Gagal File TXT dari AP2T
        </h3>

        <!-- ➕ LABEL TOTAL GAGAL -->
        <div class="flex justify-between items-center w-full mb-2 text-xs font-semibold text-red-700">
            <span id="count_gagal" class="bg-red-50 px-2 py-1 rounded border border-red-200">
                Total File Gagal: 0 file
            </span>
        </div>

        <div id="loading_gagal" class="text-sm text-blue-600 animate-pulse mb-2 text-center" style="display:none;">
            Memuat daftar file dari FTP...
        </div>

        <div class="w-full h-60 min-h-[240px] mb-4">
            <select id="list_gagal" size="10"
                    class="border border-gray-300 rounded-lg w-full h-full p-2 text-sm text-gray-700 bg-gray-50
                           focus:outline-none focus:ring-1 focus:ring-blue-500 overflow-auto whitespace-nowrap"
                    multiple></select>
        </div>

        <div class="flex justify-center mt-auto">
            <button id="btnPrint_gagal" type="button"
                    class="max-w-[160px] w-full bg-green-600 hover:bg-green-700 text-white font-semibold px-4 py-2 rounded shadow flex items-center justify-center gap-2 transition duration-150 ease-in-out">
                <i class="fa fa-download"></i> <span>Download</span>
            </button>
        </div>
    </fieldset>

</div>

<script type="text/javascript">
document.addEventListener("DOMContentLoaded", function() {
    var contextPath = '<%= request.getContextPath() %>';

    const spinner = document.getElementById('spinnerOverlay');

    function showSpinner(){ 
        spinner.classList.remove('hidden'); 
        spinner.classList.add('flex');
    }
    function hideSpinner(){ 
        spinner.classList.remove('flex'); 
        spinner.classList.add('hidden');
    }

    // -----------------------------------------------------
    // 0) Inisialisasi Instance Select2 untuk Bank MIV
    // -----------------------------------------------------
    $('#bank_miv').select2({
        placeholder: "-- Pilih Bank MIV --",
        allowClear: true,
        width: '100%'
    }); 

    $('#idtxt_rcn').select2({
        placeholder: "-- Pilih File TXT Untuk BANK--",
        allowClear: true,
        width: '100%'
    }); 

    function convertBulanTahunToYYYYMM(input) {
        var bulanMap = {
            "Januari": "01", "Februari": "02", "Maret": "03",
            "April": "04", "Mei": "05", "Juni": "06",
            "Juli": "07", "Agustus": "08", "September": "09",
            "Oktober": "10", "November": "11", "Desember": "12"
        };
        var parts = input.split(" ");
        return parts[1] + bulanMap[parts[0]];
    }

    // Flatpickr Bulan
    if (typeof flatpickr !== "undefined") {
        var blnUsulan = document.getElementById('bln_usulan');
        var blnUsulanValue = document.getElementById('bln_usulan_value');
        var calendarIcon = document.getElementById('calendarIcon');

        var fp = flatpickr(blnUsulan, {
            locale: "id",
            plugins: [new monthSelectPlugin({
                shorthand: false,
                dateFormat: "F Y",
                altFormat: "Y-m"
            })],
            defaultDate: new Date(),
            onChange: function(selectedDates) {
                var date = selectedDates[0];
                if (date) {
                    var yyyy = date.getFullYear();
                    var mm = ("0" + (date.getMonth() + 1)).slice(-2);
                    blnUsulanValue.value = yyyy + mm;
                }
            },
            onReady: function(selectedDates) {
                var date = selectedDates[0] || new Date();
                var yyyy = date.getFullYear();
                var mm = ("0" + (date.getMonth() + 1)).slice(-2);
                blnUsulanValue.value = yyyy + mm;
                blnUsulan.value = date.toLocaleString('id-ID', { month: 'long' }) + ' ' + yyyy;
            }
        });
        calendarIcon.addEventListener('click', function() { fp.open(); });
    }

    // Load Bank MIV
    function loadBankMIV() {
        var params = "act=getNamaBank&kdbank=";
        fetch(contextPath + "/mst-global", {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: params
        }).then(res => res.json())
        .then(json => {
            var select = document.getElementById('bank_miv');
            select.innerHTML = '<option value="">-- Pilih Bank MIV --</option>';
            if (json.status === 'success' && Array.isArray(json.data)) {
                json.data.forEach(bank => {
                    var opt = document.createElement('option');
                    opt.value = bank.KODE_ERP;
                    opt.text = bank.NAMA_BANK;
                    select.appendChild(opt);
                });
            } else {
                var opt = document.createElement('option');
                opt.text = "Tidak ada data bank";
                select.appendChild(opt);
            }
        }).catch(err => console.error("❌ Error load bank:", err.message));
    }
    loadBankMIV();

    function clearList() {
        document.getElementById("list_sukses").innerHTML = "";
        document.getElementById("list_gagal").innerHTML = "";
        document.getElementById("count_sukses").textContent = "Total File Sukses: 0 file";
        document.getElementById("count_gagal").textContent = "Total File Gagal: 0 file";
    }

    async function loadFiles(jenis) {
        var bank = document.getElementById("bank_miv").value;
        if (!bank) 
        { 
            showMessageDlg("Info", "Silakan pilih BANK MIV!");
            return; 
        }

        showSpinner();
        try {
            var bln = document.getElementById("bln_usulan").value;
            var thbl = convertBulanTahunToYYYYMM(bln);
            var idtrans = document.getElementById('idtrans').value.trim();

            var act = (jenis === 'TXT') ? 'listtxt' : 'listrcn';
            var url = contextPath + "/mon3ChekFileTxt?act=" + act
            + "&thbl=" + thbl
            + "&bankmiv=" + bank
            + "&idtrans=" + encodeURIComponent(idtrans)
            + "&jenis=" + jenis;

            var loading_sukses = document.getElementById('loading_sukses');
            var loading_gagal = document.getElementById('loading_gagal');
            var list_sukses = document.getElementById('list_sukses');
            var list_gagal = document.getElementById('list_gagal');
            var count_sukses = document.getElementById('count_sukses');
            var count_gagal = document.getElementById('count_gagal');

            loading_sukses.style.display = 'block';
            loading_gagal.style.display = 'block';
            list_sukses.innerHTML = "";
            list_gagal.innerHTML = "";
            count_sukses.textContent = "Memuat data...";
            count_gagal.textContent = "Memuat data...";

            const res = await fetch(url);
            const json = await res.json();

            loading_sukses.style.display = 'none';
            loading_gagal.style.display = 'none';

            var suksesFiles = json.listSukses || [];
            var gagalFiles = json.listGagal || [];

            // Filter berdasarkan idtrans jika ada
            if(idtrans && idtrans !== "*"){
                var pola = idtrans.toLowerCase();
                suksesFiles = suksesFiles.filter(f => f.toLowerCase().includes(pola));
                gagalFiles  = gagalFiles.filter(f => f.toLowerCase().includes(pola));
            }

            // =========================================================
            // ➕ PROSES SORTING JS: Urutkan berdasarkan Nama File & Ekstensi
            // =========================================================
            suksesFiles.sort((a, b) => a.localeCompare(b, undefined, { sensitivity: 'base', numeric: true }));
            gagalFiles.sort((a, b) => a.localeCompare(b, undefined, { sensitivity: 'base', numeric: true }));

            // ➕ Update label jumlah file Sukses
            count_sukses.textContent = "Total File Sukses: " + suksesFiles.length + " file";
            
            // isi list sukses
            if(suksesFiles.length === 0){
                var opt = document.createElement('option');
                opt.text = "Tidak ada file sukses.";
                opt.disabled = true;
                list_sukses.appendChild(opt);
            } else {
                suksesFiles.forEach(f => {
                    var opt = document.createElement('option');
                    opt.value = f;
                    opt.text = f;
                    list_sukses.appendChild(opt);
                });
            }

            // ➕ Update label jumlah file Gagal
            count_gagal.textContent = "Total File Gagal: " + gagalFiles.length + " file";

            // isi list gagal
            if(gagalFiles.length === 0){
                var opt = document.createElement('option');
                opt.text = "Tidak ada file gagal.";
                opt.disabled = true;
                list_gagal.appendChild(opt);
            } else {
                gagalFiles.forEach(f => {
                    var opt = document.createElement('option');
                    opt.value = f;
                    opt.text = f;
                    list_gagal.appendChild(opt);
                });
            }

        } catch(err) {
            console.error("❌ Error load files:", err);
            document.getElementById("count_sukses").textContent = "Total File Sukses: Gagal memuat";
            document.getElementById("count_gagal").textContent = "Total File Gagal: Gagal memuat";
            showMessageDlg("Error", "Terjadi kesalahan: " + err.message);
        } finally {
            hideSpinner();
        }
    }

    document.getElementById('btnTampil').addEventListener('click', function () {
        var jenis = document.getElementById("idtxt_rcn").value.trim().toUpperCase();
        if(jenis === "") { 
            showMessageDlg("Error", "Silakan pilih jenis file (TXT/RCN)!");
            return; 
        }

        clearList();
        loadFiles(jenis);
    });

    function downloadFile(path){
        if(!path || path.substring(0, 9) === "Tidak ada"){ 
            showMessageDlg("Info", "Pilih file valid dulu!");
            return; 
        }
        var url = contextPath + "/mon3ChekFileTxt?act=download&file=" + encodeURIComponent(path);
        var a = document.createElement('a');
        a.href = url;
        a.target = "_blank";
        document.body.appendChild(a);
        a.click();
        a.remove();
    }

    function attachDownload(btnId, listId){
        var btn = document.getElementById(btnId);
        var list = document.getElementById(listId);
        btn.addEventListener('click', function(){ downloadFile(list.value); });
        list.addEventListener('dblclick', function(){ downloadFile(list.value); });
        list.addEventListener('keydown', function(e){ if(e.key==="Enter"){ downloadFile(list.value); } });
    }
    attachDownload('btnPrint_sukses','list_sukses');
    attachDownload('btnPrint_gagal','list_gagal');

    // -----------------------------------------------------
    // PERBAIKAN: Gunakan event change milik Select2
    // -----------------------------------------------------
    $('#idtxt_rcn').on('change', function(){
        var jenis = $(this).val(); // Mengambil value menggunakan jQuery
        var labelSukses = document.getElementById("label_sukses");
        var labelGagal = document.getElementById("label_gagal");
        
        if(jenis === "TXT"){
            labelSukses.innerHTML = "📂 Daftar File TXT dari AP2T";
            labelGagal.innerHTML  = "📂 Daftar/Gagal File RCN dari AP2T";
        } else if(jenis === "RCN"){
            labelSukses.innerHTML = "📂 Lunas File RCN dari BANK";
            labelGagal.innerHTML  = "📂 Lunas/Gagal File RCN dari BANK";
        }
    });
    
});
</script>