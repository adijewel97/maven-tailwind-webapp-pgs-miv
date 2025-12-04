<%@ page language="java" contentType="text/html;charset=UTF-8" %>

<!-- GLOBAL MODAL MESSAGE -->
<div id="globalMessageModal" class="hidden fixed inset-0 bg-gray-900 bg-opacity-50 
            justify-center items-center z-50">
    <div class="bg-white rounded-2xl shadow-lg w-96">
        <div class="px-6 py-3 border-b">
            <h2 class="text-lg font-semibold text-gray-700">Pesan</h2>
        </div>
        <div class="px-6 py-4">
            <p id="globalMessageText" class="text-gray-600">Pesan di sini</p>
        </div>
        <div class="px-6 py-3 text-right border-t">
            <button id="globalCloseModalBtn"
                class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg">
                Close
            </button>
        </div>
    </div>
</div>

<script>
    // ==== Fungsi untuk menampilkan modal ====
    function showMessage(text) {
        let modal = document.getElementById("globalMessageModal");
        let message = document.getElementById("globalMessageText");

        message.textContent = text;
        modal.classList.remove("hidden");
        modal.classList.add("flex");
    }

    // Close modal
    document.getElementById("globalCloseModalBtn").addEventListener("click", function () {
        let modal = document.getElementById("globalMessageModal");
        modal.classList.remove("flex");
        modal.classList.add("hidden");
    });
</script>
