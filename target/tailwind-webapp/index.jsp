<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // =====================================================================
    // AUTH CHECK
    // =====================================================================
    if (session.getAttribute("username") == null) {
        response.sendRedirect(request.getContextPath() + "/views/templates/login.jsp");
        return;
    }

    String currentPage = request.getParameter("page");
    String currentMenu  = request.getParameter("menu");

    if (currentPage == null || currentPage.trim().isEmpty()) {
        currentPage = "/views/dashboard/dashboard.jsp";
    }

    request.setAttribute("menu",
        (currentMenu == null || currentMenu.trim().isEmpty())
        ? "dashboard"
        : currentMenu
    );
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <title>MIV Dashboard</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>

    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate"/>
    <meta http-equiv="Pragma" content="no-cache"/>
    <meta http-equiv="Expires" content="0"/>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style_tailwind_adis.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/dataTables/css/jquery.dataTables.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/dataTables/css/buttons.dataTables.min.css">

    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/plugins/monthSelect/style.css">

    <!-- exel css export-->
    <script src="${pageContext.request.contextPath}/assets/excel/js/xlsx.full.min.js"></script>

    <style>
        /* GLOBAL */
        html, body {
            font-size: 13px;
            line-height: 1.5;
            font-family: 'Inter', Arial, sans-serif;
            background-color: #f3f4f6;
            overflow-x: hidden;
        }

        :root { --footer-height: 50px; }

        /* ================================================================
           SIDEBAR
        ================================================================ */
        #sidebar {
            background: #0e7490; /* cyan-700 */
            color: white;
            box-shadow: inset -2px 0 6px rgba(0,0,0,0.25);
            font-size: 13px;
            transition: width 0.3s ease, left 0.3s ease;
            overflow-y: auto;
        }

        /* COLLAPSE SIDEBAR */
        #sidebar.collapsed {
            width: 4rem !important;
            overflow-y: visible !important; /* Penting agar menu melayang tidak terpotong scroll */
        }
        #sidebar.collapsed .sidebar-text {
            display: none;
        }

        /* Hover item utama di sidebar */
        .sidebar-item:hover {
            background: #0891b2 !important; /* cyan-600 */
            transition: 0.2s ease-in-out;
        }

        /* ================================================================
           FLYOUT SUBMENU (Saat Sidebar Mengecil)
        ================================================================ */
        /* Bungkus posisi sub-menu secara relatif terhadap baris menu induk */
        #sidebar.collapsed .submenu-wrapper {
            position: relative;
        }

        /* Base style untuk sub-menu melayang di kanan */
        #sidebar.collapsed .submenu-popover {
            position: absolute;
            left: 4rem;
            top: 0;
            width: 14rem;
            background: #0e7490;
            box-shadow: 4px 4px 10px rgba(0,0,0,0.3);
            border-radius: 0 6px 6px 0;
            z-index: 99;
            display: none; /* Default sembunyi */
        }

        /* 1. AKSI DISOROT (HOVER): Munculkan jika wrapper disorot mouse */
        #sidebar.collapsed .submenu-wrapper:hover .submenu-popover {
            display: block !important;
        }

        /* 2. AKSI DIKLIK: Munculkan jika ditambahkan class aktif via JS klik */
        #sidebar.collapsed .submenu-popover.show-popover {
            display: block !important;
        }

        /* Kembalikan teks dalam sub-menu agar terlihat di dalam kotak popover */
        #sidebar.collapsed .submenu-popover .sidebar-text {
            display: inline !important;
        }

        /* ================================================================
           MOBILE SIDEBAR
        ================================================================ */
        @media (max-width: 767px) {
            #sidebar {
                position: fixed;
                top: 50px;
                left: -16rem;
                height: calc(100% - 50px);
                z-index: 60;
                width: 16rem !important;
            }
            #sidebar.show { left: 0; }

            #sidebar-overlay {
                position: fixed;
                inset: 0;
                background: rgba(0,0,0,0.5);
                opacity: 0;
                pointer-events: none;
                transition: opacity 0.3s ease;
                z-index: 50;
            }
            #sidebar-overlay.show {
                opacity: 1;
                pointer-events: auto;
            }
        }

        /* FOOTER */
        #mainFooter {
            position: fixed;
            bottom: 0;
            left: 0;
            width: 100%;
            border-top: 1px solid #d1d5db;
            height: var(--footer-height);
            background: #ffffff;
            z-index: 45;
        }

        /* MAIN MAIN CONTENT */
       /* #mainContent{
            margin-left: 16rem;
            margin-top: 60px;
            transition: all .3s ease;
        }
        */
        :root{
            --footer-height:50px;
        }

        #mainContent{
            margin-left:16rem;
            margin-top:60px;
            padding:16px;
            padding-bottom:calc(var(--footer-height) + 20px);
            transition:all .3s ease;
            overflow:auto;
        }

        #mainContent.sidebar-collapsed{
            margin-left: 4rem;
        }

        @media (max-width: 767px) {
            #mainContent {
                margin-left: 0 !important;
                padding-left: 10px;
                padding-right: 10px;
            }
            #mainContent.sidebar-collapsed {
                margin-left: 0 !important;
            }
        }
    </style>
</head>

<body class="min-h-screen flex flex-col">

<nav class="fixed top-0 left-0 right-0 bg-cyan-600 z-50 flex items-center justify-between px-4 h-[50px] shadow-lg">
    <i class="toggleSidebar fa-solid fa-bars text-white text-xl cursor-pointer hover:text-cyan-200"></i>
    <span class="text-white font-bold text-sm truncate">MIV - Management Instansi Vertikal</span>

    <div class="relative">
        <img src="${pageContext.request.contextPath}/assets/img/profile.jpg"
             width="34"
             class="rounded-full cursor-pointer toggleSubmenuProfile hover:scale-110 transition"
             alt="Profile">

        <div id="submenu-profile"
             class="absolute right-0 mt-3 w-48 bg-gray-700 text-white rounded-lg shadow-2xl
                    transform scale-95 opacity-0 pointer-events-none transition-all origin-top">
            <div class="text-center p-3 border-b border-gray-600">
                <span class="block text-sm font-semibold">${sessionScope.username} / ${sessionScope.userRole}</span>
            </div>
            <a href="#" class="block px-4 py-2 text-sm hover:bg-gray-600">
                <i class="fa-solid fa-gear mr-2"></i> Setting
            </a>
            <a href="${pageContext.request.contextPath}/LogoutServlet"
               class="block px-4 py-2 text-sm hover:bg-gray-600">
                <i class="fa-solid fa-right-from-bracket mr-2"></i> Logout
            </a>
        </div>
    </div>
</nav>

<div class="flex h-screen overflow-hidden">
    <aside id="sidebar" class="fixed top-[50px] left-0 h-full md:flex flex-col z-40 w-64">
        <jsp:include page="/views/templates/sidebar.jsp"/>
    </aside>

    <div id="sidebar-overlay"></div>

    <main id="mainContent" class="w-full p-4 bg-gray-100 min-h-screen overflow-auto transition-all">
        <div class="bg-white rounded-xl shadow p-6 mb-4 overflow-auto">
            <jsp:include page="<%= currentPage %>"/>
        </div>
    </main>
</div>

<footer id="mainFooter" class="flex items-center justify-center text-xs text-gray-600">
    <strong>MangAdi © 2025 <a class="text-cyan-600">MIV</a>.</strong> All rights reserved.
</footer>

<script src="${pageContext.request.contextPath}/assets/js/jquery-3.7.1.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/dataTables/js/jquery.dataTables.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/dataTables/js/dataTables.buttons.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/dataTables/js/buttons.html5.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/dataTables/js/jszip.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/excel/js/cdnjs_cloudflare_com/ajax/libs/exceljs/4.3.0/exceljs.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/excel/js/cdnjs_cloudflare_com/ajax/libs/FileSaver.js/2.0.5/FileSaver.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>
<script src="https://npmcdn.com/flatpickr/dist/l10n/id.js"></script>
<script src="https://cdn.jsdelivr.net/npm/flatpickr/dist/plugins/monthSelect/index.js"></script>
<!-- <script src="https://cdn.jsdelivr.net/npm/exceljs/dist/exceljs.min.js"></script> -->
<!-- <script src="https://cdnjs.cloudflare.com/ajax/libs/FileSaver.js/2.0.2/FileSaver.min.js"></script> -->

<!-- export exel -->
<!-- <script src="https://cdnjs.cloudflare.com/ajax/libs/exceljs/4.3.0/exceljs.min.js"></script> -->
<!-- <script src="https://cdnjs.cloudflare.com/ajax/libs/FileSaver.js/2.0.5/FileSaver.min.js"></script> -->

<script>
document.addEventListener("DOMContentLoaded", () => {
    const sidebar   = document.getElementById('sidebar');
    const overlay   = document.getElementById('sidebar-overlay');
    const main      = document.getElementById('mainContent');
    const toggleBtn = document.querySelector(".toggleSidebar");

    /* RESPONSIVE TOGGLE SIDEBAR */
    toggleBtn.addEventListener("click", () => {
        if (window.innerWidth < 768) {
            const isShow = !sidebar.classList.contains("show");
            sidebar.classList.toggle("show", isShow);
            overlay.classList.toggle("show", isShow);
            main.classList.add("ml-0");
        } else {
            sidebar.classList.toggle("collapsed");
            
            // Bersihkan sisa popover klik yang aktif saat dikembalikan ke ukuran normal
            document.querySelectorAll('.submenu-popover').forEach(el => {
                el.classList.remove('show-popover');
            });

            main.classList.toggle(
                "sidebar-collapsed",
                sidebar.classList.contains("collapsed")
            );
        }
    });

    overlay.addEventListener("click", () => {
        sidebar.classList.remove("show");
        overlay.classList.remove("show");
    });

    /* PROFILE DROPDOWN */
    const toggleProfile = document.querySelector(".toggleSubmenuProfile");
    const menuProfile   = document.getElementById("submenu-profile");

    toggleProfile.onclick = e => {
        e.stopPropagation();
        menuProfile.classList.toggle("opacity-0");
        menuProfile.classList.toggle("opacity-100");
        menuProfile.classList.toggle("pointer-events-none");
        menuProfile.classList.toggle("pointer-events-auto");
        menuProfile.classList.toggle("scale-95");
        menuProfile.classList.toggle("scale-100");
    };

    document.addEventListener("click", e => {
        if (!menuProfile.contains(e.target)) {
            menuProfile.classList.add("opacity-0","pointer-events-none","scale-95");
            menuProfile.classList.remove("opacity-100","pointer-events-auto","scale-100");
        }
        
        // Klik di luar area sidebar akan menutup popover menu yang sengaja dibuka lewat klik
        if (sidebar.classList.contains('collapsed') && !sidebar.contains(e.target)) {
            document.querySelectorAll('.submenu-popover').forEach(el => {
                el.classList.remove('show-popover');
            });
        }
    });
});
</script>

<jsp:include page="/components/modalMessage.jsp" />

</body>
</html>