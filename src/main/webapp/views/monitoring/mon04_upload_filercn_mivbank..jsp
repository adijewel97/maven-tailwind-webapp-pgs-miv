<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<div id="spinnerOverlay"
     class="hidden fixed top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 
            z-[9999] flex-col items-center justify-center bg-white bg-opacity-90 
            p-5 rounded-lg shadow-xl border border-gray-100 pointer-events-none">
    <div class="border-4 border-blue-500 border-t-transparent rounded-full w-9 h-9 animate-spin"></div>
    <span class="text-xs text-gray-600 mt-3 font-medium tracking-wide">Memuat Data...</span>
</div>

<!-- 🔹 FORM FILTER -->
<div class="flex justify-center">
    <fieldset class="border border-gray-300 rounded p-5 mt-4 w-full bg-white shadow text-left">
        <legend class="text-sm font-bold px-3 text-left">Download/Proses File Pelunasan RCN BANK MIV</legend>

        <form id="form-monitoring">         
            <div class="col-span-12 md:col-span-2 mt-4 flex justify-center">
                <button id="btnTampilRcn" type="button" class="max-w-[140px] w-full bg-blue-600 hover:bg-blue-700 text-white font-semibold px-3 py-2 rounded shadow flex items-center justify-center gap-2 transition duration-150 ease-in-out">
                    <i class="fa fa-search"></i> <span>Tampilkan RCN</span>
                </button>
            </div>

            <h3 class="text-xl font-semibold mb-4">📂 Daftar File RCN</h3>
            <div id="loading_sukses" class="text-sm text-blue-600 animate-pulse mb-2 text-center" style="display:none;">
                Memuat daftar file dari FTP...
            </div>
            
            <div class="flex justify-center">
                <select id="list_rcn_sukses" size="10" class="border border-gray-300 rounded w-full p-2" multiple></select>
            </div>
            
            <div class="flex justify-center mt-4">
                <button id="btnProsesRcn" disabled type="button" class="max-w-[160px] w-full bg-green-600 hover:bg-green-700 text-white font-semibold px-4 py-2 rounded shadow flex items-center justify-center gap-2 transition duration-150 ease-in-out disabled:opacity-50 disabled:cursor-not-allowed">
                    <i class="fa fa-download"></i> <span>Proses Data</span>
                </button>
            </div>
        </form>
    </fieldset>
</div>

<!-- 🔹 TABEL LOG HASIL PROSES DATABASE (Selalu Tampil / Default) -->
<div id="logContainer" class="mt-6 w-full bg-white shadow rounded border border-gray-300 p-5 text-left">
    <div class="flex flex-col md:flex-row justify-between items-start md:items-center mb-4 border-b pb-3 gap-3">
        <div>
            <h3 class="text-lg font-bold text-gray-800 flex items-center gap-2">
                <i class="fa fa-history text-blue-600"></i> Log Hasil Proses Database (Hari Ini)
            </h3>
            <p class="text-xs text-gray-500 mt-0.5">Menampilkan riwayat pemrosesan data untuk tanggal hari ini saja.</p>
        </div>
        
        <!-- Fitur Pencarian & Bersihkan -->
        <div class="flex items-center gap-2 w-full md:w-auto">
            <div class="relative w-full md:w-64">
                <span class="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none text-gray-400">
                    <i class="fa fa-search text-xs"></i>
                </span>
                <input id="searchLog" type="text" placeholder="Cari di tabel log..." 
                       class="w-full pl-8 pr-3 py-1.5 text-xs border border-gray-300 rounded focus:outline-none focus:ring-1 focus:ring-blue-500" />
            </div>
            <button id="btnClearLog" type="button" class="text-xs bg-gray-200 hover:bg-gray-300 text-gray-700 px-3 py-1.5 rounded transition whitespace-nowrap">
                Bersihkan Log
            </button>
        </div>
    </div>
    
    <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200 text-sm">
            <thead class="bg-gray-50 font-semibold text-gray-700 text-left">
                <tr>
                    <th class="px-4 py-2 border-b">Tanggal Insert</th>
                    <th class="px-4 py-2 border-b">Nama File</th>
                    <th class="px-4 py-2 border-b">Produk</th>
                    <th class="px-4 py-2 border-b">Status</th>
                    <th class="px-4 py-2 border-b">Pesan Database</th>
                </tr>
            </thead>
            <tbody id="logTableBody" class="divide-y divide-gray-100 bg-white">
                <!-- DataTables akan mengontrol baris tabel secara otomatis -->
            </tbody>
        </table>
    </div>
</div>

<script>
// 📌 Deklarasikan table_logrcn di luar agar dapat diakses secara global
let table_logrcn = null;

document.addEventListener("DOMContentLoaded", function() {
    var contextPath = '<%= request.getContextPath() %>';

    const spinner = document.getElementById('spinnerOverlay');
    const searchLog = document.getElementById('searchLog');

    function showSpinner(){ 
        spinner.classList.remove('hidden'); 
        spinner.classList.add('flex');
    }

    function hideSpinner(){ 
        spinner.classList.remove('flex'); 
        spinner.classList.add('hidden');
    }

    // Aksi tombol bersihkan tabel log
    document.getElementById("btnClearLog").addEventListener("click", function() {
        if (table_logrcn) {
            table_logrcn.clear().draw(); 
        }
        searchLog.value = "";
    });

    // Hubungkan input search custom ke DataTables
    searchLog.addEventListener('keyup', function() {
        if (table_logrcn) {
            table_logrcn.search(this.value).draw();
        }
    });

    async function loadFilesRcn() {
        showSpinner();
        try {
            var act = 'listrcn';
            var url = contextPath + "/mon4ProsesFileRcn?act=" + act;
            var loading_sukses = document.getElementById('loading_sukses');
            var list_rcn_sukses = document.getElementById('list_rcn_sukses');

            loading_sukses.style.display = 'block';            
            list_rcn_sukses.innerHTML = "";

            const res = await fetch(url);
            const json = await res.json();

            loading_sukses.style.display = 'none';
            var suksesFiles = json.listSuksesRcn || [];

            if (suksesFiles.length === 0) {
                var opt = document.createElement('option');
                opt.text = "Tidak ada file.";
                opt.disabled = true;
                list_rcn_sukses.appendChild(opt);
                document.getElementById("btnProsesRcn").disabled = true;
            } else {
                suksesFiles.forEach(f => {
                    var opt = document.createElement('option');                    
                    opt.value = f;                    
                    var fileName = f.substring(f.lastIndexOf("/") + 1);
                    opt.text = fileName;                    
                    list_rcn_sukses.appendChild(opt);
                });
                document.getElementById("btnProsesRcn").disabled = false;
            }
        } catch(err) {
            console.error("❌ Error load files:", err);
            if (typeof showMessageDlg === "function") {
                showMessageDlg("Error", "Terjadi kesalahan: " + err.message);
            } else {
                alert("Terjadi kesalahan: " + err.message);
            }
        } finally {
            hideSpinner();
        }
    }

    // 📌 EVENT LISTENER TOMBOL TAMPILKAN RCN
    document.getElementById('btnTampilRcn').addEventListener('click', function () {
        loadFilesRcn();
        
        if (table_logrcn !== null) {            
            showSpinner();
            table_logrcn.ajax.reload(function(json) {
                hideSpinner();                
                console.log("Data log berhasil diperbarui dari database.");
            }, false); 
        } else {
            console.error("Variabel table_logrcn belum di-inisialisasi!");
        }
    });

    // Proses konversi file ke json dan kirim ke backend
    document.getElementById("btnProsesRcn").addEventListener("click", async function () {
        const btnProses = document.getElementById("btnProsesRcn");
        btnProses.disabled = true;
        const list = document.getElementById("list_rcn_sukses");        
        
        const selected = Array.from(list.options)
            .map(opt => opt.value)
            .filter(value => value && value.trim() !== "" && !value.toLowerCase().includes("tidak ada"));
        
        if (selected.length === 0) {
            if (typeof showMessageDlg === "function") {
                showMessageDlg("Warning", "Tidak ada file RCN yang tersedia di dalam daftar!");
            } else {
                alert("Tidak ada file RCN yang tersedia di dalam daftar!");
            }
            btnProses.disabled = false; 
            return;
        }

        showSpinner();
        let adaGagalDb = false; 

        try {
            for (const filePath of selected) {
                const fileName = filePath.substring(filePath.lastIndexOf("/") + 1);
                const isUpperCase = filePath.endsWith(".RCN");
                const filePathCtl = filePath + (isUpperCase ? '.CTL' : '.ctl');

                const urlReadFile = contextPath + "/mon4ProsesFileRcn?act=readfilercn&file=" + encodeURIComponent(filePath);
                const res = await fetch(urlReadFile);
                const jsonResult = await res.json();

                const urlReadFileCtl = contextPath + "/mon4ProsesFileRcn?act=readfilercnctl&file=" + encodeURIComponent(filePathCtl);
                const resCtl = await fetch(urlReadFileCtl);
                const jsonResultCtl = await resCtl.json();

                if (jsonResult.status === "success" && jsonResult.fileContent && jsonResultCtl.status === "success" && jsonResultCtl.fileContent) {
                    
                    const lines = jsonResult.fileContent.split(/\r?\n/);
                    const finalJsonArray = [];
                    const currentTimestamp = new Date().toISOString().replace('T', ' ').substring(0, 19); 
                    
                    lines.forEach((line) => {
                        const trimmedLine = line.trim();
                        if (trimmedLine !== "" && !trimmedLine.startsWith("NOUSULAN") && !trimmedLine.startsWith("0000000000000000001")) {
                            const columns = trimmedLine.split("|");
                            if (columns.length >= 11) {
                                finalJsonArray.push({
                                    "NOUSULAN": columns[0], "TGLUSULAN": columns[1], "VA": columns[2], "KDBANK": columns[3],
                                    "IDPEL": columns[4], "BLTH": columns[5], "RPTAG": columns[6], "RPBK": columns[7],
                                    "TGLBAYAR": columns[8], "JAMBAYAR": columns[9], "USERID": columns[10],
                                    "NAMAFILE": fileName, "TGLINSERT": currentTimestamp
                                });
                            }
                        }
                    });

                    const linesCtl = jsonResultCtl.fileContent.split(/\r?\n/);
                    let ctlObject = { "RECORD_COUNT": "0", "TOTAL_NOMINAL": "0", "NAMAFILE_CTL": filePathCtl.substring(filePathCtl.lastIndexOf("/") + 1) };
                    
                    if (linesCtl.length > 0 && linesCtl[0].trim() !== "") {
                        const ctlColumns = linesCtl[0].split("|");
                        if (ctlColumns.length >= 2) {
                            ctlObject.RECORD_COUNT = ctlColumns[0].trim();
                            ctlObject.TOTAL_NOMINAL = ctlColumns[1].trim();
                        }
                    }

                    const urlInsertDb = contextPath + "/mon4ProsesFileRcn";
                    const formData = new URLSearchParams();
                    formData.append("act", "insertdb");
                    formData.append("file", filePath); 
                    formData.append("fileCtl", filePathCtl); 
                    formData.append("jsonData", JSON.stringify(finalJsonArray)); 
                    formData.append("jsonDataCtl", JSON.stringify(ctlObject)); 

                    const dbResponse = await fetch(urlInsertDb, {
                        method: "POST",
                        headers: { "Content-Type": "application/x-www-form-urlencoded" },
                        body: formData
                    });

                    const dbJsonResult = await dbResponse.json();
                    if (dbJsonResult.status !== "success") {
                        adaGagalDb = true;
                    }
                } else {
                    adaGagalDb = true;
                }
            }

            list.innerHTML = ""; 

            if (typeof showMessageDlg === "function") {
                if (adaGagalDb) {
                    showMessageDlg("Warning", "Proses selesai dengan kendala. Silakan periksa tabel log.");
                } else {
                    showMessageDlg("Info", "Semua data dari daftar file berhasil diproses.");
                }
            }

        } catch (err) {
            console.error("❌ Terjadi kesalahan proses:", err);
        } finally {
            if (table_logrcn !== null) {
                table_logrcn.ajax.reload(function() {
                    hideSpinner();
                    btnProses.disabled = false;
                }, false);
            } else {
                hideSpinner();
                btnProses.disabled = false;
            }
        }
    });

    // Inisialisasi DataTables Server-Side
    table_logrcn = $('#logTableBody').closest('table').DataTable({
        processing: true,      
        serverSide: true,      
        scrollX: true, 
        paging: true,
        ordering: true,    
        searching: true,       
        autoWidth: false,
        info: true,
        stripeClasses: [],
        lengthMenu: [ [10, 25, 50, 100], [10, 25, 50, "100 Baris"] ],
        language: {
            // Mengubah teks bawaan saat kosong agar senada dengan markup Anda sebelumnya
            emptyTable: "Belum ada data log pemrosesan untuk hari ini. Silakan pilih berkas dan klik 'Proses Data'."
        },
        ajax: {
            url: contextPath + '/mon4ProsesFileRcn',
            type: 'POST',
            data: function (d) {
                d.act       = 'getlogdbrcn';
                let tglAwalRaw  = typeof getTglAwal === 'function' ? getTglAwal() : new Date().toISOString().slice(0,10);
                let tglAkhirRaw = typeof getTglAkhir === 'function' ? getTglAkhir() : new Date().toISOString().slice(0,10);                
                d.vtglawal  = tglAwalRaw.replace(/-/g, '');
                d.vtglakhir = tglAkhirRaw.replace(/-/g, '');
            },
            dataSrc: function (json) {
                if (json.status === "error") {
                    let errorAlert = json.message || json.dbMessage || "Gagal memuat riwayat log.";
                    if (typeof showMessageDlg === "function") {
                        showMessageDlg("Warning", errorAlert);
                    } else {
                        alert(errorAlert);
                    }
                    return []; 
                }
                return json.data; 
            },
            error: function (xhr) {
                console.error("Network error dashboard log:", xhr.statusText);
            }
        },
        columns: [
            { data: 'TGLINSERT', defaultContent: '-' },
            { data: 'NAMAFILE', defaultContent: '-' },
            { data: 'PRODUK', defaultContent: '-' },
            { 
                data: 'STATUS', 
                defaultContent: '-',
                render: function(data) {
                    if (!data) return '-';
                    let uData = data.toUpperCase();
                    if(uData === 'GAGAL' || uData === 'ERROR') {
                        return '<span class="text-red-600 font-bold">GAGAL</span>';
                    }
                    return '<span class="text-green-600 font-semibold">' + data + '</span>';
                }
            },
            { data: 'MESSAGE', defaultContent: '-' }
        ],
        columnDefs: [
            { targets: '_all', className: 'text-center px-4 py-2 text-xs text-gray-700' }
        ],
        headerCallback: function(thead) {
            $(thead).find('th').css({
                'font-weight': 'bold',
                'text-align': 'center',
                'vertical-align': 'middle'
            });
        }
    });

});
</script>