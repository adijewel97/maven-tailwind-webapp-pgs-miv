<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<style>
/* ---------- Spinner CSS ---------- */
#spinnerOverlay {
    display: none;
    position: fixed;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    z-index: 9999;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    background-color: rgba(255,255,255,0.85);
    padding: 20px 30px;
    border-radius: 8px;
    box-shadow: 0 0 12px rgba(0,0,0,0.2);
}
#spinnerOverlay .spinner {
    border: 4px solid #3b82f6;
    border-top-color: transparent;
    border-radius: 50%;
    width: 40px;
    height: 40px;
    animation: spin 1s linear infinite;
}
#spinnerOverlay span {
    margin-top: 8px;
    font-size: 0.875rem;
    color: #333;
}
@keyframes spin { 100% { transform: rotate(360deg); } }
</style>

<!-- Spinner universal -->
<div id="spinnerOverlay">
    <div class="spinner"></div>
    <span>Loading...</span>
</div>

<!-- FORM FILTER -->
<div class="flex justify-center">
    <fieldset class="border rounded p-5 mt-4 w-full mx-auto bg-white shadow text-left">
        <legend class="text-sm font-bold px-3 text-left">Monitoring File Bank MIV</legend>
        <form id="form-monitoring" class="w-full">
            <div class="grid grid-cols-12 gap-3 mb-2 w-full md:w-[1000px]">
                
                <!-- Bulan Laporan -->
                <div class="col-span-12 md:col-span-3">
                    <label for="bln_usulan" class="block text-gray-700 mb-1 font-medium">Bulan Laporan :</label>
                    <div class="flex border border-gray-300 rounded items-center">
                        <input type="text" id="bln_usulan" class="flex-1 px-3 py-2 text-sm uppercase focus:outline-none focus:ring-1 focus:ring-blue-500" placeholder="Pilih Bulan Laporan" readonly>
                        <i id="calendarIcon" class="fa fa-calendar text-gray-500 px-3 cursor-pointer hover:text-blue-600"></i>
                    </div>
                    <input type="hidden" id="bln_usulan_value" name="bln_usulan_value">
                </div>

                <!-- Bank MIV -->
                <div class="col-span-12 md:col-span-3">
                    <label for="bank_miv" class="block text-gray-700 mb-1 font-medium">Bank MIV :</label>
                    <select id="bank_miv" name="bank_miv" class="w-full border border-gray-300 rounded px-3 py-2 text-sm focus:ring-1 focus:ring-blue-500">
                        <option value="">-- Pilih Bank MIV --</option>
                    </select>
                </div>

                <!-- Jenis File TXT/RCN -->
                <div class="col-span-12 md:col-span-2">
                    <label for="idtxt_rcn" class="block text-gray-700 mb-1 font-medium">Jenis File:</label>
                    <select id="idtxt_rcn" class="w-full border border-gray-300 rounded px-3 py-2 text-sm focus:ring-1 focus:ring-blue-500">
                        <option value="TXT">TXT -  File Dari AP2T</option>
                        <option value="RCN">RCN -  File Dari BANK</option>
                    </select>
                </div>

                <!-- IdTransaksi / Nousulan -->
                <div class="col-span-12 md:col-span-4">
                    <label for="idtrans" class="block text-gray-700 mb-1 font-medium">IdTransaksi / Nousulan:</label>
                    <div class="flex">
                        <input type="text" id="idtrans" placeholder="* = Semua / ID tertentu" class="flex-1 bg-gray-100 border rounded-l px-3 py-2 text-sm focus:outline-none focus:ring-1 focus:ring-blue-500">
                    </div>
                </div>

                <!-- Tombol Tampilkan di tengah form -->
                <div class="col-span-12 flex justify-center mt-2">
                    <button type="button" id="btnTampil" class="bg-blue-600 text-white rounded px-6 py-2 text-sm">
                        Tampilkan
                    </button>
                </div>

            </div>
        </form>
    </fieldset>
</div>

<!-- Daftar TXT/RCN Sukses/Gagal -->
<div class="grid grid-cols-1 md:grid-cols-2 gap-6 mt-4">
    <fieldset class="border rounded p-5 bg-white shadow text-center">
        <h3 id="label_sukses">📂 Daftar Sukses</h3>
        <select id="list_sukses" size="10" class="border rounded w-full p-2" multiple></select>
        <button type="button" id="btnPrint_sukses" class="mt-2 bg-green-600 text-white rounded px-3 py-1 w-full">Download</button>
    </fieldset>

    <fieldset class="border rounded p-5 bg-white shadow text-center">
        <h3 id="label_gagal">📂 Daftar Gagal</h3>
        <select id="list_gagal" size="10" class="border rounded w-full p-2" multiple></select>
        <button type="button" id="btnPrint_gagal" class="mt-2 bg-green-600 text-white rounded px-3 py-1 w-full">Download</button>
    </fieldset>
</div>

<script>
document.addEventListener("DOMContentLoaded", function(){

    const contextPath = '<%= request.getContextPath() %>';
    const spinner = document.getElementById('spinnerOverlay');

    function showSpinner(){ spinner.style.display='flex'; }
    function hideSpinner(){ spinner.style.display='none'; }

    // ---------- Flatpickr Bulan Laporan ----------
    const blnUsulan = document.getElementById('bln_usulan');
    const blnUsulanValue = document.getElementById('bln_usulan_value');
    const calendarIcon = document.getElementById('calendarIcon');

    if (typeof flatpickr !== "undefined") {
        const fp = flatpickr(blnUsulan, {
            plugins: [new monthSelectPlugin({
                shorthand: false,
                dateFormat: "F Y",
                altFormat: "Y-m"
            })],
            defaultDate: new Date(),
            onChange: function(selectedDates) {
                const date = selectedDates[0];
                if(date){
                    const yyyy = date.getFullYear();
                    const mm = String(date.getMonth()+1).padStart(2,'0');
                    blnUsulanValue.value = yyyy + mm;
                }
            },
            onReady: function(selectedDates) {
                const date = selectedDates[0] || new Date();
                const yyyy = date.getFullYear();
                const mm = String(date.getMonth()+1).padStart(2,'0');
                blnUsulanValue.value = yyyy + mm;
                blnUsulan.value = date.toLocaleString('id-ID', { month: 'long' }) + ' ' + yyyy;
            }
        });

        calendarIcon.addEventListener('click', ()=>fp.open());
    }

    function convertBulanTahunToYYYYMM(input){
        const bulanMap = { "Januari":"01","Februari":"02","Maret":"03","April":"04","Mei":"05","Juni":"06",
                           "Juli":"07","Agustus":"08","September":"09","Oktober":"10","November":"11","Desember":"12" };
        const parts = input.split(" ");
        return parts[1] + bulanMap[parts[0]];
    }

    // ---------- Load master data ----------
    async function loadBankMIV(){
        try{
            const res = await fetch(contextPath+'/mst-global',{
                method:'POST',
                headers:{'Content-Type':'application/x-www-form-urlencoded'},
                body:'act=getNamaBank&kdbank='
            });
            const json = await res.json();
            const sel = document.getElementById('bank_miv');
            sel.innerHTML='<option value="">-- Pilih Bank MIV --</option>';
            if(json.status==='success' && Array.isArray(json.data)){
                json.data.forEach(b=>{
                    const opt=document.createElement('option');
                    opt.value=b.KODE_ERP; opt.textContent=b.NAMA_BANK;
                    sel.appendChild(opt);
                });
            }
        }catch(err){ console.error(err); }
    }

    // ---------- Load file TXT/RCN ----------
    async function loadFtpFiles(){
        const thbl = blnUsulanValue.value;
        const bank = document.getElementById('bank_miv').value;
        const jenis = document.getElementById('idtxt_rcn').value;
        const idtrans = document.getElementById('idtrans').value.trim();

        showSpinner();
        const listSukses = document.getElementById('list_sukses');
        const listGagal = document.getElementById('list_gagal');
        listSukses.innerHTML=''; listGagal.innerHTML='';

        try{
            const url = contextPath + '/mon3ChekFileTxt'
                + '?act=' + (jenis==='TXT'?'listtxt':'listrcn')
                + '&thbl=' + encodeURIComponent(thbl)
                + '&bankmiv=' + encodeURIComponent(bank)
                + '&idtrans=' + encodeURIComponent(idtrans);

            const res = await fetch(url);
            if(!res.ok) throw new Error("Gagal memuat data dari server");
            const json = await res.json();

            if(json.listSukses && json.listSukses.length>0) json.listSukses.forEach(f=>listSukses.appendChild(new Option(f,f)));
            else listSukses.appendChild(new Option("Tidak ada file sukses"));

            if(json.listGagal && json.listGagal.length>0) json.listGagal.forEach(f=>listGagal.appendChild(new Option(f,f)));
            else listGagal.appendChild(new Option("Tidak ada file gagal"));

        }catch(err){
            listSukses.appendChild(new Option("Error: "+err.message));
            listGagal.appendChild(new Option("Error: "+err.message));
        }finally{
            hideSpinner();
        }
    }

    // ---------- Download file ----------
    function downloadFiles(listId){
        const list = document.getElementById(listId);
        Array.from(list.selectedOptions).forEach((filePath,index)=>{
            setTimeout(()=>{
                const a=document.createElement('a');
                a.href = contextPath + '/mon3ChekFileTxt?act=download&file=' + encodeURIComponent(filePath.value);
                a.target='_blank';
                document.body.appendChild(a); a.click(); a.remove();
            }, index*300);
        });
    }

    // ---------- Event ----------
    document.getElementById('btnTampil').addEventListener('click', loadFtpFiles);
    document.getElementById('btnPrint_sukses').addEventListener('click', ()=>downloadFiles('list_sukses'));
    document.getElementById('btnPrint_gagal').addEventListener('click', ()=>downloadFiles('list_gagal'));

    // ---------- Load awal ----------
    loadBankMIV();
});
</script>
