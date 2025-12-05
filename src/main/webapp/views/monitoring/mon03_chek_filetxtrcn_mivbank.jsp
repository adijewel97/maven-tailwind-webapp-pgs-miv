<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

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

<!-- 🔹 FORM FILTER -->
<div class="flex justify-center">
    <fieldset class="border border-gray-300 rounded p-5 mt-4 w-full  mx-auto bg-white shadow text-left">
        <legend class="text-sm font-bold px-3 text-left">Upload File Lunas - Bank MIV (RCN/TXT)</legend>

        <form id="form-monitoring">
            <div class="flex justify-center">
                <div class="grid grid-cols-12 gap-3 mb-2 w-full md:w-[1100px]">

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
                <div class="grid grid-cols-12 gap-3 mb-2 w-full md:w-[1100px]">

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

                            <i class="fa fa-search absolute right-3 top-1/2 -translate-y-1/2 text-gray-500"></i>
                        </div>
                    </div>

                    <!-- Tombol Tampilkan -->
                    <div class="col-span-12 md:col-span-3 flex items-end justify-center">
                        <button id="btnTampil" type="button"
                                class="max-w-[140px] w-full bg-blue-600 hover:bg-blue-700 text-white font-semibold px-3 py-2 rounded shadow
                                flex items-center justify-center gap-2 transition duration-150 ease-in-out">
                            <i class="fa fa-search"></i> <span>Tampilkan</span>
                        </button>
                    </div>

                </div>
            </div>

        </form>
    </fieldset>
</div>

<!-- Wrapper utama 2 kolom -->
<div class="grid grid-cols-1 md:grid-cols-2 gap-6 mt-4 w-full">

    <!-- KIRI - SUKSES -->
    <fieldset class="border border-gray-300 rounded p-5 text-center bg-white shadow w-full">
        <h3 id="label_sukses" class="text-xl font-semibold mb-4">📂 Daftar File TXT dari AP2T</h3>

        <div id="loading_sukses" class="text-blue-600 animate-pulse mb-3" style="display:none;">
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
                    class="max-w-[160px] w-full bg-green-600 hover:bg-green-700 text-white font-semibold px-4 py-2 rounded shadow flex items-center justify-center gap-2 transition duration-150 ease-in-out">
                <i class="fa fa-download"></i> <span>Download</span>
            </button>
        </div>
    </fieldset>

    <!-- KANAN - GAGAL -->
    <fieldset class="border border-gray-300 rounded p-5 text-center bg-white shadow w-full">
        <h3 class="text-xl font-semibold mb-4">📂 Daftar/Gagal File TXT dari AP2T</h3>

        <div id="loading_gagal" class="text-blue-600 animate-pulse mb-3" style="display:none;">
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
                    class="max-w-[160px] w-full bg-green-600 hover:bg-green-700 text-white font-semibold px-4 py-2 rounded shadow flex items-center justify-center gap-2 transition duration-150 ease-in-out">
                <i class="fa fa-download"></i> <span>Download</span>
            </button>
        </div>
    </fieldset>

</div>

<!-- =================== JAVASCRIPT =================== -->
<script type="text/javascript">
document.addEventListener("DOMContentLoaded", function() {
    var contextPath = '<%= request.getContextPath() %>';

    const spinner = document.getElementById('spinnerOverlay');

    function showSpinner(){ spinner.style.display='flex'; }
    function hideSpinner(){ spinner.style.display='none'; }

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
    }

    async function loadFiles(jenis) {
        showSpinner();
        try {
            var bln = document.getElementById("bln_usulan").value;
            var thbl = convertBulanTahunToYYYYMM(bln);
            var bank = document.getElementById("bank_miv").value;
            var idtrans = document.getElementById('idtrans').value.trim();

            if (!bank) { alert("⚠ Silakan pilih BANK MIV!"); return; }

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

            loading_sukses.style.display = 'block';
            loading_sukses.textContent = "Memuat daftar file dari FTP...";
            list_sukses.innerHTML = "";
            list_gagal.innerHTML = "";

            const res = await fetch(url);
            const json = await res.json();

            loading_sukses.style.display = 'none';
            loading_gagal.style.display = 'none';

            var suksesFiles = json.listSukses || [];
            var gagalFiles = json.listGagal || [];

            if(idtrans && idtrans !== "*"){
                var pola = idtrans.toLowerCase();
                suksesFiles = suksesFiles.filter(f => f.toLowerCase().includes(pola));
                gagalFiles  = gagalFiles.filter(f => f.toLowerCase().includes(pola));
            }

            // isi list sukses
            if(suksesFiles.length === 0){
                var opt = document.createElement('option');
                opt.text = "Tidak ada file sukses.";
                list_sukses.appendChild(opt);
            } else {
                suksesFiles.forEach(f => {
                    var opt = document.createElement('option');
                    opt.value = f;
                    opt.text = f;
                    list_sukses.appendChild(opt);
                });
            }

            // isi list gagal
            if(gagalFiles.length === 0){
                var opt = document.createElement('option');
                opt.text = "Tidak ada file gagal.";
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
            alert("Terjadi kesalahan: " + err.message);
        } finally {
            hideSpinner(); // pasti jalan walau error
        }
    }

    document.getElementById('btnTampil').addEventListener('click', function () {
        var jenis = document.getElementById("idtxt_rcn").value.trim().toUpperCase();
        if(jenis === "") { alert("⚠ Silakan pilih jenis file (TXT/RCN)!"); return; }
        clearList();
        loadFiles(jenis);
    });

    function downloadFile(path){
        if(!path){ alert("⚠ Pilih file dulu!"); return; }
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

    document.getElementById("idtxt_rcn").addEventListener("change", function(){
        var jenis = this.value;
        var labelSukses = document.getElementById("label_sukses");
        if(jenis === "TXT"){
            labelSukses.textContent = "📂 Daftar File TXT dari AP2T";
        } else if(jenis === "RCN"){
            labelSukses.textContent = "📂 Daftar/Lunas File RCN dari BANK";
        }
    });
});
</script>
