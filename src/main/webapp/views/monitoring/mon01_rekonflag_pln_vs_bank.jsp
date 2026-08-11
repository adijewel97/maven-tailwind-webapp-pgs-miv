<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<style>
    /* CSS TABLE REKAP - SAMAKAN DENGAN TABEL DETAIL */
    #table_monrkp_rekonupi {
        table-layout: auto;
        font-size: 0.75rem;
        width: 100%;
    }

    #table_monrkp_rekonupi th,
    #table_monrkp_rekonupi td {
        font-size: 0.7rem;
        padding: 4px 6px;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }

    #table_monrkp_rekonupi th.sorting::after,
    #table_monrkp_rekonupi th.sorting_asc::after,
    #table_monrkp_rekonupi th.sorting_desc::after {
        display: none !important;
    }

    #table_monrkp_rekonupi_wrapper .dataTables_scrollBody {
        max-height: 65vh;
        overflow-y: auto;
    }

    /* Header DataTables Detail */
    #table_mondaf_rekonupi thead th,
    #table_mondaf_rekonupi.dataTable thead th,
    #table_mondaf_rekonupi.dataTable thead td {
        font-weight: 700 !important;
        text-align: center !important;
        vertical-align: middle !important;
    }

    /* CSS MODAL SHOW TABLE MONITORING DETAIL */
    #dataModal .modal-body {
        font-size: 0.75rem;
    }

    #dataModal table th,
    #dataModal table td {
        font-size: 0.7rem;
        padding: 4px 6px;
        white-space: nowrap;
    }

    #dataModal table {
        table-layout: auto;
    }

    .form-monitoring {
        position: relative;
    }

    .loading-overlay {
        position: absolute;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        z-index: 1050;
        text-align: center;
        font-size: 0.95rem;
    }

    .modal-xxl {
        max-width: 98% !important;
    }

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
        height: 36px !important;
    }

    #bln_usulanAndCalendarWrapper {
        height: 38px !important;
    }

    #loadingSpinner {
        display: none;
        position: fixed;
        top: 20%;
        left: 50%;
        transform: translate(-50%, 0);
        z-index: 9999;
        padding: 20px 30px;
        border-radius: 6px;
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

<!-- ✅ Spinner universal -->
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
                <!-- Bulan Laporan -->
                <div class="col-span-12 md:col-span-3">
                    <label for="bln_usulan" class="block text-gray-700 mb-1 font-medium">Bulan Laporan :</label>
                    <div id="bln_usulanAndCalendarWrapper" class="flex border border-gray-300 rounded items-center h-[38px] bg-white">
                        <input type="text" id="bln_usulan"
                            class="flex-1 px-3 py-2 text-sm uppercase focus:outline-none focus:ring-1 focus:ring-blue-500"
                            placeholder="Pilih Bulan Laporan" readonly>
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
                <table id="table_monrkp_rekonupi" class="table-auto border border-gray-300 w-full text-xs display">
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

<!-- Modal Menampilkan Detail -->
<div id="dataModal" class="fixed inset-0 bg-black bg-opacity-50 hidden items-center justify-center z-50">
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
                <table id="table_mondaf_rekonupi" class="table-auto border border-gray-300 w-full text-xs display">
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
                            <th class="px-2 py-1">PLN_NAMA</th>
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
                    <tbody class="text-xs"></tbody>
                </table>
            </div>
        </div>
        
        <div class="p-4 border-t flex justify-end bg-gray-50">
            <button id="closeModalBtn2" class="bg-gray-500 hover:bg-gray-600 text-white px-3 py-2 rounded shadow transition duration-150 ease-in-out">Tutup</button>
        </div>
    </div>
</div>

<script>
    function showSpinner() {
        const spinner = document.getElementById('spinnerOverlay');
        if (spinner) {
            spinner.classList.remove('hidden');
            spinner.classList.add('flex');
        }
    }

    function hideSpinner() {
        const spinner = document.getElementById('spinnerOverlay');
        if (spinner) {
            spinner.classList.add('hidden');
            spinner.classList.remove('flex');
        }
    }

    const CONTEXT_PATH = "${pageContext.request.contextPath}";

    function getContextPath() {
        return CONTEXT_PATH;
    }
    
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
    
    let detailFilterParams = {};
    let table_detail_upi = null;

    document.addEventListener('DOMContentLoaded', function() {
        
        // 1) Modal Setup
        const modal = document.getElementById('dataModal');
        const detailTitle = document.getElementById('detailTitle');
        const closeBtns = [document.getElementById('closeModalBtn'), document.getElementById('closeModalBtn2')];

        closeBtns.forEach(btn => {
            if(btn && modal) btn.addEventListener('click', () => {
                modal.classList.add('hidden');
                modal.classList.remove('flex');
            });
        });

        // 2) Flatpickr Month Picker
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

        if (calendarIcon) {
            calendarIcon.addEventListener('click', () => fp.open());
        }
        
        // 3) DataTables Rekap
        var table_rekap_upi = $('#table_monrkp_rekonupi').DataTable({
            processing: false,
            serverSide: true,
            scrollX: true,
            paging: false,
            ordering: false,
            searching: false, 
            autoWidth: false,
            info: false,
            stripeClasses: [],
            deferLoading: 0,
            ajax: {
                url: getContextPath() + '/mon-rekon-bankvsperupi',
                type: 'POST',
                data: function (d) {
                    const yyyymm = $('#bln_usulan_value').val();
                    d.vbln_usulan = yyyymm;
                },
                dataSrc: function (json) {
                    hideSpinner();

                    if (json.code && json.code !== 200) {
                        let errorMsg = json.code_message || "Terjadi kesalahan pada server.";
                        if (typeof showMessage === "function") {
                            showMessage("Error", errorMsg, "error");
                        } else {
                            showMessageDlg(errorMsg);
                        }
                        return []; 
                    }

                    var actualData = json.data ? json.data : json;
                    if (!Array.isArray(actualData)) {
                        console.error("Format data dari server bukan Array:", actualData);
                        return [];
                    }

                    return actualData; 
                },
                error: function (xhr, error, thrown) {
                    hideSpinner();
                    console.log("DataTables Ajax Error:", error, thrown);
                }
            },
            columns: [
                { data: null, render: function (data, type, row, meta) { return row.URUT != 5 ? meta.row + 1 : ''; } },
                { data: null, render: function (data, type, row) { const text = row.KD_DIST && row.NAMA_DIST ? row.KD_DIST + ' - ' + row.NAMA_DIST : ''; return row.URUT != 5 ? text : ''; } },
                { data: 'PRODUK', defaultContent: '' },
                { data: 'BANK', defaultContent: '' },
                { data: 'BLN_USULAN', defaultContent: '' },
                { data: 'PLN_IDPEL', render: function (data) { return formatNumber(data, 0); } },
                { data: 'PLN_RPTAG', render: function (data) { return formatNumber(data, 0); } },
                { data: 'PLN_LEBAR_LUNAS', render: function (data) { return formatNumber(data, 0); } },
                { data: 'PLN_RPTAG_LUNAS', render: function (data) { return formatNumber(data, 0); } },
                { data: 'BANK_IDPEL', render: function (data) { return formatNumber(data, 0); } },
                { data: 'BANK_RPTAG', render: function (data) { return formatNumber(data, 0); } },
                { data: 'SELISIH_RPTAG', render: function (data) { return formatNumber(data, 0); } }
            ],
            columnDefs: [
                { targets: '_all', className: 'text-center' },
                { targets: [1, 2, 3], className: '!text-left' }, 
                { targets: [5, 6, 7, 8, 9, 10, 11], className: '!text-right' }
            ],
            createdRow: function (row, data, dataIndex) {
                if (data.URUT == 5) {
                    $(row).addClass('font-bold bg-gray-200');
                    $('td', row).css('border-top', '3px solid #000');
                }
                
                const clickableColumns = [5, 6]; 
                const columnNames = ['PLN_IDPEL', 'PLN_RPTAG'];

                $('td', row).each(function (colIndex) {
                    if (clickableColumns.includes(colIndex)) {
                        const columnName = columnNames[clickableColumns.indexOf(colIndex)];
                        const cellValue = data[columnName];
                        
                        if (data.URUT != 5 && cellValue && parseFloat(String(cellValue).replace(/\./g, '').replace(/,/g, '.')) > 0) {
                            $(this).addClass('cursor-pointer text-blue-600 underline').off('click').on('click', function () {
                                detailFilterParams = {
                                    vbln_usulan: data.BLN_USULAN,
                                    vkd_bank: data.BANK ? data.BANK.substring(0, 3) : '', 
                                    vkd_dist: data.KD_DIST,
                                    vproduk: data.PRODUK
                                };
                                
                                detailTitle.textContent = "("+data.KD_DIST+" - "+data.NAMA_DIST+" | "+data.BANK+")";
                                modal.classList.remove('hidden');
                                modal.classList.add('flex');
                                
                                if(table_detail_upi) {
                                    showSpinner();
                                    table_detail_upi.ajax.reload();
                                }
                            });
                        }
                    }
                });
            },
            headerCallback: function(thead) {
                $(thead).find('th').css({
                    'font-weight': 'bold',
                    'text-align': 'center',
                    'vertical-align': 'middle'
                });
            },
            dom: 'lfrtip', 
            buttons: [{
                extend: 'excelHtml5',
                className: 'd-none',
                title: null,
                filename: function () {
                    var bln = $('#bln_usulan_value').val() || 'ALL';
                    return 'MIV_REKON_REKAP_PLN_Vs_BANK_' + bln;
                },
                exportOptions: {
                    format: {
                        body: function (data, row, column, node) {
                            const columnsRaw = [5, 6, 7, 8, 9, 10, 11]; 
                            if (columnsRaw.includes(column)) {
                                if (typeof data === 'string') {
                                    return data.replace(/\./g, '').replace(/,/g, ''); 
                                }
                            }
                            return data;
                        }
                    }
                },
                customize: function (xlsx) {
                    var sheet = xlsx.xl.worksheets['sheet1.xml'];
                    $('sheet', xlsx.xl['workbook.xml']).attr('name', 'Rekap Rekon');
                    
                    var bulan = $('#bln_usulan_value').val() || 'ALL';
                    var now = new Date();
                    var tanggalCetak =
                        ("0" + now.getDate()).slice(-2) + "-" +
                        ("0" + (now.getMonth() + 1)).slice(-2) + "-" +
                        now.getFullYear() + " " +
                        ("0" + now.getHours()).slice(-2) + ":" +
                        ("0" + now.getMinutes()).slice(-2);

                    var vawalData = 5;
                    $('row', sheet).each(function () {
                        var currentAttrRow = parseInt($(this).attr('r'));
                        var newAttrRow = currentAttrRow + vawalData; 
                        $(this).attr('r', newAttrRow);
                        
                        $('c', this).each(function () {
                            var currentAttrCell = $(this).attr('r');
                            var newAttrCell = currentAttrCell.replace(/[0-9]+/, newAttrRow);
                            $(this).attr('r', newAttrCell);
                        });
                    });

                    $('row', sheet).each(function () {
                        var isTotalRow = false;
                        $(this).find('is t').each(function () {
                            if ($(this).text().trim() === 'TOTAL') {
                                isTotalRow = true;
                                return false; 
                            }
                        });
                        if (isTotalRow) {
                            $(this).find('c').each(function () {
                                $(this).attr('s', '2'); 
                            });
                        }
                    });

                    var header =
                        '<row r="1">' +
                            '<c t="inlineStr" r="B1" s="2">' +
                                '<is><t>MANAGEMENT INSTANSI VERTIKAL</t></is>' +
                            '</c>' +
                        '</row>' +
                        '<row r="2">' +
                            '<c t="inlineStr" r="B2" s="2">' +
                                '<is><t>REKAP REKONSILIASI PLN VS BANK</t></is>' +
                            '</c>' +
                        '</row>' +
                        '<row r="3">' +
                            '<c t="inlineStr" r="B3" s="2">' +
                                '<is><t>BULAN</t></is>' +
                            '</c>' +
                            '<c t="inlineStr" r="C3" s="2">' +
                                '<is><t>: ' + bulan + '</t></is>' +
                            '</c>' +
                        '</row>' +
                        '<row r="4">' +
                            '<c t="inlineStr" r="B4" s="2">' +
                                '<is><t>TANGGAL CETAK</t></is>' +
                            '</c>' +
                            '<c t="inlineStr" r="C4" s="2">' +
                                '<is><t>: ' + tanggalCetak + '</t></is>' +
                            '</c>' +
                        '</row>' +
                        '<row r="5">' +
                            '<c t="inlineStr" r="A5">' +
                                '<is><t></t></is>' + 
                            '</c>' +
                        '</row>';

                    $('sheetData', sheet).prepend(header);
                }
            }]
        });

        // 🌟 4) DataTables Detail (table_mondaf_rekonupi) - SESUAIKAN DENGAN PENDING
        table_detail_upi = $('#table_mondaf_rekonupi').DataTable({
            processing: false,
            serverSide: true,
            scrollX: true,
            paging: true,
            ordering: false,
            searching: true, 
            autoWidth: false,
            info: true,
            stripeClasses: [],
            lengthMenu: [ [10, 25, 50, 1000], [10, 25, 50, "1000"] ],
            ajax: {
                url: getContextPath() + '/mon-rekon-bankvsperupi',
                type: 'POST',
                data: function (d) {
                    d.act         = 'detailData';
                    d.vbln_usulan = detailFilterParams.vbln_usulan || ''; 
                    d.vkd_bank    = detailFilterParams.vkd_bank || '';
                    d.vkd_dist    = detailFilterParams.vkd_dist || '';
                    d.vproduk     = detailFilterParams.vproduk || '';
                },
                dataSrc: function (json) {
                    hideSpinner();
                    
                    if (json.code && json.code !== 200) {
                        const modalDetail = document.getElementById('dataModal');
                        if (modalDetail) {
                            modalDetail.classList.add('hidden');
                            modalDetail.classList.remove('flex');
                        }
                        
                        if (typeof showMessageDlg === "function") {
                            showMessageDlg("Error", "Error " + json.code + " - " + json.code_message);
                        } else {
                            showMessageDlg("Warning", json.code_message);
                        }
                        return []; 
                    }
                    return json.data; 
                },
                error: function (xhr, error, thrown) {
                    hideSpinner();
                    let errorMsg = "Terjadi kesalahan pada detail server.";
                    showMessageDlg(errorMsg);
                }
            },
            columns: [
                { data: null, render: function (data, type, row, meta) { return meta.row + 1 + meta.settings._iDisplayStart; } },
                { data: 'PRODUK', defaultContent: '' },
                { data: 'TGLAPPROVE', defaultContent: '' },
                { data: 'KD_DIST', defaultContent: '' },
                { data: 'VA', defaultContent: '' },
                { className: 'text-left',   data: 'SATKER', defaultContent: '' },
                { data: 'PLN_NOUSULAN', defaultContent: '' },
                { data: 'PLN_IDPEL', defaultContent: '' },
                { data: 'PLN_BLTH', defaultContent: '' },
                { data: 'PLN_NAMA', defaultContent: '' },
                { data: 'PLN_LUNAS_H0', defaultContent: '' },
                { className: 'text-right',  data: 'PLN_RPTAG', render: function (data) { return formatNumber(data, 0); } },
                { className: 'text-right',  data: 'PLN_RPBK', render: function (data) { return formatNumber(data, 0); } },
                { data: 'PLN_TGLBAYAR', defaultContent: '' },
                { data: 'PLN_JAMBAYAR', defaultContent: '' },
                { data: 'PLN_USERID', defaultContent: '' },
                { data: 'PLN_KDBANK', defaultContent: '' },
                { data: 'BANK_NOUSULAN', defaultContent: '' },
                { data: 'BANK_IDPEL', defaultContent: '' },
                { data: 'BANK_BLTH', defaultContent: '' },
                { className: 'text-right',  data: 'BANK_RPTAG', render: function (data) { return formatNumber(data, 0); } },
                { className: 'text-right',  data: 'BANK_RPBK', render: function (data) { return formatNumber(data, 0); } },
                { data: 'BANK_TGLBAYAR', defaultContent: '' },
                { data: 'BANK_JAMBAYAR', defaultContent: '' },
                { data: 'BANK_USERID', defaultContent: '' },
                { data: 'BANK_KDBANK', defaultContent: '' },
                { className: 'text-right',  data: 'SELISIH_RPTAG', render: function (data) { return formatNumber(data, 0); } },
                { className: 'text-right',  data: 'SELISIH_BK', render: function (data) { return formatNumber(data, 0); } },
                { className: 'text-left',   data: 'KETERANGAN', defaultContent: '' }
            ],
            headerCallback: function(thead) {
                $(thead).find('th').css({
                    'font-weight': 'bold',
                    'text-align': 'center',
                    'vertical-align': 'middle'
                });
            },
            buttons: [
                {
                    extend: 'excelHtml5',
                    title: function() {
                        const bln = detailFilterParams.vbln_usulan || '';
                        const dist = detailFilterParams.vkd_dist || '';
                        return 'MIV_REKON_DETAIL_' + dist + '_' + bln;
                    },
                    className: 'd-none',
                    exportOptions: {
                        columns: ':visible'
                    }
                }
            ]
        });

        // 5) --- Event Handlers (Siklus Proses DataTables Spinner) ---
        table_rekap_upi.on('preXhr.dt', function() {
            showSpinner();
        }).on('xhr.dt', function() {
            hideSpinner();
        });

        $('#table_mondaf_rekonupi').on('preXhr.dt', function() {
             showSpinner();
        }).on('xhr.dt', function() {
            hideSpinner();
        });

        // 6) --- Event Handlers (Tombol) ---
        $('#btnTampil').on('click', function () {
            if (!$('#bln_usulan_value').val()) {
                showMessageDlg("Warning", "Silakan pilih Bulan Laporan terlebih dahulu!");
                return;
            }

            showSpinner();   
            table_rekap_upi.ajax.reload();
        });
        
        $('#btnExportMonRkpAllExcel2').on('click', function () {
            table_rekap_upi.button(0).trigger();
        });

        // Export Excel Detail
        const formatRibuan = (angka) => new Intl.NumberFormat('id-ID').format(angka);

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

            showSpinner();
            await new Promise(resolve => setTimeout(resolve, 30));

            btn.prop('disabled', true).html('<i class="fa fa-spinner fa-spin"></i> <span>Memuat...</span>');

            const vbln_usulan = detailFilterParams.vbln_usulan;
            const vkd_bank = detailFilterParams.vkd_bank;
            const vkd_dist = detailFilterParams.vkd_dist;
            const vproduk = detailFilterParams.vproduk || '';

            if (!vbln_usulan || !vkd_bank || !vkd_dist) {
                showMessageDlg("Warning", "Silakan lengkapi filter terlebih dahulu!");
                btn.prop('disabled', false).html('<i class="fa fa-file-excel"></i> <span>Export Detail Per-UPI</span>');
                hideSpinner();
                return;
            }

            try {
                let namaBank = await fetchNamaBank(vkd_bank);
                let namaUPI  = (vkd_dist === '00') ? '00 - SAKTI' : (await fetchNamaUnitUPI(vkd_dist));
                
                const pageSize = 1000;
                let start = 0;
                let allData = [];
                let drawCounter = 1;

                const headers = {
                    PRODUK: 'PRODUK', TGLAPPROVE: 'TGL APPROVE', KD_DIST: 'KD DIST', VA: 'VA', SATKER: 'SATKER',
                    PLN_NOUSULAN: 'PLN NO USULAN', PLN_IDPEL: 'PLN IDPEL', PLN_BLTH: 'PLN BLTH', PLN_NAMA: 'PLN NAMA', PLN_LUNAS_H0: 'PLN LUNAS H0',
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
                    totalRecords = json.recordsTotal || 0;
                    
                    if (!data || data.length === 0) break;

                    const formatted = data.map((item) => {
                        const row = {};
                        Object.keys(headers).forEach(key => {
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
                    showMessageDlg("Warning", "Tidak ada data untuk diekspor!");
                    btn.prop('disabled', false).html('<i class="fa fa-file-excel"></i> <span>Export Detail Per-UPI</span>');
                    hideSpinner();
                    return;
                }

                const now = new Date();
                const timestamp = String(now.getDate()).padStart(2, '0') + "/" + 
                                  String(now.getMonth() + 1).padStart(2, '0') + "/" + 
                                  now.getFullYear() + " " + 
                                  String(now.getHours()).padStart(2, '0') + ":" + 
                                  String(now.getMinutes()).padStart(2, '0') + ":" + 
                                  String(now.getSeconds()).padStart(2, '0');

                const workbook = new ExcelJS.Workbook();
                const worksheet = workbook.addWorksheet('Detail Rekon');

                worksheet.getCell('B1').value = "MANAGEMENT INSTANSI VERTIKAL";
                worksheet.getCell('B2').value = "DETAIL REKONSILIASI PLN VS BANK";
                worksheet.getCell('B3').value = "UID/UIW";
                worksheet.getCell('C3').value = ": " + namaUPI;
                worksheet.getCell('B4').value = "BANK MIV";
                worksheet.getCell('C4').value = ": " + vkd_bank + (namaBank ? " - " + namaBank : '');
                worksheet.getCell('B5').value = "PRODUK";
                worksheet.getCell('C5').value = ": " + vproduk;
                worksheet.getCell('B6').value = "BULAN";
                worksheet.getCell('C6').value = ": " + vbln_usulan.substring(4, 6) + '/' + vbln_usulan.substring(0, 4);
                worksheet.getCell('B7').value = "TOTAL DATA";
                worksheet.getCell('C7').value = ": " + formatRibuan(totalLoaded);
                worksheet.getCell('B8').value = "TANGGAL DOWNLOAD";
                worksheet.getCell('C8').value = ": " + timestamp;

                ['B1', 'B2'].forEach(cellRef => {
                    worksheet.getCell(cellRef).font = { bold: true, size: 12, name: 'Arial' };
                });
                for (let i = 3; i <= 8; i++) {
                    worksheet.getCell('B' + i).font = { bold: true, name: 'Arial' };
                }

                const headerKeys = Object.keys(headers);
                const tableHeaders = ['NO', ...headerKeys.map(k => headers[k])];
                const headerRow = worksheet.getRow(10);
                headerRow.values = tableHeaders;
                
                headerRow.eachCell({ includeEmpty: true }, (cell) => {
                    cell.font = { bold: true, color: { argb: 'FFFFFF' }, name: 'Arial' };
                    cell.fill = {
                        type: 'pattern',
                        pattern: 'solid',
                        fgColor: { argb: '1F4E78' }
                    };
                    cell.alignment = { horizontal: 'center', vertical: 'middle' };
                });

                allData.forEach((item, index) => {
                    const rowValues = [
                        index + 1,
                        ...headerKeys.map(key => item[key])
                    ];
                    
                    const addedRow = worksheet.addRow(rowValues);

                    addedRow.eachCell({ includeEmpty: true }, (cell, colNumber) => {
                        cell.font = { name: 'Arial', size: 10 };
                        
                        const headerKeyName = headerKeys[colNumber - 2]; 
                        if (['PLN_RPTAG', 'PLN_RPBK', 'BANK_RPTAG', 'BANK_RPBK', 'SELISIH_RPTAG', 'SELISIH_BK'].includes(headerKeyName)) {
                            cell.numFmt = '#,##0';
                            cell.alignment = { horizontal: 'right', vertical: 'middle' };
                        } else if (['SATKER', 'PLN_NAMA', 'KETERANGAN'].includes(headerKeyName)) {
                            cell.alignment = { horizontal: 'left', vertical: 'middle' };
                        } else {
                            cell.alignment = { horizontal: 'center', vertical: 'middle' };
                        }
                    });
                });

                worksheet.columns.forEach(column => {
                    let maxLen = 0;
                    column.eachCell({ includeEmpty: true }, cell => {
                        const len = cell.value ? String(cell.value).length : 10;
                        if (len > maxLen) maxLen = len;
                    });
                    column.width = Math.min(Math.max(maxLen + 3, 12), 40);
                });

                const buffer = await workbook.xlsx.writeBuffer();
                const blob = new Blob([buffer], { type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' });
                const link = document.createElement('a');
                link.href = URL.createObjectURL(blob);
                link.download = 'MIV_REKON_DETAIL_' + vkd_dist + '_' + vbln_usulan + '.xlsx';
                document.body.appendChild(link);
                link.click();
                document.body.removeChild(link);
                URL.revokeObjectURL(link.href);

            } catch (error) {
                console.error("Export Error: ", error);
                showMessageDlg("Error", "Gagal melakukan export data detail: " + error.message);
            } finally {
                btn.prop('disabled', false).html('<i class="fa fa-file-excel"></i> <span>Export Detail Per-UPI</span>');
                hideSpinner();
            }
        });
    });
</script>