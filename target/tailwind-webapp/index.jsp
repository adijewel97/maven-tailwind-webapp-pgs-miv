<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // ===================================================
    // ✅ PERBAIKAN 1: AUTHORIZATION CHECK KRUSIAL
    // Memeriksa apakah sesi 'username' ada. Jika tidak, redirect ke login.
    // ===================================================
    if (session.getAttribute("username") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return; // Hentikan pemrosesan halaman
    }
    // ===================================================

    // Logic menentukan halaman & menu aktif
    String currentPage = request.getParameter("page");
    String currentMenu = request.getParameter("menu");

    if (currentPage == null || currentPage.trim().isEmpty()) {
        currentPage = "/views/dashboard/dashboard.jsp";
    }

    if (currentMenu == null || currentMenu.trim().isEmpty()) {
        request.setAttribute("menu", "dashboard");
    } else {
        request.setAttribute("menu", currentMenu);
    }
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <title>MIV Dashboard</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="0" />

    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style_tailwind_adis.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/dataTables/css/jquery.dataTables.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/dataTables/css/buttons.dataTables.min.css">

    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/themes/material_blue.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/plugins/monthSelect/style.css">

    <style>
        html, body {
            font-size: 13px;
            line-height: 1.5;
            color: #374151;
            font-family: 'Inter', Arial, sans-serif;
            background-color: #f3f4f6;
            overflow-x: hidden; /* Pertahankan ini agar seluruh halaman tidak bergeser */
        }

        #sidebar {
            width: 16rem;
            font-size: 12.5px;
            transition: width 0.3s ease;
            background-color: #1f2937;
            overflow-y: auto;
            scrollbar-width: thin;
        }

        #sidebar.collapsed { width: 4rem; }
        #sidebar.collapsed .sidebar-text, #sidebar.collapsed .submenu { display: none; }

        .content-card { padding: 1.5rem !important; }
        .navbar { height: 50px; }

        main { transition: margin-left 0.3s ease; }
        main.ml-64 { margin-left: 16rem; }
        main.ml-16 { margin-left: 4rem; }

        /* Submenu Profil CSS (tidak diubah) */
        #submenu-profile::before {
            content: "";
            position: absolute;
            top: -6px;
            right: 16px;
            border-width: 6px;
            border-style: solid;
            border-color: transparent transparent #374151 transparent;
            opacity: 0;
            transform: translateY(-4px);
            transition: all 0.2s ease-out;
        }
        #submenu-profile.show::before {
            opacity: 1;
            transform: translateY(0);
        }

        /* Overlay Sidebar Mobile CSS (tidak diubah) */
        #sidebar-overlay {
            display: none;
            position: fixed;
            inset: 0;
            background: rgba(0, 0, 0, 0.45);
            z-index: 30;
            opacity: 0;
            transition: opacity 0.3s ease;
        }
        #sidebar-overlay.show {
            display: block;
            opacity: 1;
        }
        #submenu-profile {
            position: absolute;
            top: 45px;
            right: 0;
            z-index: 9999;
        }

        /* --- */
        :root {
            --footer-height: 60px; /* tinggi footer default (bisa ubah di sini) */
        }

        /* Supaya konten panjang tetap muncul penuh */
        #mainContentCard {
            overflow: visible;
        }

        /* Saat sidebar overlay muncul di mobile, footer tetap di bawah tapi tidak di atas overlay */
        #sidebar-overlay.show + main #mainFooter {
            z-index: 20;
        }

        /* Footer link warna */
        #mainFooter a {
            color: #0891b2;
        }
        #mainFooter a:hover {
            text-decoration: underline;
        }

    </style>
</head>

<body class="min-h-screen flex flex-col">

    <nav class="fixed top-0 left-0 right-0 bg-cyan-600 navbar z-50 flex items-center justify-between px-4 shadow-lg">
        <i class="toggleSidebar fa-solid fa-bars text-white cursor-pointer text-xl hover:text-cyan-200 transition"></i>

        <span class="text-white text-sm font-bold truncate">MIV - Management Instansi Vertikal</span>

        <div class="relative">
            <img src="${pageContext.request.contextPath}/assets/img/profile.jpg"
                 class="rounded-full cursor-pointer toggleSubmenuProfile transition-all duration-200 ease-in-out hover:scale-110 shadow-md"
                 width="36" alt="Profile">

            <div id="submenu-profile"
                 class="absolute right-0 mt-3 w-48 bg-gray-700 text-white rounded-md shadow-2xl z-50
                         transform scale-95 opacity-0 pointer-events-none transition-all duration-200 ease-out origin-top">
                <div class="text-center border-b border-gray-600 p-3">
                    <span class="block text-sm font-semibold">${sessionScope.username}</span>
                    <span class="block text-xs text-gray-300">${sessionScope.userRole}</span>
                </div>
                <a href="#" class="block px-4 py-2 text-sm hover:bg-gray-600 transition-all">
                    <i class="fa-solid fa-gear mr-2"></i> Setting
                </a>
                <a href="${pageContext.request.contextPath}/LogoutServlet" class="block px-4 py-2 text-sm hover:bg-gray-600 transition-all">
                    <i class="fa-solid fa-right-from-bracket mr-2"></i> Logout
                </a>
            </div>
        </div>
    </nav>

    <div class="flex h-screen overflow-hidden" style="padding-top: 50px;">
        <aside id="sidebar" class="fixed top-[50px] left-0 h-full w-64 text-gray-100 hidden md:flex flex-col z-40">
            <jsp:include page="/views/templates/sidebar.jsp" />
        </aside>

        <div id="sidebar-overlay"></div>

        <main id="mainContent"
            class="ml-64 bg-gray-100 flex flex-col min-h-screen p-4 transition-all duration-300 ease-in-out relative">

            <!-- ✅ Wrapper agar konten tidak tertutup footer -->
            <div id="mainContentWrapper" class="pb-[var(--footer-height,60px)]">
                <div id="mainContentCard" class="bg-white rounded-xl shadow content-card w-full mb-4 overflow-visible">
                    <jsp:include page="<%= currentPage %>" />
                </div>
            </div>

            <!-- ✅ Footer adaptif, menempel di bawah -->
            <footer id="mainFooter"
                    class="fixed bottom-0 left-0 right-0 bg-gray-200 border-t border-gray-300 
                        flex items-center justify-center text-xs text-gray-600 z-40 transition-all duration-300"
                    style="height: 30px">
                    <!-- style="height: var(--footer-height, 10px);"> -->
                <strong>MangAdi&copy; 2025 
                    <a href="#" class="text-cyan-600 hover:underline">MIV</a>.
                </strong> All rights reserved.
            </footer>

        </main>

    </div>

    <script src="${pageContext.request.contextPath}/assets/js/jquery-3.7.1.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/dataTables/js/jquery.dataTables.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/dataTables/js/dataTables.buttons.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/dataTables/js/buttons.html5.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/dataTables/js/jszip.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>
    <script src="https://npmcdn.com/flatpickr/dist/l10n/id.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/flatpickr/dist/plugins/monthSelect/index.js"></script>
    <script src="${pageContext.request.contextPath}/assets/excel/js/xlsx.full.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/style_tailwind_adis.js"></script>

    <script>
        document.addEventListener("DOMContentLoaded", function () {
            const sidebar = document.getElementById('sidebar');
            const main = document.getElementById('mainContent');
            const sidebarOverlay = document.getElementById('sidebar-overlay');
            const profileToggle = document.querySelector(".toggleSubmenuProfile");
            const profileMenu = document.getElementById("submenu-profile");
            const footer = document.getElementById("mainFooter");

            // Asumsikan div konten utama memiliki ID, atau kita seleksi berdasarkan class unik.
            // Berdasarkan struktur HTML Anda, konten card adalah anak pertama dari main.
            const mainContentCard = main.querySelector('.content-card'); 

            // ===================================================
            // 1. Logic Profile Menu 
            // ===================================================
            if (profileToggle && profileMenu) {
                function toggleProfileMenu(show) {
                    const isVisible = (typeof show === 'boolean') ? show : !profileMenu.classList.contains("opacity-100");
                    profileMenu.classList.toggle("opacity-100", isVisible);
                    profileMenu.classList.toggle("scale-100", isVisible);
                    profileMenu.classList.toggle("pointer-events-auto", isVisible);
                    
                    profileMenu.classList.toggle("opacity-0", !isVisible);
                    profileMenu.classList.toggle("scale-95", !isVisible);
                    profileMenu.classList.toggle("pointer-events-none", !isVisible);
                }

                profileToggle.addEventListener("click", function (e) {
                    e.stopPropagation();
                    toggleProfileMenu();
                });

                // Klik di luar area submenu untuk menutupnya
                document.addEventListener("click", function (e) {
                    if (!profileMenu.contains(e.target) && !profileToggle.contains(e.target)) {
                        toggleProfileMenu(false); // Sembunyikan
                    }
                });
            }

            // ===================================================
            // 2. ✅ KUNCI PERBAIKAN: Logic Layout Responsif Terpusat
            // ===================================================

            function adjustLayout() {
                const isDesktop = window.innerWidth >= 768;

                // --- Logika Margin (Mengatasi Isu Mobile Resize) ---
                if (isDesktop) {
                    // Pastikan sidebar terlihat di desktop
                    sidebar.classList.remove("hidden");
                    sidebarOverlay.classList.remove("show");

                    // Tentukan margin awal berdasarkan status collapsed/default
                    if (!sidebar.classList.contains("collapsed")) {
                        main.classList.remove("ml-16");
                        main.classList.add("ml-64"); // Sidebar terlihat penuh (default)
                    } else {
                        main.classList.remove("ml-64");
                        main.classList.add("ml-16"); // Sidebar collapsed
                    }
                } 
                else {
                    // ✅ Mobile: Hapus SEMUA margin kiri dan set sidebar ke hidden secara default
                    main.classList.remove("ml-64", "ml-16");
                    
                    // Hapus collapsed class di mobile
                    if (sidebar.classList.contains("collapsed")) {
                        sidebar.classList.remove("collapsed");
                    }
                    // Sembunyikan sidebar, kecuali jika overlay sedang tampil (sidebar terbuka)
                    if (!sidebarOverlay.classList.contains("show")) {
                        sidebar.classList.add("hidden");
                    }
                }

                // --- Logika Konten Card (min-height) ---
                if (mainContentCard) {
                    // Terapkan min-h-[calc(100%-60px)] hanya jika di Desktop ATAU di Mobile saat sidebar terbuka (overlay show)
                    const shouldBeTall = isDesktop || sidebarOverlay.classList.contains("show");
                    mainContentCard.classList.toggle("min-h-[calc(100%-60px)]", shouldBeTall);
                }
                
                // Adjust DataTables setelah layout berubah (penting untuk rendering)
                setTimeout(() => {
                    if (typeof table !== 'undefined' && table !== null) {
                        table.columns.adjust().draw();
                    }
                    if (typeof table_detail_upi !== 'undefined' && table_detail_upi !== null) {
                        table_detail_upi.columns.adjust().draw();
                    }
                }, 150);
            }
            
            // Panggil fungsi adjustLayout saat halaman dimuat
            adjustLayout(); 

            // Panggil saat window resize (dengan debounce)
            let resizeTimer;
            window.addEventListener('resize', () => {
                clearTimeout(resizeTimer);
                resizeTimer = setTimeout(adjustLayout, 150);
            });
            
            // ===================================================
            // 3. Logic Toggle Sidebar 
            // ===================================================
            document.querySelectorAll(".toggleSidebar").forEach(btn => {
                btn.addEventListener("click", () => {
                    const isDesktop = window.innerWidth >= 768;
                    
                    if (isDesktop) {
                        sidebar.classList.toggle("collapsed");
                        main.classList.toggle("ml-16");
                        main.classList.toggle("ml-64"); 
                    } 
                    else {
                        const isHidden = sidebar.classList.toggle("hidden");
                        sidebarOverlay.classList.toggle("show", !isHidden);
                        
                        // ✅ Update min-h konten saat toggle di mobile
                        if (mainContentCard) {
                            mainContentCard.classList.toggle("min-h-[calc(100%-60px)]", !isHidden);
                        }
                    }

                    // Adjust DataTables 
                    setTimeout(() => {
                        if (typeof table !== 'undefined' && table !== null) {
                            table.columns.adjust().draw();
                        }
                        if (typeof table_detail_upi !== 'undefined' && table_detail_upi !== null) {
                            table_detail_upi.columns.adjust().draw();
                        }
                    }, 350);
                });
            });

            // Sembunyikan footer saat sidebar overlay muncul di mobile
            sidebarOverlay.addEventListener("click", () => {
                sidebar.classList.add("hidden");
                sidebarOverlay.classList.remove("show");
                if (footer) footer.classList.remove("hidden");
            });

            document.querySelectorAll(".toggleSidebar").forEach(btn => {
                btn.addEventListener("click", () => {
                    const isMobile = window.innerWidth < 768;
                    if (isMobile) {
                        const isHidden = sidebar.classList.toggle("hidden");
                        sidebarOverlay.classList.toggle("show", !isHidden);
                        if (footer) footer.classList.toggle("hidden", !isHidden); // footer hilang saat overlay tampil
                    }
                });
            });

        });
    </script>

</body>
</html>