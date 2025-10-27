<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // ===========================
    // ✅ Inisialisasi parameter halaman
    String currentPage = request.getParameter("page");
    if (currentPage == null || currentPage.trim().isEmpty()) {
        currentPage = "/views/dashboard/dashboard.jsp";
    }
%>

<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <title>Monitoring Rekon PLN vs Bank</title>
    <link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/jquery.dataTables.min.css">
    <link rel="stylesheet" href="https://cdn.datatables.net/responsive/2.5.0/css/responsive.dataTables.min.css">
    <script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/responsive/2.5.0/js/dataTables.responsive.min.js"></script>

    <style>
        /* =======================
           ✅ STYLE UMUM
        ========================*/
        body {
            font-family: "Segoe UI", Arial, sans-serif;
            font-size: 14px;
            margin: 0;
            background-color: #f9fafb;
        }

        fieldset {
            border: 1px solid #ccc;
            border-radius: 8px;
            padding: 16px;
            position: relative;
            background: #fff;
        }

        legend {
            font-weight: bold;
            font-size: 0.9rem;
        }

        /* =======================
           ✅ SPINNER UTAMA (Rekap)
        ========================*/
        .spinner-border {
            border: 4px solid #d1d5db;
            border-top: 4px solid #2563eb;
            border-radius: 50%;
            width: 32px;
            height: 32px;
            animation: spin 0.8s linear infinite;
        }

        .spinner-border-mini {
            border: 2px solid #d1d5db;
            border-top: 2px solid #16a34a;
            border-radius: 50%;
            width: 16px;
            height: 16px;
            animation: spin 0.8s linear infinite;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        /* =======================
           ✅ TABLE STYLE
        ========================*/
        table.dataTable th,
        table.dataTable td {
            white-space: nowrap;
            text-align: center;
            font-size: 13px;
        }

        table.dataTable thead th {
            background-color: #f3f4f6;
            font-weight: 600;
        }

        #tablemon_upi_wrapper {
            margin-top: 8px;
        }

        /* Spinner overlay di tengah tabel utama */
        #spinnerOverlayRekap {
            position: absolute;
            inset: 0;
            display: none;
            align-items: center;
            justify-content: center;
            background-color: rgba(255, 255, 255, 0.6);
            z-index: 20;
        }

        /* Spinner mini (modal) akan ditampilkan di tengah tabel detail */
        #spinnerOverlayDetail {
            position: absolute;
            inset: 0;
            display: none;
            align-items: center;
            justify-content: center;
            background-color: rgba(255, 255, 255, 0.3);
            z-index: 10;
        }
    </style>
</head>
<body>

<!-- ===============================
     ✅ FIELDSET MONITORING REKAP
=================================-->
<fieldset>
    <legend>Monitoring Rekon PLN vs Bank</legend>

    <!-- Form Filter -->
    <div class="mb-3 grid grid-cols-12 gap-3 items-center">
        <div class="col-span-3">
            <label>Jenis Data:</label>
            <select id="jenisData" class="form-control">
                <option value="rekon">Rekonsiliasi</option>
                <option value="bpbl">BPBL</option>
            </select>
        </div>
        <div class="col-span-3">
            <label>Tahun:</label>
            <input type="number" id="tahun" value="2025" class="form-control">
        </div>
        <div class="col-span-3">
            <button id="btnTampil" class="btn btn-primary mt-4">Tampilkan</button>
        </div>
    </div>

    <!-- ✅ Spinner Overlay untuk Rekap -->
    <div id="spinnerOverlayRekap">
        <div class="spinner-border"></div>
    </div>

    <!-- ✅ Tabel Rekap -->
    <div class="relative">
        <table id="tablemon_upi" class="display nowrap" style="width:100%">
            <thead>
                <tr>
                    <th>URUT</th>
                    <th>UPI</th>
                    <th>BANK</th>
                    <th>TOTAL TRANSAKSI</th>
                    <th>TOTAL NILAI</th>
                    <th>AKSI</th>
                </tr>
            </thead>
        </table>
    </div>
</fieldset>

<!-- ===============================
     ✅ MODAL DETAIL DATA
=================================-->
<div class="modal fade" id="dataModal" tabindex="-1" role="dialog" aria-labelledby="dataModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-xl" role="document">
        <div class="modal-content rounded-lg shadow">
            <div class="modal-header bg-blue-600 text-white">
                <h5 class="modal-title font-semibold" id="dataModalLabel">Detail Monitoring Rekon</h5>
                <button type="button" class="close text-white" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>

            <div class="modal-body" style="max-height: 80vh; overflow-y: auto;">
                <!-- Tombol Aksi -->
                <div class="mb-3 flex justify-between items-center">
                    <h6 class="font-semibold text-gray-700">Data Transaksi Detail</h6>
                    <div>
                        <button id="downloadMonDftExcelBtnAll" class="btn btn-success btn-sm">
                            <i class="fa fa-file-excel-o"></i> Export Semua Data
                        </button>
                    </div>
                </div>

                <!-- ✅ Wrapper tabel dengan spinner mini -->
                <div class="relative">
                    <div id="spinnerOverlayDetail" class="hidden absolute inset-0 flex items-center justify-center z-10 bg-white bg-opacity-30">
                        <div class="spinner-border-mini"></div>
                    </div>

                    <!-- ✅ Tabel Detail -->
                    <table id="table_mondaf_upi" class="display nowrap" style="width:100%">
                        <thead>
                            <tr>
                                <th>NO</th>
                                <th>IDPEL</th>
                                <th>NAMA</th>
                                <th>UPI</th>
                                <th>BANK</th>
                                <th>TGL BAYAR</th>
                                <th>NILAI</th>
                                <th>STATUS</th>
                                <th>KETERANGAN</th>
                            </tr>
                        </thead>
                    </table>
                </div>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Tutup</button>
            </div>
        </div>
    </div>
</div>

<script>
$(document).ready(function() {

    // ===========================
    // ✅ 1. Inisialisasi DataTables Rekap
    // ===========================
    var tableRekap = $('#tablemon_upi').DataTable({
        processing: true,
        serverSide: true,
        ajax: {
            url: '/api/rekon/list', // 🔧 Ganti sesuai endpoint kamu
            type: 'POST',
            data: function(d) {
                d.jenis = $('#jenisData').val();
                d.tahun = $('#tahun').val();
            }
        },
        columns: [
            { data: 'URUT', className: 'text-center' },
            { data: 'UPI' },
            { data: 'BANK' },
            { data: 'TOTAL_TRANSAKSI', className: 'text-right' },
            { data: 'TOTAL_NILAI', className: 'text-right' },
            {
                data: null,
                orderable: false,
                render: function(data, type, row) {
                    return '<button class="btn btn-sm btn-info btnDetail" data-upi="'+row.UPI+'" data-bank="'+row.BANK+'">Detail</button>';
                }
            }
        ],
        responsive: true,
        language: { emptyTable: "Tidak ada data ditemukan" }
    });

    // ===========================
    // ✅ 2. Spinner untuk DataTables Rekap
    // ===========================
    tableRekap.on('preXhr.dt', function() {
        $('#spinnerOverlayRekap').css('display', 'flex');
    });
    tableRekap.on('xhr.dt', function() {
        $('#spinnerOverlayRekap').hide();
    });

    // Tombol Tampilkan
    $('#btnTampil').on('click', function() {
        tableRekap.ajax.reload();
    });

    // ===========================
    // ✅ 3. Modal Detail - Inisialisasi DataTables Detail
    // ===========================
    var tableDetail = $('#table_mondaf_upi').DataTable({
        processing: true,
        serverSide: true,
        ajax: {
            url: '/api/rekon/detail', // 🔧 Ganti sesuai endpoint kamu
            type: 'POST',
            data: function(d) {
                d.upi = $('#dataModal').data('upi');
                d.bank = $('#dataModal').data('bank');
            }
        },
        columns: [
            { data: 'NO', className: 'text-center' },
            { data: 'IDPEL' },
            { data: 'NAMA' },
            { data: 'UPI' },
            { data: 'BANK' },
            { data: 'TGL_BAYAR', className: 'text-center' },
            { data: 'NILAI', className: 'text-right' },
            { data: 'STATUS', className: 'text-center' },
            { data: 'KETERANGAN' }
        ],
        responsive: true,
        language: { emptyTable: "Tidak ada data detail ditemukan" }
    });

    // ===========================
    // ✅ 4. Spinner Mini di Modal
    // ===========================
    tableDetail.on('preXhr.dt', function() {
        $('#spinnerOverlayDetail').css('display', 'flex');
    });
    tableDetail.on('xhr.dt', function() {
        $('#spinnerOverlayDetail').hide();
    });

    // ===========================
    // ✅ 5. Event Klik Tombol Detail
    // ===========================
    $('#tablemon_upi').on('click', '.btnDetail', function() {
        const upi = $(this).data('upi');
        const bank = $(this).data('bank');

        // simpan data di modal
        $('#dataModal').data('upi', upi);
        $('#dataModal').data('bank', bank);

        // ubah judul modal
        $('#dataModalLabel').text('Detail Rekon - ' + upi + ' | ' + bank);

        // tampilkan modal
        $('#dataModal').modal('show');

        // reload data detail
        tableDetail.ajax.reload();
    });

    // ===========================
    // ✅ 6. Export Excel Semua Data (Detail)
    // ===========================
    $('#downloadMonDftExcelBtnAll').on('click', function() {
        const upi = $('#dataModal').data('upi');
        const bank = $('#dataModal').data('bank');
        const jenis = $('#jenisData').val();
        const tahun = $('#tahun').val();

        const url = `/api/rekon/export?upi=${upi}&bank=${bank}&jenis=${jenis}&tahun=${tahun}`;
        window.open(url, '_blank');
    });

});
</script>

</body>
</html>
