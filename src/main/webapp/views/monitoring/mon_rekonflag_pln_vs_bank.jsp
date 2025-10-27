<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<style>
   /* CSS TABLE REKAP - SAMAKAN DENGAN TABEL Detail */
    #tablemon_upi {
        table-layout: auto; /* Sama seperti #dataModal table */
        font-size: 0.75rem; /* Sama dengan modal-body */
        width: 100%;
    }

    #tablemon_upi th,
    #tablemon_upi td {
        font-size: 0.7rem;      /* Sama seperti table detail */
        padding: 4px 6px;       /* Sama seperti table detail */
        white-space: nowrap;    /* Hindari wrap */
        overflow: hidden;
        text-overflow: ellipsis;
    }

    #tablemon_upi th.sorting::after,
    #tablemon_upi th.sorting_asc::after,
    #tablemon_upi th.sorting_desc::after {
        display: none !important;
    }

     /* Tambahan jika mau batas tinggi + scroll seperti modal */
    #tablemon_upi_wrapper .dataTables_scrollBody {
        max-height: 65vh;       /* Sesuaikan tinggi maksimal seperti modal */
        overflow-y: auto;
    }

    /* CSS MODAL SHOW TABLE MONITORING Detail */
    #dataModal .modal-body {
        font-size: 0.75rem; /* Ukuran teks diperkecil */
    }

    #dataModal table th,
    #dataModal table td {
        font-size: 0.7rem;   /* Ukuran teks header dan isi tabel */
        padding: 4px 6px;    /* Padding dikurangi agar tidak terlalu lebar */
        white-space: nowrap; /* Hindari pemisahan baris */
    }

    #dataModal table {
        table-layout: auto; /* Gunakan auto agar kolom menyesuaikan konten */
    }

    /* Pastikan form-container relatif */
    .form-monitoring {
        position: relative;
    }

    /* ✅ HAPUS .datatable-container jika tidak digunakan */
    /* .datatable-container {
        overflow-x: auto;
        width: 100%;
    } */

    /* Buat spinner tetap di tengah form tapi transparan */
    .loading-overlay {
        position: absolute;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        z-index: 1050;
        text-align: center;
        font-size: 0.95rem;
        /* Tidak ada background, padding, atau box */
    }

    /* tambah lebar large modal */
    .modal-xxl {
        max-width: 98% !important; /* Atur sesuai kebutuhan */
    }

    /* legenda tulisan hedar dan kotak  */
    .form-box {
        border: 1px solid #ddd;
        border-radius: 4px;
        padding: 20px;
        margin: 20px 0;
    }

    .form-box legend {
        font-weight: bold;
        font-size: 1rem;
    }

    .form-box fieldset {
        border: none;
        padding: 0;
        margin: 0;
    }

    #bln_usulan {
        text-transform: uppercase;
    }

    /* ----------
       Spiner css
       ----------
    */
    #loadingSpinner {
        display: none;
        position: fixed;
        top: 20%;
        left: 50%;
        transform: translate(-50%, 0);
        z-index: 9999;
        /* background-color: rgba(255, 255, 255, 0.7); */
        padding: 20px 30px;
        border-radius: 6px;
        /* box-shadow: 0 0 10px rgba(0,0,0,0.2); */
        text-align: center;
    }

    #loadingSpinner .spinner-content {
        text-align: center;
        font-size: 1.2rem;
        color: #333;
    }

    .overlay-spinner {
        position: absolute;
        top: 40%;
        left: 45%;
        z-index: 1060;
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

<fieldset class="border border-gray-300 rounded p-5 mt-4">
    <legend class="text-sm font-bold px-3">Monitoring Rekon PLN Vs Bank</legend>

    <div class="mt-1 relative">
        <form id="form-monitoring">
            <div class="grid grid-cols-12 gap-3 mb-2 items-end">
                <div class="col-span-12 md:col-span-4 lg:col-span-3">
                    <label for="bln_usulan" class="block text-gray-700 mb-1 font-medium">Bulan Laporan :</label>
                    <div class="flex border border-gray-300 rounded items-center">
                        <input 
                            type="text" 
                            id="bln_usulan" 
                            class="flex-1 px-3 py-2 text-sm uppercase focus:outline-none focus:ring-1 focus:ring-blue-500" 
                            placeholder="Pilih Bulan Laporan" 
                            readonly
                        >
                        <i id="calendarIcon" class="fa fa-calendar text-gray-500 px-3 cursor-pointer hover:text-blue-600"></i>
                    </div>
                    <input type="hidden" id="bln_usulan_value" name="bln_usulan_value">
                </div>

                <div class="col-span-6 md:col-span-2">
                    <label class="block md:hidden">&nbsp;</label>
                    <button id="btnTampil" type="button" class="max-w-[120px] w-full bg-blue-600 hover:bg-blue-700 text-white font-semibold px-3 py-2 rounded shadow flex items-center justify-center gap-2 transition duration-150 ease-in-out">
                        <i class="fa fa-search"></i>
                        <span>Tampilkan</span>
                    </button>
                </div>
            </div>
        </form>
    </div>

    <div class="mt-4 relative min-h-[150px]">
        <div class="mb-2">
            <button id="btnExportMonRkpAllExcel2" class="bg-green-600 hover:bg-green-700 text-white px-3 py-2 rounded shadow flex items-center gap-2 transition duration-150 ease-in-out">
                <i class="fa-solid fa-file-excel"></i> <span>Download Excel Rekap</span>
            </button>
        </div>


        <div class="mt-4 relative">
            <div class="overflow-x-auto w-full">
                <table id="tablemon_upi" class="table-auto border border-gray-300 w-full text-xs display">
                    <thead class="bg-gray-100">
                        <tr>
                            <th class="px-2 py-1 text-center border">NO</th>
                            <th class="px-2 py-1 text-center border">NAMA_DIST</th>
                            <th class="px-2 py-1 text-center border">PRODUK</th>
                            <th class="px-2 py-1 text-center border">BANK</th>
                            <th class="px-2 py-1 text-center border">BULAN</th>
                            <th class="px-2 py-1 text-center border">PLN_IDPEL</th>
                            <th class="px-2 py-1 text-center border">PLN_RPTAG</th>
                            <th class="px-2 py-1 text-center border">PLN_LB_LUNAS</th>
                            <th class="px-2 py-1 text-center border">PLN_RP_LUNAS</th>
                            <th class="px-2 py-1 text-center border">BANK_IDPEL</th>
                            <th class="px-2 py-1 text-center border">BANK_RPTAG</th>
                            <th class="px-2 py-1 text-center border">SELISIH_RPTAG</th>
                        </tr>
                    </thead>
                    <tbody class="text-xs"></tbody>
                </table>
            </div>
        </div>
    </div>
</fieldset>

<!-- modal menapilkan detail -->
<div id="dataModal" class="fixed inset-0 bg-black bg-opacity-50 hidden items-center justify-center z-50">
    <!-- <div class="bg-white rounded-lg w-[95%] max-w-7xl max-h-[90vh] overflow-hidden flex flex-col shadow-xl"> -->
    <div class="bg-white rounded-lg w-full max-w-full max-h-[90vh] overflow-hidden flex flex-col shadow-xl">
        <div class="flex justify-between items-center p-4 border-b bg-gray-50">
            <h5 class="text-gray-700 font-bold text-lg">Detail Data Rekon 
                <span id="detailTitle" class="text-blue-600 font-normal"></span></h5>
            <button id="closeModalBtn" class="text-gray-500 hover:text-gray-700 text-2xl font-bold transition duration-150 ease-in-out">&times;</button>
        </div>
        
        <div class="p-4 flex-1 overflow-auto relative"> 
            <div class="mb-2">
                <button id="btnExportMonDftAllExcelOneSheet" class="bg-green-600 hover:bg-green-700 text-white px-3 py-2 rounded shadow flex items-center gap-2 transition duration-150 ease-in-out">
                    <i class="fa fa-file-excel"></i>
                    <span>Export Detail Per-UPI</span>
                </button>
            </div>

            <div class="overflow-x-auto w-full">
                <table id="table_mondaf_upi" class="table-auto border border-gray-300 w-full text-xs display">
                    <thead class="bg-gray-100">
                        <tr>
                            <th class="px-2 py-1">NO</th>
                            <th class="px-2 py-1">PRODUK</th>
                            <th class="px-2 py-1">TGLAPPROVE</th>
                            <th class="px-2 py-1">KD_DIST</th>
                            <th class="px-2 py-1">VA</th>
                            <th class="px-2 py-1">SATKER</th>
                            <th class="px-2 py-1">PLN_NOUSULAN</th>
                            <th class="px-2 py-1">PLN_IDPEL</th>
                            <th class="px-2 py-1">PLN_BLTH</th>
                            <th class="px-2 py-1">PLN_LUNAS_H0</th>
                            <th class="px-2 py-1">PLN_RPTAG</th>
                            <th class="px-2 py-1">PLN_RPBK</th>
                            <th class="px-2 py-1">PLN_TGLBAYAR</th>
                            <th class="px-2 py-1">PLN_JAMBAYAR</th>
                            <th class="px-2 py-1">PLN_USERID</th>
                            <th class="px-2 py-1">PLN_KDBANK</th>
                            <th class="px-2 py-1">BANK_NOUSULAN</th>
                            <th class="px-2 py-1">BANK_IDPEL</th>
                            <th class="px-2 py-1">BANK_BLTH</th>
                            <th class="px-2 py-1">BANK_RPTAG</th>
                            <th class="px-2 py-1">BANK_RPBK</th>
                            <th class="px-2 py-1">BANK_TGLBAYAR</th>
                            <th class="px-2 py-1">BANK_JAMBAYAR</th>
                            <th class="px-2 py-1">BANK_USERID</th>
                            <th class="px-2 py-1">BANK_KDBANK</th>
                            <th class="px-2 py-1">SELISIH_RPTAG</th>
                            <th class="px-2 py-1">SELISIH_BK</th>
                            <th class="px-2 py-1">KETERANGAN</th>
                        </tr>
                    </thead>
                    <tbody class="text-xs">
                    </tbody>
                </table>
            </div>
        </div>
        
        <div class="p-4 border-t flex justify-end bg-gray-50">
            <button id="closeModalBtn2" class="bg-gray-500 hover:bg-gray-600 text-white px-3 py-2 rounded shadow transition duration-150 ease-in-out">Tutup</button>
        </div>

    </div>
</div>

<script>
    // Tampilkan spinner
    function showSpinner() {
        const spinner = document.getElementById('spinnerOverlay');
        spinner.classList.remove('hidden');
        spinner.classList.add('flex');
    }

    function hideSpinner() {
        const spinner = document.getElementById('spinnerOverlay');
        spinner.classList.add('hidden');
        spinner.classList.remove('flex');
    }

    // --- GLOBAL VARIABLES (Diambil dari JSP context) ---
    const CONTEXT_PATH = "${pageContext.request.contextPath}";

    // --- UTILITY FUNCTIONS ---
    function getContextPath() {
        return CONTEXT_PATH;
    }
    
    // Fungsi format angka (dipanggil dari DataTables render)
    function formatNumber(value, fractionDigits = 0) {
        if (value === null || value === undefined || String(value).trim() === '') return '0';
        
        let cleanValue = String(value).replace(/\./g, '').replace(/,/g, '.');

        const number = parseFloat(cleanValue);
        if (isNaN(number)) return value;

        return number.toLocaleString('id-ID', {
            minimumFractionDigits: fractionDigits,
            maximumFractionDigits: fractionDigits
        });
    }
    
    // Parameter global untuk transfer data dari tabel Rekap ke tabel Detail
    let detailFilterParams = {};
    let table_detail_upi = null; // Deklarasi global agar dapat diakses oleh tombol Export

    // --- END UTILITY FUNCTIONS ---

    document.addEventListener('DOMContentLoaded', function() {
        // Mendapatkan referensi spinner
        const spinnerRekap = $('#spinnerOverlay');
        const spinnerDetail = $('#spinnerOverlay');
        
        // 1) --- Modal Setup ---
        const modal = document.getElementById('dataModal');
        const detailTitle = document.getElementById('detailTitle');
        const closeBtns = [document.getElementById('closeModalBtn'), document.getElementById('closeModalBtn2')];

        closeBtns.forEach(btn => {
            if(btn && modal) btn.addEventListener('click', () => {
                modal.classList.add('hidden');
                modal.classList.remove('flex');
            });
        });

        // 2) --- Flatpickr Month Picker ---
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
            onChange: function(selectedDates, dateStr, instance) {
                const date = selectedDates[0];
                if(date) {
                    const yyyy = date.getFullYear();
                    const mm = String(date.getMonth() + 1).padStart(2,'0');
                    blnUsulanValue.value = yyyy+mm;
                }
            },
            onReady: function(selectedDates, dateStr, instance) {
                const date = selectedDates[0];
                if(date) {
                    const yyyy = date.getFullYear();
                    const mm = String(date.getMonth() + 1).padStart(2,'0');
                    blnUsulanValue.value = yyyy+mm;
                }
            }
        });

        calendarIcon.addEventListener('click', () => fp.open());
        
        // 3) --- DataTables Rekap (tablemon_upi) ---
        var table = $('#tablemon_upi').DataTable({
            processing: false,
            serverSide: true,
            scrollX: true, 
            paging: false,
            ordering: false,
            searching: false, 
            autoWidth: false,
            info: false,
            stripeClasses: [],
            ajax: {
                url: getContextPath() + '/mon-rekon-bankvsperupi', // Ganti dengan URL Servlet yang benar
                type: 'POST',
                data: function (d) {
                    // Ambil dari hidden input (YYYYMM)
                    const yyyymm = $('#bln_usulan_value').val();
                    d.vbln_usulan = yyyymm;
                },
                error: function (xhr, error, thrown) {
                    spinnerRekap.removeClass('flex').addClass('hidden'); 
                    // Tambahkan notifikasi error jika perlu
                }
            },
            columns: [
                {
                    data: null, // NO
                    render: function (data, type, row, meta) {
                        // Hanya tampilkan nomor jika bukan baris total (URUT 5)
                        if (row.URUT != 5) {
                            return meta.row + 1;
                        } else {
                            return ''; 
                        }
                    },
                    width: '30px'
                },
                {
                    data: null, // NAMA_DIST
                    render: function (data, type, row) {
                        const text = row.KD_DIST && row.NAMA_DIST ? row.KD_DIST + ' - ' + row.NAMA_DIST : '';
                        return row.URUT == 5 ? `<strong>TOTAL</strong>` : text;
                    },
                    width: '250px'
                },
                { data: 'PRODUK', defaultContent: '', width: '80px' },
                { data: 'BANK' , defaultContent: '', width: '200px'},
                { data: 'BLN_USULAN', defaultContent: '', width: '70px' },
                // Angka
                { data: 'PLN_IDPEL', render: function (data) { return formatNumber(data, 0); }, width: '100px' },
                { data: 'PLN_RPTAG', render: function (data) { return formatNumber(data, 0); }, width: '120px' },
                { data: 'PLN_LEBAR_LUNAS', render: function (data) { return formatNumber(data, 0); }, width: '100px' },
                { data: 'PLN_RPTAG_LUNAS', render: function (data) { return formatNumber(data, 0); }, width: '120px' },
                { data: 'BANK_IDPEL', render: function (data) { return formatNumber(data, 0); }, width: '100px' },
                { data: 'BANK_RPTAG', render: function (data) { return formatNumber(data, 0); }, width: '120px' },
                { data: 'SELISIH_RPTAG', render: function (data) { return formatNumber(data, 0); }, width: '120px' }
            ],
            columnDefs: [
                { targets: '_all', className: 'text-center' },
                { targets: [1, 3], className: 'text-left' },
                { targets: [5, 6, 7, 8, 9, 10, 11], className: 'text-right' }
            ],
            createdRow: function (row, data, dataIndex) {
                // Styling untuk baris TOTAL
                if (data.URUT == 5) {
                    $(row).addClass('font-bold bg-gray-200');
                    $('td', row).css('border-top', '3px solid #000');
                }

                // Logic untuk klik/link
                // const clickableColumns = [5, 6, 9, 10]; // Index kolom: PLN_IDPEL, PLN_RPTAG, BANK_IDPEL, BANK_RPTAG
                // const columnNames = ['PLN_IDPEL', 'PLN_RPTAG', 'BANK_IDPEL', 'BANK_RPTAG'];
                const clickableColumns = [5, 6]; // Index kolom: PLN_IDPEL, PLN_RPTAG
                const columnNames = ['PLN_IDPEL', 'PLN_RPTAG'];

                $('td', row).each(function (colIndex) {
                    if (clickableColumns.includes(colIndex)) {
                        const columnName = columnNames[clickableColumns.indexOf(colIndex)];
                        const cellValue = data[columnName];
                        
                        // Cek jika nilainya > 0 dan bukan baris total (URUT 5)
                        if (data.URUT != 5 && cellValue && parseFloat(String(cellValue).replace(/\./g, '').replace(/,/g, '.')) > 0) {
                            $(this).addClass('cursor-pointer text-blue-600 underline').off('click').on('click', function () {
                                // Set parameter filter global
                                detailFilterParams = {
                                    vbln_usulan: data.BLN_USULAN,
                                    vkd_bank: data.BANK ? data.BANK.substring(0, 3) : '', // Ambil 3 karakter pertama bank
                                    vkd_dist: data.KD_DIST,
                                    vproduk: data.PRODUK
                                };
                                
                                // Update judul modal
                                detailTitle.textContent = "("+data.KD_DIST+" - "+data.NAMA_DIST+" | "+data.BANK+")";

                                // Tampilkan Modal
                                modal.classList.remove('hidden');
                                modal.classList.add('flex');
                                
                                // Muat ulang tabel detail dengan parameter baru
                                if(table_detail_upi) {
                                    // Tampilkan spinner detail saat memuat ulang
                                    spinnerDetail.removeClass('hidden').addClass('flex');
                                    table_detail_upi.ajax.reload();
                                }
                            });
                        }
                    }
                });
            },
            // Konfigurasi Export
            dom: 'lfrtip', 
            buttons: [
                {
                    extend: 'excelHtml5',
                    title: 'MIV_REKON_REKAP_' + ($('#bln_usulan_value').val() ? $('#bln_usulan_value').val() : 'ALL'),
                    className: 'd-none',
                    exportOptions: {
                        format: {
                            body: function (data, row, column, node) {
                                // Kolom angka (index 5 sampai 11) di-export tanpa format ribuan
                                const columnsRaw = [5,6,7,8,9,10,11]; 
                                if (columnsRaw.includes(column)) {
                                    if (typeof data === 'string') {
                                        // Hapus format ribuan (titik) sebelum diekspor
                                        return data.replace(/\./g, '').replace(/,/g, ''); 
                                    }
                                }
                                return data;
                            }
                        }
                    }
                }
            ] 
        });

        // 4) --- DataTables Detail (table_mondaf_upi) ---
        table_detail_upi = $('#table_mondaf_upi').DataTable({
            processing: false, // Diganti dengan spinner manual
            serverSide: true,
            scrollX: true, 
            paging: true,
            ordering: false,
            searching: false, 
            autoWidth: false,
            info: true,
            stripeClasses: [],
            lengthMenu: [ [10, 25, 50, -1], [10, 25, 50, "All"] ],
            ajax: {
                url: getContextPath() + '//mon-rekon-bankvsperupi', // Perlu dicek apakah URL ini benar untuk detail
                type: 'POST',
                data: function (d) {
                    // Gunakan parameter yang disimpan dari klik rekap
                    d.act       = 'detailData';
                    d.vbln_usulan = detailFilterParams.vbln_usulan || ''; 
                    d.vkd_bank  = detailFilterParams.vkd_bank || '';
                    d.vkd_dist  = detailFilterParams.vkd_dist || '';
                    d.vproduk   = detailFilterParams.vproduk || '';
                },
                error: function (xhr, error, thrown) {
                    spinnerDetail.removeClass('flex').addClass('hidden');
                    // Handle error detail
                }
            },
            columns: [
                { data: null, render: function (data, type, row, meta) { return meta.row + 1 + meta.settings._iDisplayStart; } },
                { data: 'PRODUK', defaultContent: '' },
                { data: 'TGLAPPROVE', defaultContent: '' },
                { data: 'KD_DIST', defaultContent: '' },
                { data: 'VA', defaultContent: '' },
                { data: 'SATKER', defaultContent: '' },
                { data: 'PLN_NOUSULAN', defaultContent: '' },
                { data: 'PLN_IDPEL', defaultContent: '' },
                { data: 'PLN_BLTH', defaultContent: '' },
                { data: 'PLN_LUNAS_H0', defaultContent: '' },
                { data: 'PLN_RPTAG', render: function (data) { return formatNumber(data, 0); } },
                { data: 'PLN_RPBK', render: function (data) { return formatNumber(data, 0); } },
                { data: 'PLN_TGLBAYAR', defaultContent: '' },
                { data: 'PLN_JAMBAYAR', defaultContent: '' },
                { data: 'PLN_USERID', defaultContent: '' },
                { data: 'PLN_KDBANK', defaultContent: '' },
                { data: 'BANK_NOUSULAN', defaultContent: '' },
                { data: 'BANK_IDPEL', defaultContent: '' },
                { data: 'BANK_BLTH', defaultContent: '' },
                { data: 'BANK_RPTAG', render: function (data) { return formatNumber(data, 0); } },
                { data: 'BANK_RPBK', render: function (data) { return formatNumber(data, 0); } },
                { data: 'BANK_TGLBAYAR', defaultContent: '' },
                { data: 'BANK_JAMBAYAR', defaultContent: '' },
                { data: 'BANK_USERID', defaultContent: '' },
                { data: 'BANK_KDBANK', defaultContent: '' },
                { data: 'SELISIH_RPTAG', render: function (data) { return formatNumber(data, 0); } },
                { data: 'SELISIH_BK', render: function (data) { return formatNumber(data, 0); } },
                { data: 'KETERANGAN', defaultContent: '' }
            ],
            columnDefs: [
                { targets: [10, 11, 19, 20, 25, 26], className: 'text-right' }, // Kolom angka
                { targets: '_all', className: 'text-center' }
            ],
            // Konfigurasi Export Detail
            dom: 'Bfrtip',
            buttons: [
                {
                    extend: 'excelHtml5',
                    title: function() {
                        const bln = detailFilterParams.vbln_usulan || 'ALL';
                        const dist = detailFilterParams.vkd_dist || 'UNDEF';
                        return `MIV_REKON_DETAIL_${dist}_${bln}`;
                    },
                    className: 'd-none',
                    exportOptions: {
                        // Export semua kolom
                    }
                }
            ]
        });


        // 5) --- Event Handlers (Spinner) ---
        // Spinner Rekap (hanya untuk area tabel rekap)
        // table.on('preXhr.dt', function () {
        //     spinnerRekap.removeClass('hidden').addClass('flex');  
        // });

        table.on('preXhr.dt', function() {
            showSpinner();
        }).on('xhr.dt', function() {
            hideSpinner();
        });

        table.on('xhr.dt', function () {
            spinnerRekap.removeClass('flex').addClass('hidden');   
        });


        // Spinner Detail (hanya untuk area modal detail)
        $('#table_mondaf_upi').on('preXhr.dt', function() {
             showSpinner();
        }).on('xhr.dt', function() {
            hideSpinner();
        });


        // 6) --- Event Handlers (Tombol) ---       
        // ---------------------------------------------------------------------------------------------
        // 1A-1) Tampilkan monitoring Rekap
        // ---------------------------------------------------------------------------------------------
        $('#btnTampil').on('click', function () {
            if (!$('#bln_usulan_value').val()) {
                alert("Silakan pilih Bulan Laporan terlebih dahulu!");
                return;
            }
            // Tampilkan spinner Rekap secara manual sebelum reload
            spinnerRekap.removeClass('hidden').addClass('flex');   
            table.ajax.reload();
        });
        
        // Trigger Download Excel Rekap
        $('#btnExportMonRkpAllExcel2').on('click', function () {
            table.button(0).trigger();
        });

        // ----------------------------------------------------------------------------
        // 1B-2) Export ke exel semua data MON Detail
        // ----------------------------------------------------------------------------
        // Fungsi format angka ribuan (lokal Indonesia)
        const formatRibuan = (angka) => new Intl.NumberFormat('id-ID').format(angka);

        // Ambil nama Bank MIV dari DB
        async function fetchNamaBank(kodeBank) {
            const params = new URLSearchParams();
            params.append('act', 'getNamaBank');
            params.append('kdbank', kodeBank);

            const response = await fetch(getContextPath() + '/mon-rekon-bankvsperupi', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: params.toString()
            });

            if (!response.ok) throw new Error("Gagal mengambil data bank");

            const json = await response.json();
            if (json.status !== 'success') return '';

            return json.data.NAMA_BANK || '';
        }

        // Ambil nama UID/UIW PLN MIV dari DB
        async function fetchNamaUnitUPI(kd_dist) {
            const params = new URLSearchParams();
            params.append('act', 'getNamaUnitUPI');
            params.append('kd_dist', kd_dist);

            const response = await fetch(getContextPath() + '/mon-rekon-bankvsperupi', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: params.toString()
            });

            if (!response.ok) throw new Error("Gagal mengambil data UNITUPI");

            const json = await response.json();
            if (json.status !== 'success') return '';

            return json.data.NAMA_DIST || '';
        }

        $('#btnExportMonDftAllExcelOneSheet').on('click', async function () {
            const btn = $(this);
            let totalLoaded = 0;

            spinnerDetail.removeClass('hidden').addClass('flex');
            await new Promise(resolve => setTimeout(resolve, 30));

            btn.prop('disabled', true).html('<i class="fa fa-spinner fa-spin"></i> <span>Memuat... (' + formatRibuan(totalLoaded) + " data)</span>");

            const vbln_usulan = detailFilterParams.vbln_usulan;
            const vkd_bank = detailFilterParams.vkd_bank;
            const vkd_dist = detailFilterParams.vkd_dist;
            const vproduk = detailFilterParams.vproduk;

            if (!vbln_usulan || !vkd_bank || !vkd_dist) {
                alert('Silakan lengkapi filter terlebih dahulu!');
                btn.prop('disabled', false).html('<i class="fa fa-file-excel"></i> <span>Export Detail Per-UPI</span>');
                spinnerDetail.removeClass('flex').addClass('hidden');
                return;
            }

            let namaBank = '';
            let namaUPI  = '';
            try {
                namaBank = await fetchNamaBank(vkd_bank);
                if (vkd_dist === '00') {
                    namaUPI  = '00 - SAKTI'
                } else {
                    namaUPI  = (await fetchNamaUnitUPI(vkd_dist));
                }
                const pageSize = 1000;
                let start = 0;
                let allData = [];
                let drawCounter = 1;

                const headers = {
                    PRODUK: 'PRODUK', TGLAPPROVE: 'TGL APPROVE', KD_DIST: 'KD DIST', VA: 'VA', SATKER: 'SATKER',
                    PLN_NOUSULAN: 'PLN NO USULAN', PLN_IDPEL: 'PLN IDPEL', PLN_BLTH: 'PLN BLTH', PLN_LUNAS_H0: 'PLN LUNAS H0',
                    PLN_RPTAG: 'PLN RPTAG', PLN_RPBK: 'PLN RPBK', PLN_TGLBAYAR: 'PLN TGL BAYAR', PLN_JAMBAYAR: 'PLN JAM BAYAR',
                    PLN_USERID: 'PLN USER ID', PLN_KDBANK: 'PLN KD BANK', BANK_NOUSULAN: 'BANK NO USULAN',
                    BANK_IDPEL: 'BANK IDPEL', BANK_BLTH: 'BANK BLTH', BANK_RPTAG: 'BANK RPTAG', BANK_RPBK: 'BANK RPBK',
                    BANK_TGLBAYAR: 'BANK TGL BAYAR', BANK_JAMBAYAR: 'BANK JAM BAYAR', BANK_USERID: 'BANK USER ID', BANK_KDBANK: 'BANK KD BANK',
                    SELISIH_RPTAG: 'SELISIH RPTAG', SELISIH_BK: 'SELISIH BK', KETERANGAN: 'KETERANGAN'
                };
                
                let totalRecords = 0;

                while (true) {
                    const params = new URLSearchParams();
                    params.append('act', 'detailData');
                    params.append('vbln_usulan', vbln_usulan);
                    params.append('vkd_bank', vkd_bank);
                    params.append('vkd_dist', vkd_dist);
                    params.append('vproduk', vproduk);
                    params.append('start', start);
                    params.append('length', pageSize);
                    params.append('draw', drawCounter++);
                    params.append('order[0][column]', '0');
                    params.append('order[0][dir]', 'asc');
                    params.append('columns[0][data]', 'KD_DIST');
                    params.append('search[value]', '');

                    const response = await fetch(getContextPath() + '/mon-rekon-bankvsperupi', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                        body: params.toString()
                    });

                    if (!response.ok) {
                        const errorText = await response.text();
                        throw new Error('Status: ' + response.status + '\n' + errorText);
                    }

                    const json = await response.json();
                    const data = json.data;
                    totalRecords = json.recordsTotal;
                    
                    if (!data || data.length === 0) break;

                    const formatted = data.map((item) => {
                        const row = {};
                        Object.keys(headers).forEach(key => {
                            // Cek jika field adalah angka, biarkan sebagai angka (Excel akan memformatnya)
                            if (['PLN_RPTAG', 'PLN_RPBK', 'BANK_RPTAG', 'BANK_RPBK', 'SELISIH_RPTAG', 'SELISIH_BK'].includes(key)) {
                                row[key] = parseFloat(String(item[key] || '0').replace(/\./g, '').replace(/,/g, '.')) || 0;
                            } else {
                                row[key] = String(item[key] || '');
                            }
                        });
                        return row;
                    });

                    allData = allData.concat(formatted);
                    totalLoaded += data.length;
                    
                    btn.html('<i class="fa fa-spinner fa-spin"></i> <span>Memuat... (' + formatRibuan(totalLoaded) + "/" + formatRibuan(totalRecords) + " data)</span>");
                    await new Promise(resolve => setTimeout(resolve, 10));

                    if (data.length < pageSize || totalLoaded >= totalRecords) break;

                    start += pageSize;
                }

                if (allData.length === 0) {
                    alert('Tidak ada data untuk diekspor!');
                    return;
                }

                // --- Proses Excel Export (Menggunakan SheetJS/js-xlsx) ---
                // Asumsi Anda sudah memiliki library SheetJS (xlsx.full.min.js) di halaman Anda
                
                const Workbook = XLSX.utils.book_new();
                
                // Buat timestamp dan judul
                const now = new Date();
                const dd = String(now.getDate()).padStart(2, '0');
                const mm = String(now.getMonth() + 1).padStart(2, '0');
                const yyyy = now.getFullYear();
                const hh = String(now.getHours()).padStart(2, '0');
                const mi = String(now.getMinutes()).padStart(2, '0');
                const ss = String(now.getSeconds()).padStart(2, '0');
                const timestamp = dd + "/" + mm + "/" + yyyy + " " + hh + ":" + mi + ":" + ss;
                
                // Susun data untuk Header Informasi
                const headerInfo = [
                    ["MIV REKON DETAIL"],
                    ["BULAN", ": "+ vbln_usulan.substring(4, 6) + '/' + vbln_usulan.substring(0, 4) ],
                    ["UID/UIW", ": "+ namaUPI ],
                    ["BANK MIV", ": " + vkd_bank + (namaBank ? " - " + namaBank : '') ],
                    ["PRODUK", ": " + vproduk ],
                    ["TOTAL DATA", ": " + formatRibuan(totalLoaded) ],
                    ["TANGGAL DOWNLOAD", ": "+ timestamp],
                    [] // Baris kosong sebelum header tabel
                ];
                
                // Konversi data array ke format sheet
                const ws_info = XLSX.utils.aoa_to_sheet(headerInfo);

                // Tambahkan header tabel (kolom NO manual)
                const ws_data = [
                    ['NO', ...Object.values(headers)] 
                ];

                // Tambahkan data detail
                allData.forEach((row, index) => {
                    const dataRow = [index + 1];
                    Object.keys(headers).forEach(key => {
                        dataRow.push(row[key]);
                    });
                    ws_data.push(dataRow);
                });
                
                // Konversi data tabel ke format sheet
                const ws_table = XLSX.utils.aoa_to_sheet(ws_data);
                
                // Gabungkan kedua sheet (info dan data)
                XLSX.utils.sheet_add_aoa(ws_info, ws_data, { origin: "A10" }); // Mulai data tabel dari baris A10
                
                // Styling (opsional, hanya untuk sel tertentu)
                // ws_info['A1'].s = { font: { bold: true, sz: 14 } }; // Judul
                // for (let i = 0; i < 7; i++) {
                //     ws_info['A' + (i + 2)].s = { font: { bold: true } }; // Label info
                // }
                
                // Tambahkan sheet ke Workbook
                XLSX.utils.book_append_sheet(Workbook, ws_info, "Detail Rekon");

                // Nama File
                const fileName = `MIV_REKON_DETAIL_${vkd_dist}_${vbln_usulan}.xlsx`;
                
                // Tulis dan download file
                XLSX.writeFile(Workbook, fileName);

            } catch (error) {
                console.error("Error during full export:", error);
                alert('Gagal mengekspor data: ' + error.message);
            } finally {
                btn.prop('disabled', false).html('<i class="fa fa-file-excel"></i> <span>Export Detail Per-UPI</span>');
                spinnerDetail.removeClass('flex').addClass('hidden');
            }
        });
    });
</script>