<%@ page language="java" contentType="text/html;charset=UTF-8" %>

<div id="globalMessageModal" class="hidden fixed inset-0 bg-gray-900 bg-opacity-50 justify-center items-center z-50">
    <div class="bg-white rounded-2xl shadow-lg w-96 mx-4">
        <div class="px-6 py-2 border-b">
            <h2 id="globalMessagelabel" class="text-base font-semibold text-gray-700 flex items-center gap-1.5">
                <span id="globalMessageIcon"></span>
                <span id="globalLabelText"></span>
            </h2>
        </div>
        <div class="px-6 py-6">
            <p id="globalMessageText" class="text-gray-600 whitespace-pre-line text-sm">Pesan di sini</p>
        </div>
        <div class="px-6 py-2 text-right border-t">
            <button id="globalCloseModalBtn"
                class="bg-blue-600 hover:bg-blue-700 text-white text-sm px-3 py-1.5 rounded-lg transition duration-150">
                Close
            </button>
        </div>
    </div>
</div>

<script>
    // ==== Fungsi Utama (Case Insensitive & Fleksibel) ====
    function showMessageDlg(label, text) {
        // Jika parameter kedua kosong, asumsikan parameter pertama adalah text
        if (text === undefined) {
            text = label;
            label = "Info";
        }

        let modal = document.getElementById("globalMessageModal");
        let messageLabel = document.getElementById("globalMessagelabel");
        let messageIcon = document.getElementById("globalMessageIcon");
        let labelText = document.getElementById("globalLabelText");
        let messageText = document.getElementById("globalMessageText");

        if (modal && messageLabel && messageIcon && labelText && messageText) {
            let icon = "";
            let cleanLabel = label.trim().toLowerCase();

            // Tentukan Ikon, Warna Teks Label, dan Perkecil Ukuran Ikon menggunakan text-xs/text-sm
            if (cleanLabel === 'warning') {
                icon = "⚠️";
                messageLabel.className = "text-base font-semibold text-amber-500 flex items-center gap-1.5";
                messageIcon.className = "text-sm"; // Ukuran ikon diperkecil dari text-base ke text-sm
            } else if (cleanLabel === 'error') {
                icon = "❌"; 
                messageLabel.className = "text-base font-semibold text-red-600 flex items-center gap-1.5";
                messageIcon.className = "text-xs"; // Tanda silang (x) seringkali terlihat besar, jadi pakai text-xs
            } else {
                icon = "ℹ️"; 
                messageLabel.className = "text-base font-semibold text-blue-700 flex items-center gap-1.5";
                messageIcon.className = "text-sm"; // Ukuran info diperkecil
            }

            // Memasukkan data ke elemen masing-masing
            messageIcon.textContent = icon;
            labelText.textContent = label;
            messageText.textContent = text;
            
            modal.classList.remove("hidden");
            modal.classList.add("flex");
        } else {
            // Fallback jika DOM belum siap
            alert(label + ": " + text);
        }
    }

    // ==== Alias / Mapping Fungsi ====
    const showmessagedlg = showMessageDlg;
    const showMessage = showMessageDlg;

    // ==== Fungsi Menutup Modal ====
    function closeGlobalModal() {
        let modal = document.getElementById("globalMessageModal");
        if (modal) {
            modal.classList.remove("flex");
            modal.classList.add("hidden");
        }
    }

    // Event Listener Klik Tombol Close
    document.getElementById("globalCloseModalBtn").addEventListener("click", closeGlobalModal);

    // Event Listener keyboard 'Escape' untuk menutup modal
    document.addEventListener("keydown", function (e) {
        if (e.key === "Escape") {
            closeGlobalModal();
        }
    });
</script>