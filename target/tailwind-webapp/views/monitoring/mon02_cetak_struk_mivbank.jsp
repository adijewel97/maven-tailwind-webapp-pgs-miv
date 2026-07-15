<!-- ========================= SCRIPT ========================= -->
<!-- ========================= SCRIPT ========================= -->
<script>
document.addEventListener("DOMContentLoaded", function () {

    function getContextPath() {
        return '<%= request.getContextPath() %>';
    }

    // Fungsi pembantu untuk menampilkan/menyembunyikan spinner secara aman
    function showSpinner() { 
        const spinner = document.getElementById('spinnerOverlay');
        if (spinner) spinner.style.display = 'flex'; 
    }
    
    function hideSpinner() { 
        const spinner = document.getElementById('spinnerOverlay');
        if (spinner) spinner.style.display = 'none'; 
    }

    // -----------------------------------------------------
    // 0) Inisialisasi Instance Select2 (Gunakan jQuery secara aman)
    // -----------------------------------------------------
    function initSelect2Elements() {
        const $bank = $('#bank_miv');
        const $diswil = $('#diswil');
        const $up3 = $('#up3');

        if ($bank.length) $bank.select2({ placeholder: "-- Pilih Bank MIV --", allowClear: true, width: '100%' });
        if ($diswil.length) $diswil.select2({ placeholder: "-- Pilih Distribusi/Wilayah --", allowClear: true, width: '100%' });
        if ($up3.length) $up3.select2({ placeholder: "-- Pilih UP3 --", allowClear: true, width: '100%' });
    }

    // -------------------------
    // 1) Load FTP files (AJAX)
    // -------------------------
    async function loadStrukFiles() {
        const loading = document.getElementById('loading');
        const list = document.getElementById('thelist');
        const blnUsulan = document.getElementById("bln_usulan");
        const bankMiv = document.getElementById("bank_miv");
        const diswilEl = document.getElementById("diswil");
        const up3El = document.getElementById("up3");
        const idTransEl = document.getElementById("id_transaksi");

        if (!blnUsulan || !bankMiv || !list) {
            alert("Komponen form tidak lengkap di halaman!");
            return;
        }

        showSpinner();
        if (loading) {
            loading.style.display = 'block';
            loading.textContent = "Memuat daftar file dari FTP...";
        }
        list.innerHTML = '';

        try {
            const raw = blnUsulan.value;
            const thblalp = convertBulanTahunToYYYYMM(raw);
            const bank_miv = bankMiv.value;
            const diswil = diswilEl ? diswilEl.value : '';
            const up3 = up3El ? up3El.value : '';
            const idTransaksiFilter = idTransEl ? idTransEl.value.trim().toUpperCase() : '';

            const url = getContextPath()
                + "/mon2strukbank?act=list"
                + "&thbl=" + encodeURIComponent(thblalp)
                + "&bankmiv=" + encodeURIComponent(bank_miv)
                + "&upi=" + encodeURIComponent(diswil)
                + "&up3=" + encodeURIComponent(up3);

            const res = await fetch(url);
            if (!res.ok) throw new Error("Gagal memuat data dari server");

            const json = await res.json();
            const files = json.files || [];
            let filteredFiles = files;

            if (idTransaksiFilter && idTransaksiFilter !== '*') {
                filteredFiles = files.filter(f => f.split('/').pop().includes(idTransaksiFilter));
            }

            if (!filteredFiles || filteredFiles.length === 0) {
                const opt = document.createElement('option');
                opt.textContent = "Tidak ada file sesuai filter.";
                list.appendChild(opt);
                return;
            }

            filteredFiles.forEach(filePath => {
                const opt = document.createElement('option');
                opt.value = filePath;
                opt.textContent = filePath.split('/').pop();
                list.appendChild(opt);
            });

            if (loading) loading.style.display = 'none';
        } catch (err) {
            if (loading) loading.innerHTML = '<span class="text-red-600">Terjadi kesalahan: ' + err.message + '</span>';
            console.error("ERROR loadStrukFiles:", err);
        } finally {
            hideSpinner();
        }
    }

    // -------------------------
    // 2) Setup Flatpickr Dinamis
    // -------------------------
    function initFlatpickr() {
        const blnUsulan = document.getElementById('bln_usulan');
        const blnUsulanValue = document.getElementById('bln_usulan_value');
        const calendarIcon = document.getElementById('calendarIcon');

        if (blnUsulan && typeof flatpickr !== "undefined") {
            const now = new Date();
            const currentYyyy = now.getFullYear();
            const currentMm = String(now.getMonth() + 1).padStart(2, '0');
            
            const namaBulanLengkap = now.toLocaleString('id-ID', { month: 'long' });
            blnUsulan.value = namaBulanLengkap + " " + currentYyyy;
            
            if (blnUsulanValue) {
                blnUsulanValue.value = currentYyyy + currentMm;
            }

            const fp = flatpickr(blnUsulan, {
                locale: "id",
                plugins: [new monthSelectPlugin({
                    shorthand: false,
                    dateFormat: "F Y",
                    altFormat: "Y-m"
                })],
                onChange: function (selectedDates) {
                    if (selectedDates && selectedDates.length > 0) {
                        const date = selectedDates[0];
                        const yyyy = date.getFullYear();
                        const mm = String(date.getMonth() + 1).padStart(2, '0');
                        if (blnUsulanValue) blnUsulanValue.value = yyyy + mm;
                    }
                }
            });

            if (calendarIcon) {
                calendarIcon.addEventListener('click', function () {
                    fp.open();
                });
            }
        }
    }

    // -------------------------
    // 3) Konversi nama bulan -> YYYYMM
    // -------------------------
    function convertBulanTahunToYYYYMM(input) {
        if (!input) return '';
        const bulanMap = {
            "Januari": "01", "Februari": "02", "Maret": "03",
            "April": "04", "Mei": "05", "Juni": "06",
            "Juli": "07", "Agustus": "08", "September": "09",
            "Oktober": "10", "November": "11", "Desember": "12"
        };
        const parts = input.split(" ");
        const bulan = bulanMap[parts[0]] || '';
        const tahun = parts[1] || '';
        return tahun + bulan;
    }

    // -------------------------
    // 4) Load Bank MIV via Select2
    // -------------------------
    async function loadBankMIV() {
        const $bankSelect = $('#bank_miv');
        if (!$bankSelect.length) return;

        const params = new URLSearchParams();
        params.append('act', 'getNamaBank');
        params.append('kdbank', '');

        try {
            const res = await fetch(getContextPath() + '/mst-global', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: params.toString()
            });
            if (!res.ok) throw new Error("HTTP Error " + res.status);
            const json = await res.json();

            $bankSelect.empty().append(new Option('-- Pilih Bank MIV --', ''));

            if (json.status === 'success' && Array.isArray(json.data)) {
                json.data.forEach(bank => {
                    $bankSelect.append(new Option(bank.NAMA_BANK, bank.KODE_ERP, false, false));
                });
                $bankSelect.trigger('change');
            } else {
                $bankSelect.append(new Option('Tidak ada data bank', '')).trigger('change');
            }
        } catch (err) {
            console.error("❌ Error JS:", err.message);
        }
    }

    // -------------------------
    // 5) Load DIS/WIL via Select2
    // -------------------------
    async function loadDisWilMIV() {
        const $diswilSelect = $('#diswil');
        if (!$diswilSelect.length) return;

        const params = new URLSearchParams();
        params.append('act', 'getNamaUnitUPI');
        params.append('kd_dist', 'ALL');

        try {
            const res = await fetch(getContextPath() + '/mst-global', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: params.toString()
            });
            if (!res.ok) throw new Error("HTTP Error " + res.status);
            const json = await res.json();

            $diswilSelect.empty().append(new Option('-- Pilih Distribusi --', ''));

            if (json.status === 'success' && Array.isArray(json.data)) {
                json.data.forEach(diswil => {
                    $diswilSelect.append(new Option(diswil.NAMA_DIST, diswil.KD_DIST, false, false));
                });
                $diswilSelect.trigger('change');
            } else {
                $diswilSelect.append(new Option('Tidak ada data DISWIL', '')).trigger('change');
            }
        } catch (err) {
            console.error("❌ Error JS:", err.message);
        }
    }

    // -------------------------
    // 6) Load UP3 berdasarkan DIS/WIL
    // -------------------------
    async function loadUP3MIV(kd_dist) {
        const $up3Select = $('#up3');
        if (!$up3Select.length) return;

        const params = new URLSearchParams();
        params.append('act', 'getNamaArea');
        params.append('kd_dist', kd_dist);

        try {
            const res = await fetch(getContextPath() + '/mst-global', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: params.toString()
            });
            if (!res.ok) throw new Error("HTTP Error " + res.status);

            const text = await res.text();
            if (!text) return;
            const json = JSON.parse(text);

            $up3Select.empty().append(new Option('-- Pilih UP3 --', ''));

            if (json.status === 'success' && Array.isArray(json.data)) {
                json.data.forEach(up3 => {
                    $up3Select.append(new Option(up3.NAMA_AREA, up3.UNITAP, false, false));
                });
                $up3Select.trigger('change');
            } else {
                $up3Select.append(new Option('Tidak ada data UP3', '')).trigger('change');
            }
        } catch (err) {
            console.error("❌ Error JS:", err.message);
            $up3Select.empty().append(new Option('-- Pilih UP3 --', '')).trigger('change');
        }
    }

    // -------------------------------------------------------------------------
    // 7) RUN ORCHESTRATION & SAFE EVENT BINDING
    //    Membungkus semua pemicu agar kebal dari Lifecycle / Delay Render JSP
    // -------------------------------------------------------------------------
    initSelect2Elements();
    initFlatpickr();
    loadBankMIV();
    loadDisWilMIV();

    // Event handler Cascading Dropdown Distribusi -> UP3 menggunakan jQuery Select2 Event
    $('#diswil').on('change', function () {
        const kd_dist = this.value;
        if (kd_dist) {
            loadUP3MIV(kd_dist);
        } else {
            $('#up3').empty().append(new Option('-- Pilih UP3 --', '')).trigger('change');
        }
    });

    // Pendelegasian Event Klik Tombol Tampilkan secara aman (Mencegah error null addEventListener)
    $(document).on('click', '#btnTampil', function () {
        const bankVal = $('#bank_miv').val();
        const diswilVal = $('#diswil').val();
        const up3Val = $('#up3').val();

        if (!bankVal || bankVal.trim() === "") {
            alert("Silakan pilih BANK MIV terlebih dahulu!");
            return;
        }
        if (!diswilVal || diswilVal.trim() === "") {
            alert("Silakan pilih DISTRIBUSI/WILAYAH terlebih dahulu!");
            return;
        }
        if (!up3Val || up3Val.trim() === "") {
            alert("Silakan pilih PILIH UP3 dahulu!");
            return;
        }

        loadStrukFiles();
    });

    // Pendelegasian Event Klik Tombol Print secara aman
    $(document).on('click', '#btnPrint', function () {
        const list = document.getElementById("thelist");
        if (!list) return;

        const selected = Array.from(list.selectedOptions).map(opt => opt.value);
        if (selected.length === 0 || selected[0] === "") {
            alert("Silakan pilih minimal 1 file PDF yang valid!");
            return;
        }

        selected.forEach((filePath, index) => {
            const safeURL = getContextPath() 
                + "/mon2strukbank?act=download&file=" 
                + encodeURIComponent(filePath);

            setTimeout(() => {
                window.open(safeURL, "_blank");
            }, index * 500);
        });
    });
});
</script>