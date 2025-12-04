<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // =====================================================================
    // AUTH CHECK
    // =====================================================================
    if (session.getAttribute("username") == null) {
        // response.sendRedirect(request.getContextPath() + "/login.jsp");
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

    <!-- CACHE CONTROL -->
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate"/>
    <meta http-equiv="Pragma" content="no-cache"/>
    <meta http-equiv="Expires" content="0"/>

    <!-- STYLE -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style_tailwind_adis.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/dataTables/css/jquery.dataTables.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/dataTables/css/buttons.dataTables.min.css">

    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/plugins/monthSelect/style.css">
     <!-- STYLE -->

    <style>
        /* ================================================================
           DEFAULT
        ================================================================ */
        html, body {
            font-size: 13px;
            line-height: 1.5;
            font-family: 'Inter', Arial, sans-serif;
            background-color: #f3f4f6;
            overflow-x: hidden;
        }

        :root { --footer-height: 50px; }

        main { transition: margin-left 0.3s ease; }

        /* ================================================================
           SIDEBAR DESKTOP
        ================================================================ */
        #sidebar {
            width: 16rem;
            background-color: #1f2937;
            font-size: 13px;
            transition: width 0.3s ease;
            overflow-y: auto;
        }

        #sidebar.collapsed { width: 4rem; }
        #sidebar.collapsed .sidebar-text,
        #sidebar.collapsed .submenu {
            display: none;
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
                transition: left 0.3s ease;
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

        /* ================================================================
           FOOTER
        ================================================================ */
        #mainFooter {
            position: fixed;
            bottom: 0;
            left: 0;
            width: 100%;
            border-top: 1px solid #d1d5db;
            height: var(--footer-height);
            background: #ffffff;
        }

        /* ================================================================
           MAIN CONTENT (RESPONSIVE)
        ================================================================ */
        #mainContent {
            margin-left: 16rem; /* default desktop */
            margin-top: 60px;   /* jarak dari navbar */
            transition: margin-left 0.3s ease;
        }

        /* ================================================================
           Reset Ke mobile (RESPONSIVE)
        ================================================================ */
        @media (max-width: 767px) {
            #mainContent {
                margin-left: 0 !important;
                padding-left: 10px;
                padding-right: 10px;
            }
        }

    </style>
</head>
<body class="min-h-screen flex flex-col">

<!-- ================================================================
     NAVBAR
================================================================ -->
<nav class="fixed top-0 left-0 right-0 bg-cyan-600 z-50 flex items-center justify-between px-4 h-[50px] shadow-lg">
    <i class="toggleSidebar fa-solid fa-bars text-white text-xl cursor-pointer hover:text-cyan-200"></i>

    <span class="text-white font-bold text-sm truncate">MIV - Management Instansi Vertikal</span>

    <div class="relative">
        <img src="${pageContext.request.contextPath}/assets/img/profile.jpg"
             width="34"
             class="rounded-full cursor-pointer toggleSubmenuProfile hover:scale-110 transition"
             alt="Profile">

        <!-- PROFILE DROPDOWN -->
        <div id="submenu-profile"
             class="absolute right-0 mt-3 w-48 bg-gray-700 text-white rounded-lg shadow-2xl
                    transform scale-95 opacity-0 pointer-events-none transition-all origin-top">
            <div class="text-center p-3 border-b border-gray-600">
                <span class="block text-sm font-semibold">${sessionScope.username}</span>
                <span class="block text-xs text-gray-300">${sessionScope.userRole}</span>
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

<!-- ================================================================
     LAYOUT WRAPPER
================================================================ -->
<div class="flex h-screen overflow-hidden">

    <!-- SIDEBAR -->
    <aside id="sidebar" class="fixed top-[50px] left-0 h-full md:flex flex-col z-40 w-64">
        <jsp:include page="/views/templates/sidebar.jsp"/>
    </aside>

    <div id="sidebar-overlay"></div>

    <!-- MAIN -->
    <main id="mainContent" class="w-full ml-64 p-4 bg-gray-100 min-h-screen overflow-auto transition-all">
        <div class="bg-white rounded-xl shadow p-6 mb-4 overflow-auto">
            <jsp:include page="<%= currentPage %>"/>
        </div>
    </main>
</div>

<!-- ================================================================
     FOOTER
================================================================ -->
<footer id="mainFooter"
        class="flex items-center justify-center text-xs text-gray-600">
    <strong>MangAdi © 2025 <a class="text-cyan-600 hover:underline">MIV</a>.</strong> All rights reserved.
</footer>

<!-- ================================================================
     SCRIPT
================================================================ -->
<!-- ✅ JAVASCRIPT -->
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

<!-- ================================================================
     TIME
================================================================ -->
<script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>
<script src="https://cdn.jsdelivr.net/npm/flatpickr/dist/l10n/id.js"></script>
<script src="https://cdn.jsdelivr.net/npm/flatpickr/dist/plugins/monthSelect/index.js"></script>


<script>
document.addEventListener("DOMContentLoaded", () => {

    const sidebar   = document.getElementById('sidebar');
    const overlay   = document.getElementById('sidebar-overlay');
    const main      = document.getElementById('mainContent');
    const toggleBtn = document.querySelector(".toggleSidebar");

    /* -----------------------------
       SIDEBAR TOGGLE (RESPONSIVE)
    ------------------------------*/
    toggleBtn.addEventListener("click", () => {
        if (window.innerWidth < 768) {
            const isShow = !sidebar.classList.contains("show");
            sidebar.classList.toggle("show", isShow);
            overlay.classList.toggle("show", isShow);
            main.classList.add("ml-0");
        } else {
            sidebar.classList.toggle("collapsed");
            main.classList.remove("ml-64", "ml-16");
            main.classList.add(sidebar.classList.contains("collapsed") ? "ml-16" : "ml-64");
        }
    });

    overlay.addEventListener("click", () => {
        sidebar.classList.remove("show");
        overlay.classList.remove("show");
    });

    /* -----------------------------
       PROFILE MENU
    ------------------------------*/
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
    });
});
</script>

</body>
</html>
