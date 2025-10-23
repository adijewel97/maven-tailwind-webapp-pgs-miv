<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!-- ✅ Spinner Global -->
<div id="spinnerOverlay" class="hidden fixed top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 z-[9999]">
    <div class="spinner-border text-blue-600" role="status"></div>
</div>

<!-- Fieldset Monitoring -->
<fieldset class="border border-gray-300 rounded p-5 mt-4">
    <legend class="text-sm font-bold px-3">Monitoring Rekon PLN Vs Bank</legend>

    <div class="mt-1 relative">
        <form id="form-monitoring">
            <div class="grid grid-cols-12 gap-3 mb-2 items-end">
                <!-- Input Bulan Laporan -->
                <div class="col-span-12 md:col-span-4 lg:col-span-3">
                    <label for="bln_usulan" class="block text-gray-700 mb-1 font-medium">Bulan Laporan :</label>
                    <div class="flex border border-gray-300 rounded">
                        <input type="text" id="bln_usulan" class="flex-1 px-3 py-2 text-sm uppercase" placeholder="Pilih Bulan Laporan" readonly>
                        <span id="calendarIcon" class="px-2 flex items-center justify-center cursor-pointer">
                            <i class="fa-solid fa-calendar-alt"></i>
                        </span>
                    </div>
                </div>

                <!-- Tombol Tampilkan -->
                <div class="col-span-6 md:col-span-2">
                    <label class="block md:hidden">&nbsp;</label>
                    <button id="btnTampil" type="button" class="max-w-[120px] w-full bg-blue-600 hover:bg-blue-700 text-white font-semibold px-3 py-2 rounded shadow flex items-center justify-center gap-2">
                        <i class="fa fa-search"></i>
                        <span>Tampilkan</span>
                    </button>
                </div>
            </div>
        </form>
    </div>

    <div class="mt-4">
        <div class="mb-2">
            <button id="btnExportMonRkpAllExcel2" class="bg-green-600 hover:bg-green-700 text-white px-3 py-2 rounded shadow">
                <i class="fa-solid fa-file-excel"></i> <span>Download Excel Rekap</span>
            </button>
        </div>

        <div class="overflow-x-auto w-full">
            <table id="tablemon_upi" class="table-auto border border-gray-300 w-full text-xs">
                <thead class="bg-gray-100">
                    <tr>
                        <th class="px-2 py-1">NO</th>
                        <th class="px-2 py-1">NAMA_DIST</th>
                        <th class="px-2 py-1">PRODUK</th>
                        <th class="px-2 py-1">BANK</th>
                        <th class="px-2 py-1">BULAN</th>
                        <th class="px-2 py-1">PLN_IDPEL</th>
                        <th class="px-2 py-1">PLN_RPTAG</th>
                        <th class="px-2 py-1">PLN_LB_LUNAS</th>
                        <th class="px-2 py-1">PLN_RP_LUNAS</th>
                        <th class="px-2 py-1">BANK_IDPEL</th>
                        <th class="px-2 py-1">BANK_RPTAG</th>
                        <th class="px-2 py-1">SELISIH_RPTAG</th>
                    </tr>
                </thead>
                <tbody class="text-xs"></tbody>
            </table>
        </div>
    </div>
</fieldset>

<!-- Tombol contoh untuk membuka modal -->
<button id="openModalBtn" class="bg-blue-600 text-white px-3 py-1 rounded">Buka Modal</button>

<!-- Modal Large Tailwind -->
<div id="dataModal" class="fixed inset-0 bg-black bg-opacity-50 hidden items-center justify-center z-50">
  <div class="bg-white rounded-lg w-[95%] max-w-6xl max-h-[90vh] overflow-auto flex flex-col">
    
    <!-- Header -->
    <div class="flex justify-between items-center p-4 border-b">
      <h5 class="text-gray-700 font-semibold text-lg">Detail Data</h5>
      <button id="closeModalBtn" class="text-gray-500 hover:text-gray-700 text-2xl font-bold">&times;</button>
    </div>
    
    <!-- Body -->
    <div class="p-4 flex-1 overflow-auto">
      <!-- Tombol Export -->
      <div class="mb-2">
        <button id="btnExportMonDftAllExcelOneSheet" class="bg-green-600 hover:bg-green-700 text-white px-3 py-1 rounded shadow flex items-center gap-2">
          <i class="fa fa-file-excel-o"></i>
          <span>Export Detail Per-UPI</span>
        </button>
      </div>

      <!-- Tabel -->
      <div class="overflow-x-auto w-full">
        <table id="table_mondaf_upi" class="table-auto border border-gray-300 w-full text-xs">
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
            <!-- Data detail muncul di sini -->
          </tbody>
        </table>
      </div>
    </div>
    
    <!-- Footer -->
    <div class="p-4 border-t flex justify-end">
      <button id="closeModalBtn2" class="bg-gray-400 hover:bg-gray-500 text-white px-3 py-1 rounded">Tutup</button>
    </div>

  </div>
</div>


<script>
  // Pastikan modal tersembunyi saat halaman pertama kali load
  document.addEventListener('DOMContentLoaded', function() {
      const modal = document.getElementById('dataModal');
      modal.classList.add('hidden');

      const openBtn = document.getElementById('openModalBtn');
      const closeBtns = [document.getElementById('closeModalBtn'), document.getElementById('closeModalBtn2')];

      // Buka modal
      openBtn.addEventListener('click', () => {
          modal.classList.remove('hidden');
          modal.classList.add('flex'); // tampilkan sebagai flex
      });

      // Tutup modal
      closeBtns.forEach(btn => {
          btn.addEventListener('click', () => {
              modal.classList.add('hidden');
              modal.classList.remove('flex');
          });
      });
  });
</script>
