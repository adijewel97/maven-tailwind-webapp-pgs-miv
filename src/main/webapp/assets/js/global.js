// ==========================
// global.js - Fungsi Utility
// ==========================

// 1) Fungsi untuk styling DataTables length & filter
function styleDataTablesLength(tableId = '#tablemon_upi') {
    // Ubah dropdown page length
    $(`${tableId}_length select`).addClass(
        'border border-gray-300 rounded px-2 py-1 bg-white focus:outline-none focus:ring-1 focus:ring-blue-500'
    );

    // Tambahkan styling untuk input filter
    $(`${tableId}_filter input`).addClass(
        'border border-gray-300 rounded-lg px-3 py-2 bg-white focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition duration-150'
    );
}

// 2) Fungsi mendapatkan context path
function getContextPath() {
    return window.location.pathname.substring(0, window.location.pathname.indexOf("/", 2));
}

// 3) Fungsi format angka ke ribuan ID
function formatNumber(value, fractionDigits = 2) {
    if (value == null || value === '') return '';
    const number = parseFloat(value);
    if (isNaN(number)) return value;
    return number.toLocaleString('id-ID', {
        minimumFractionDigits: fractionDigits,
        maximumFractionDigits: fractionDigits
    });
}

// 4) Fungsi untuk menampilkan spinner overlay (opsional)
function showSpinner(show = true) {
    const overlay = document.getElementById('spinnerOverlay');
    if (overlay) overlay.style.display = show ? 'block' : 'none';
}
