<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%-- PERBAIKAN: Spinner non-blocking di tengah layar --%>
<div id="spinnerOverlay" class="hidden fixed inset-0 items-center justify-center z-[9999] pointer-events-none">
    <div class="bg-white p-3 rounded-xl shadow-lg flex items-center justify-center">
        <div class="spinner-border text-blue-600 animate-spin border-4 border-t-4 border-blue-600 border-opacity-20 rounded-full h-8 w-8" role="status">
            <span class="sr-only">Loading...</span>
        </div>
        <span class="ml-3 text-sm font-medium text-gray-700">Memuat data...</span>
    </div>
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

    <div class="mt-4">
        <div class="mb-2">
            <button id="btnExportMonRkpAllExcel2" class="bg-green-600 hover:bg-green-700 text-white px-3 py-2 rounded shadow flex items-center gap-2 transition duration-150 ease-in-out">
                <i class="fa-solid fa-file-excel"></i> <span>Download Excel Rekap</span>
            </button>
        </div>

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
</fieldset>

<div id="dataModal" class="fixed inset-0 bg-black bg-opacity-50 hidden items-center justify-center z-50">
    <div class="bg-white rounded-lg w-[95%] max-w-6xl max-h-[90vh] overflow-hidden flex flex-col shadow-xl">
        
        <div class="flex justify-between items-center p-4 border-b bg-gray-50">
            <h5 class="text-gray-700 font-bold text-lg">Detail Data Rekon <span id="detailTitle" class="text-blue-600 font-normal"></span></h5>
            <button id="closeModalBtn" class="text-gray-500 hover:text-gray-700 text-2xl font-bold transition duration-150 ease-in-out">&times;</button>
        </div>
        
        <div class="p-4 flex-1 overflow-auto">
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
    // --- GLOBAL VARIABLES (Diambil dari JSP context) ---
    // Pastikan jQuery sudah dimuat sebelum script ini
    
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
    let table_detail_upi = null; // Deklarasi global agar dapat diakses oleh tombol Export dan Modal
    var table; // Deklarasi global untuk table rekap

    // --- END UTILITY FUNCTIONS ---

    $(document).ready(function() { // Menggunakan jQuery $(document).ready
        // 1) --- Modal Setup ---
        const modal = $('#dataModal'); // Menggunakan jQuery
        const detailTitle = document.getElementById('detailTitle');
        
        // Menutup modal
        $('#closeModalBtn, #closeModalBtn2').on('click', function() {
            modal.removeClass('flex').addClass('hidden');
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

        $(calendarIcon).on('click', () => fp.open()); // Menggunakan jQuery

        // 3) --- DataTables Rekap (tablemon_upi) ---
        table = $('#tablemon_upi').DataTable({
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
                url: getContextPath() + '/mon-rekon-bankvsperupi',
                type: 'POST',
                data: function (d) {
                    const yyyymm = $('#bln_usulan_value').val() ? $('#bln_usulan_value').val().replace('-', '') : '';
                    d.vbln_usulan = yyyymm;
                },
                error: function (xhr, error, thrown) {
                    // Sembunyikan spinner saat error
                    $('#spinnerOverlay').removeClass('flex').addClass('hidden'); 
                    console.error("DataTables Rekap Error:", error, thrown);
                }
            },
            columns: [
                {
                    data: null,
                    render: function (data, type, row, meta) {
                        if (row.URUT != 5) {
                            return meta.row + 1;
                        } else {
                            return ''; 
                        }
                    },
                    width: '30px'
                },
                {
                    data: null,
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
                { targets: '_all', className: 'text-center border' },
                { targets: [1, 3], className: 'text-left border' },
                { targets: [5, 6, 7, 8, 9, 10, 11], className: 'text-right border' }
            ],
            createdRow: function (row, data, dataIndex) {
                if (data.URUT == 5) {
                    $(row).addClass('font-bold bg-gray-200');
                    $('td', row).css('border-top', '3px solid #000');
                }

                const clickableColumns = [5, 6, 9, 10]; 
                const columnNames = ['PLN_IDPEL', 'PLN_RPTAG', 'BANK_IDPEL', 'BANK_RPTAG'];

                $('td', row).each(function (colIndex) {
                    if (clickableColumns.includes(colIndex)) {
                        const columnIndexInArray = clickableColumns.indexOf(colIndex);
                        const columnName = columnNames[columnIndexInArray];
                        const cellValue = data[columnName];
                        
                        if (data.URUT != 5 && cellValue && parseFloat(String(cellValue).replace(/\./g, '').replace(/,/g, '.')) > 0) {
                            $(this).addClass('cursor-pointer text-blue-600 underline').off('click').on('click', function () {
                                // Set parameter filter global
                                detailFilterParams = {
                                    vbln_usulan: data.BLN_USULAN,
                                    vkd_bank: data.BANK ? data.BANK.substring(0, 3) : '',
                                    vkd_dist: data.KD_DIST,
                                    vproduk: data.PRODUK
                                };
                                
                                // Update judul modal
                                detailTitle.textContent = `${data.KD_DIST} - ${data.NAMA_DIST} (${data.BANK})`;

                                // Tampilkan Modal
                                modal.removeClass('hidden').addClass('flex');
                                
                                // Muat ulang tabel detail dengan parameter baru
                                if(table_detail_upi) {
                                    table_detail_upi.ajax.reload(() => {
                                        // PERBAIKAN: Adjust columns setelah modal terlihat dan data dimuat
                                        table_detail_upi.columns.adjust().draw(); 
                                    });
                                }
                            });
                        }
                    }
                });
            },
            dom: 'lfrtip', 
            buttons: [
                {
                    extend: 'excelHtml5',
                    title: 'MIV_REKON_REKAP_' + ($('#bln_usulan_value').val() ? $('#bln_usulan_value').val().replace('-', '') : 'ALL'),
                    className: 'd-none',
                    exportOptions: {
                        format: {
                            body: function (data, row, column, node) {
                                const columnsRaw = [5,6,7,8,9,10,11]; 
                                if (columnsRaw.includes(column)) {
                                    if (typeof data === 'string') {
                                        // Hapus format ribuan sebelum export
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
            processing: true,
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
                url: getContextPath() + '/mon-rekon-bankvsperupi-detail',
                type: 'POST',
                data: function (d) {
                    d.vbln_usulan = detailFilterParams.vbln_usulan ? detailFilterParams.vbln_usulan.replace('-', '') : ''; 
                    d.vkd_bank = detailFilterParams.vkd_bank || '';
                    d.vkd_dist = detailFilterParams.vkd_dist || '';
                    d.vproduk = detailFilterParams.vproduk || '';
                },
                error: function (xhr, error, thrown) {
                    console.error("DataTables Detail Error:", error, thrown);
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
                { targets: [10, 11, 19, 20, 25, 26], className: 'text-right border' }, 
                { targets: '_all', className: 'text-center border' }
            ],
            dom: 'Bfrtip',
            buttons: [
                {
                    extend: 'excelHtml5',
                    title: function() {
                        const bln = detailFilterParams.vbln_usulan ? detailFilterParams.vbln_usulan.replace('-', '') : 'ALL';
                        const dist = detailFilterParams.vkd_dist || 'UNDEF';
                        return `MIV_REKON_DETAIL_${dist}_${bln}`;
                    },
                    className: 'd-none',
                    exportOptions: {
                        // Export semua data dari API (server side processing)
                    }
                }
            ]
        });


        // --- Event Handlers (Spinner) ---
        // Sembunyikan/Tampilkan spinner saat request AJAX DataTables
        const spinnerOverlay = $('#spinnerOverlay');

        table.on('preXhr.dt', function () {
            spinnerOverlay.removeClass('hidden').addClass('flex');  
        });
        table.on('xhr.dt', function () {
            spinnerOverlay.removeClass('flex').addClass('hidden');   
        });

        table_detail_upi.on('preXhr.dt', function () {
            spinnerOverlay.removeClass('hidden').addClass('flex');  
        });
        table_detail_upi.on('xhr.dt', function () {
            spinnerOverlay.removeClass('flex').addClass('hidden');   
        });


        // --- Event Handlers (Tombol) ---
        
        // Trigger Tampilkan Data Rekap
        $('#btnTampil').on('click', function () {
            if (!$('#bln_usulan_value').val()) {
                alert("Silakan pilih Bulan Laporan terlebih dahulu!");
                return;
            }
            spinnerOverlay.removeClass('hidden').addClass('flex');   
            table.ajax.reload();
        });
        
        // Trigger Download Excel Rekap
        $('#btnExportMonRkpAllExcel2').on('click', function () {
            table.button(0).trigger();
        });

        // Trigger Download Excel Detail
        $('#btnExportMonDftAllExcelOneSheet').on('click', function () {
            if (table_detail_upi) {
                // Trigger button excel yang tersembunyi
                table_detail_upi.button(0).trigger(); 
            } else {
                 alert("Data detail belum dimuat.");
            }
        });
    });
</script>