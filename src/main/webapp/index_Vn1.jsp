<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">

    <style>
        #submenu-profile {
            position: absolute;
            top: 45px;
            right: 0;
            z-index: 9999;
            transform-origin: top right;
        }
    </style>
</head>
<body class="bg-gray-100">

<!-- Header -->
<header class="bg-gray-800 text-white flex justify-between items-center px-6 py-3 relative">
    <div class="text-lg font-semibold">My App</div>

    <!-- Profil -->
    <div class="relative">
        <img src="/miv-p2apst/assets/img/profile.jpg"
             class="rounded-full cursor-pointer toggleSubmenuProfile transition-all duration-200 ease-in-out hover:scale-110 shadow-md"
             width="36" alt="Profile">
        <!-- Submenu -->
        <div id="submenu-profile"
             class="absolute right-0 mt-3 w-48 bg-gray-700 text-white rounded-md shadow-2xl z-50 transform scale-95 opacity-0 pointer-events-none transition-all duration-200 ease-out origin-top">
            <div class="text-center border-b border-gray-600 p-3">
                <p class="text-sm font-semibold">User Admin</p>
            </div>
            <a href="#" class="block px-4 py-2 text-sm hover:bg-gray-600 transition-all">Profile</a>
            <a href="/miv-p2apst/LogoutServlet" class="block px-4 py-2 text-sm hover:bg-gray-600 transition-all">Logout</a>
        </div>
    </div>
</header>

<script>
document.addEventListener("DOMContentLoaded", function () {
    const profileToggle = document.querySelector(".toggleSubmenuProfile");
    const profileMenu = document.getElementById("submenu-profile");

    if (!profileToggle || !profileMenu) {
        console.error("❌ Elemen toggle atau submenu tidak ditemukan!");
        return;
    }

    console.log("✅ Elemen ditemukan:", profileToggle, profileMenu);

    // Toggle tampil/sembunyi submenu
    profileToggle.addEventListener("click", (e) => {
        e.stopPropagation();
        console.log("🟢 Gambar profil DIKLIK");

        const isHidden = profileMenu.classList.contains("opacity-0");
        if (isHidden) {
            profileMenu.classList.remove("opacity-0", "scale-95", "pointer-events-none");
            profileMenu.classList.add("opacity-100", "scale-100", "pointer-events-auto");
            console.log("✅ Submenu profil DITAMPILKAN");
        } else {
            profileMenu.classList.add("opacity-0", "scale-95", "pointer-events-none");
            profileMenu.classList.remove("opacity-100", "scale-100", "pointer-events-auto");
            console.log("❎ Submenu profil DISEMBUNYIKAN");
        }
    });

    // Klik di luar submenu menutup menu
    document.addEventListener("click", (e) => {
        if (!profileMenu.contains(e.target) && !profileToggle.contains(e.target)) {
            profileMenu.classList.add("opacity-0", "scale-95", "pointer-events-none");
            profileMenu.classList.remove("opacity-100", "scale-100", "pointer-events-auto");
            console.log("🔘 Klik di luar -> submenu ditutup");
        }
    });
});
</script>

</body>
</html>
