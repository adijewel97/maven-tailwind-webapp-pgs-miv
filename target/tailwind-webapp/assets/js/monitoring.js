$(document).ready(function () {

    function getContextPath() {
        return window.location.pathname.substring(0, window.location.pathname.indexOf("/", 2));
    }

    function formatNumber(value, fractionDigits = 2) {
        if (!value) return '';
        const n = parseFloat(value);
        if (isNaN(n)) return value;
        return n.toLocaleString('id-ID', { minimumFractionDigits: fractionDigits, maximumFractionDigits: fractionDigits });
    }

    // Inisialisasi Flatpickr
    flatpickr("#bln_usulan", {
        locale: flatpickr.l10ns.id,
        plugins: [new monthSelectPlugin({ shorthand: false, theme: "light" })],
        dateFormat: "Y-m",
        altInput: true,
        altFormat: "F Y",
        defaultDate: new Date()
    });

    // Inisialisasi DataTable
    let table = null;
    if ($('#tablemon_upi').length) {
        if ($.fn.DataTable.isDataTable('#tablemon_upi')) $('#tablemon_upi').DataTable().destroy();
        table = $('#tablemon_upi').DataTable({
            serverSide: true,
            scrollX: true,
            ajax: {
                url: getContextPath() + '/mon-rekon-bankvsperupi',
                type: 'POST',
                data: function(d){ d.vbln_usulan = $('#bln_usulan').val().replace('-', ''); }
            },
            columns: [
                { data: null, render: (data,type,row,meta) => row.KD_DIST ? meta.row + 1 : '' },
                { data: null, render: (data,type,row) => row.KD_DIST ? row.KD_DIST+' - '+row.NAMA_DIST : '' },
                { data: 'PRODUK', defaultContent: '' },
                { data: 'BANK', defaultContent: '' },
                { data: 'BLN_USULAN', defaultContent: '' },
                { data: 'PLN_IDPEL', render: d => formatNumber(d,0) },
                { data: 'PLN_RPTAG', render: d => formatNumber(d,0) },
                { data: 'PLN_LEBAR_LUNAS', render: d => formatNumber(d,0) },
                { data: 'PLN_RPTAG_LUNAS', render: d => formatNumber(d,0) },
                { data: 'BANK_IDPEL', render: d => formatNumber(d,0) },
                { data: 'BANK_RPTAG', render: d => formatNumber(d,0) },
                { data: 'SELISIH_RPTAG', render: d => formatNumber(d,0) }
            ]
        });
    }

    // Tombol Tampil
    $('#btnTampil').click(()=>{ if(table) table.ajax.reload(); });

    // Tombol Export
    $('#btnExportRekap').click(()=>{ if(table && table.button) table.button(0).trigger(); });

});
