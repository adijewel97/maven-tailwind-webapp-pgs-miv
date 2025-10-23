<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Logic untuk menentukan halaman yang akan di-include dan menu aktif
    String currentPage = request.getParameter("page");
    String currentMenu = request.getParameter("menu");

    if (currentPage == null || currentPage.trim().isEmpty()) {
        // Default ke dashboard jika tidak ada parameter page
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
            overflow-x: hidden;
        }

        /* Sidebar Styling */
        #sidebar {
            width: 16rem;
            font-size: 12.5px;
            transition: width 0.3s ease;
            background-color: #1f2937;
            overflow-y: auto;
            scrollbar-width: thin;
        }

        #sidebar.collapsed {
            width: 4rem;
        }

        #sidebar.collapsed .sidebar-text,
        #sidebar.collapsed .submenu {
            display: none;
        }

        #sidebar.collapsed a[title]:hover::after {
            content: attr(title);
            position: absolute;
            left: 70px;
            background: #1f2937;
            color: #fff;
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 11.5px;
            white-space: nowrap;
            box-shadow: 0 2px 6px rgba(0,0,0,0.2);
            z-index: 50;
        }

        /* Content & Layout Adjustments */
        .content-card { padding: 1.5rem !important; }
        .navbar { height: 50px; }
        
        /* Main Content Margin */
        main { transition: margin-left 0.3s ease; }
        main.ml-64 { margin-left: 16rem; }
        main.ml-16 { margin-left: 4rem; }

        /* Profile Submenu Arrow */
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

        /* Mobile Overlay */
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
        <aside id="sidebar"
               class="fixed top-[50px] left-0 h-full w-64 text-gray-100 hidden md:flex flex-col z-40">
            <jsp:include page="/views/templates/sidebar.jsp" />
        </aside>

        <div id="sidebar-overlay"></div>

        <main id="mainContent" class="flex-1 ml-64 overflow-y-auto bg-gray-100 p-4">
            <div class="bg-white rounded-xl shadow content-card min-h-[calc(100%-60px)] w-full">
                <jsp:include page="<%= currentPage %>" />
            </div>

            <footer class="text-xs text-gray-500 text-center py-3 border-t border-gray-200 mt-4">
                <strong>MangAdi&copy; 2025 <a href="#" class="text-cyan-600 hover:underline">MIV</a>.</strong> All rights reserved.
            </footer>
        </main>
    </div>

    <%-- PASTIKAN HANYA SATU JQUERY YANG DIMUAT --%>
    <script src="${pageContext.request.contextPath}/assets/js/jquery-3.7.1.min.js"></script>

    <%-- DATATABLES CORE & BUTTONS --%>
    <script src="${pageContext.request.contextPath}/assets/dataTables/js/jquery.dataTables.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/dataTables/js/dataTables.buttons.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/dataTables/js/buttons.html5.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/dataTables/js/jszip.min.js"></script>
    
    <%-- FLATPCIKR --%>
    <script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>
    <script src="https://npmcdn.com/flatpickr/dist/l10n/id.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/flatpickr/dist/plugins/monthSelect/index.js"></script>

    <%-- CUSTOM SCRIPTS --%>
    <script src="${pageContext.request.contextPath}/assets/excel/js/xlsx.full.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/style_tailwind_adis.js"></script>

    <script>
        const sidebar = document.getElementById('sidebar');
        const main = document.getElementById('mainContent');
        const sidebarOverlay = document.getElementById('sidebar-overlay');
        const profileToggle = document.querySelector(".toggleSubmenuProfile");
        const profileMenu = document.getElementById("submenu-profile");

        // --- Utility Functions ---
        function showProfileMenu() {
            profileMenu.classList.remove("opacity-0", "scale-95", "pointer-events-none");
            profileMenu.classList.add("opacity-100", "scale-100", "show");
        }

        function hideProfileMenu() {
            profileMenu.classList.remove("opacity-100", "scale-100", "show");
            profileMenu.classList.add("opacity-0", "scale-95", "pointer-events-none");
        }
        
        // --- Sidebar & Layout Logic ---
        document.addEventListener('DOMContentLoaded', () => {
             // Set initial state for desktop
             if (window.innerWidth >= 768) {
                 // Pastikan class default ml-64 (16rem) sudah ada di <main>
                 main.classList.add("ml-64");
             } else {
                 sidebar.classList.add("hidden");
                 main.classList.remove("ml-64");
             }

             // --- Toggle sidebar ---
             document.querySelectorAll(".toggleSidebar").forEach(btn => {
                 btn.addEventListener("click", () => {
                     if (window.innerWidth >= 768) {
                         // Desktop: Collapse / Expand
                         sidebar.classList.toggle("collapsed");
                         main.classList.toggle("ml-16");
                         main.classList.toggle("ml-64");
                     } else {
                         // Mobile: Show / Hide with overlay
                         const isHidden = sidebar.classList.toggle("hidden");
                         if (isHidden) {
                             sidebarOverlay.classList.remove("show");
                         } else {
                             sidebarOverlay.classList.add("show");
                         }
                     }
                     
                     // PERBAIKAN: Adjust DataTables setelah transisi sidebar selesai
                     // Variabel `table` dan `table_detail_upi` diasumsikan dideklarasikan global
                     setTimeout(() => {
                         // DataTables rekap
                         if (typeof table !== 'undefined' && table !== null) {
                             table.columns.adjust().draw();
                         }
                         // DataTables detail (jika ada dan sedang ditampilkan)
                         if (typeof table_detail_upi !== 'undefined' && table_detail_upi !== null) {
                              table_detail_upi.columns.adjust().draw();
                         }
                     }, 350); // Jeda 350ms (lebih dari 0.3s transisi CSS)

                 });
             });

             // Klik overlay untuk tutup sidebar di mobile
             sidebarOverlay.addEventListener("click", () => {
                 sidebar.classList.add("hidden");
                 sidebarOverlay.classList.remove("show");
             });

             // Reset sidebar saat resize (Tambahkan adjust DataTables juga di sini)
             window.addEventListener("resize", () => {
                 if (window.innerWidth >= 768) {
                     sidebar.classList.remove("hidden");
                     sidebarOverlay.classList.remove("show");
                     
                     // Jaga konsistensi margin saat resize dari mobile ke desktop
                     if (!sidebar.classList.contains("collapsed")) {
                         main.classList.add("ml-64");
                         main.classList.remove("ml-16");
                     } else {
                         main.classList.add("ml-16");
                         main.classList.remove("ml-64");
                     }
                 } else {
                     // Mobile view
                     sidebar.classList.add("hidden");
                     main.classList.remove("ml-64");
                     main.classList.remove("ml-16");
                 }
                 
                 // PERBAIKAN: Adjust DataTables saat resize
                 // Panggil tanpa jeda panjang, karena event resize sering dipicu
                 if (typeof table !== 'undefined' && table !== null) {
                     table.columns.adjust().draw();
                 }
             });

             // --- Submenu Profil ---
             profileToggle.addEventListener("click", (e) => {
                 e.stopPropagation();
                 const isVisible = profileMenu.classList.contains("opacity-100");

                 if (isVisible) {
                     hideProfileMenu();
                 } else {
                     showProfileMenu();
                 }
             });

             document.addEventListener("click", (e) => {
                 if (!profileMenu.contains(e.target) && !profileToggle.contains(e.target)) {
                     hideProfileMenu();
                 }
             });
        });
    </script>
</body>
</html>