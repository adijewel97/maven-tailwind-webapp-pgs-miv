<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - MIV PLN P2APST</title>

    <!-- TailwindCSS CDN -->
    <link href="${pageContext.request.contextPath}/assets/css/style_tailwind_adis.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
</head>
<body class="bg-gradient-to-br from-cyan-500 to-teal-600 min-h-screen flex items-center justify-center">

<!-- Container utama -->
<div class="flex flex-col md:flex-row bg-white shadow-2xl rounded-2xl overflow-hidden w-full max-w-4xl mx-4">

    <!-- Kiri: Informasi Login -->
    <div class="hidden md:flex w-1/2 bg-gradient-to-br from-teal-600 to-cyan-500 text-white flex-col justify-center items-center p-8">
        <i class="fa fa-shield-alt text-6xl mb-4"></i>
        <!-- <h2 class="text-2xl font-bold mb-2">Selamat Datang di WebApp \n MIV - PLN P2APST</h2> -->
         <h2 class="text-2xl font-bold mb-2 whitespace-pre-line">
            Webapp MIV - P2APST
        </h2>
        <p class="text-center text-sm leading-relaxed text-teal-100">
            Sistem ini digunakan untuk monitoring Untuk Pelanggan PLN MIV - Management Instansi Vertikal.  
            Pastikan kredensial Anda valid untuk mengakses sistem ini.
        </p>
        <div class="mt-6 border-t border-teal-300 w-1/2"></div>
        <p class="text-xs mt-4 text-teal-200">Keamanan data Anda adalah prioritas kami 🔒</p>
    </div>

    <!-- Kanan: Form Login -->
    <div class="w-full md:w-1/2 p-8 flex flex-col justify-center">
        <div class="text-center mb-6">
            <img src="${pageContext.request.contextPath}/assets/img/logo.png" class="mx-auto w-16 mb-3" alt="Logo">
            <h1 class="text-2xl font-bold text-gray-800">Login Aplikasi</h1>
            <p class="text-gray-500 text-sm">Masuk untuk melanjutkan</p>
        </div>

        <!-- Form Login -->
        <form id="loginForm" action="${pageContext.request.contextPath}/LoginServlet" method="post" class="space-y-5">

            <div>
                <label for="username" class="block text-gray-600 text-sm font-semibold mb-1">Username</label>
                <div class="flex items-center border border-gray-300 rounded-lg px-3 focus-within:ring-2 focus-within:ring-teal-400">
                    <i class="fa fa-user text-gray-400 mr-2"></i>
                    <input id="username" name="username" type="text" class="w-full p-2 focus:outline-none text-gray-700" placeholder="Masukkan username">
                </div>
            </div>

            <div>
                <label for="password" class="block text-gray-600 text-sm font-semibold mb-1">Password</label>
                <div class="flex items-center border border-gray-300 rounded-lg px-3 focus-within:ring-2 focus-within:ring-teal-400">
                    <i class="fa fa-lock text-gray-400 mr-2"></i>
                    <input id="password" name="password" type="password" class="w-full p-2 focus:outline-none text-gray-700" placeholder="Masukkan password">
                </div>
            </div>

            <button type="submit" id="loginBtn"
                class="w-full bg-teal-600 hover:bg-teal-700 text-white font-semibold py-2 rounded-lg transition duration-200">
                <i class="fa fa-sign-in mr-1"></i> Login
            </button>
        </form>

        <p class="text-center text-gray-500 text-xs mt-6">© 2025 by Mang Adis</p>
    </div>
</div>

<!-- Modal Message -->
<div id="messageModal" class="hidden fixed inset-0 bg-gray-900 bg-opacity-50 justify-center items-center z-50">
    <div class="bg-white rounded-2xl shadow-lg w-96">
        <div class="px-6 py-3 border-b">
            <h2 class="text-lg font-semibold text-gray-700">Pesan</h2>
        </div>
        <div class="px-6 py-4">
            <p id="messageText" class="text-gray-600">Pesan di sini</p>
        </div>
        <div class="px-6 py-3 text-right border-t">
            <button id="closeModalBtn" class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg">Close</button>
        </div>
    </div>
</div>

<!-- Script -->
<script>
    // Validasi input kosong
    document.getElementById("loginForm").addEventListener("submit", function(e) {
        const user = document.getElementById("username").value.trim();
        const pass = document.getElementById("password").value.trim();

        if (user === "" || pass === "") {
            e.preventDefault(); // hentikan submit
            const modal = document.getElementById("messageModal");
            const modalText = document.getElementById("messageText");
            modalText.textContent = "User ID/Password tidak boleh kosong";
            modal.classList.remove("hidden");
            modal.classList.add("flex");
        }
    });

    // Close modal
    document.getElementById("closeModalBtn").addEventListener("click", function() {
        const modal = document.getElementById("messageModal");
        modal.classList.remove("flex");
        modal.classList.add("hidden");
    });

    // Tampilkan modal jika login gagal (error=1)
    const urlParams = new URLSearchParams(window.location.search);
    // if (urlParams.get("error") === "1") {
    //     const modal = document.getElementById("messageModal");
    //     const modalText = document.getElementById("messageText");
    //     modalText.textContent = "Username atau password salah!";
    //     modal.classList.remove("hidden");
    //     modal.classList.add("flex");
    // }
    if (urlParams.has("error")) {
        const modal = document.getElementById("messageModal");
        const modalText = document.getElementById("messageText");
        modalText.textContent = "Username atau password salah!";
        modal.classList.remove("hidden");
        modal.classList.add("flex");
    }

</script>

</body>
</html>
