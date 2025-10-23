<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
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

  <!-- Tailwind CSS -->
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style_tailwind_adis.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/dataTables/css/jquery.dataTables.min.css">

  <style>
    html, body {
      font-size: 13px;
      line-height: 1.45;
      color: #374151;
      font-family: 'Inter', Arial, sans-serif;
      background-color: #f3f4f6;
      overflow-x: hidden;
    }

    #sidebar {
      width: 16rem;
      font-size: 12.5px;
      transition: all 0.3s ease;
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

    table { font-size: 9.5px !important; }
    th, td { padding: 6px 8px !important; }
    .content-card { padding: 1.5rem !important; }
    .navbar { height: 46px !important; }
    #submenu-profile { font-size: 12.5px; }

    #sidebar::-webkit-scrollbar { width: 6px; }
    #sidebar::-webkit-scrollbar-thumb {
      background: #4b5563;
      border-radius: 4px;
    }

    /* 🔹 Panah kecil di atas submenu profil */
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
  </style>
</head>

<body class="min-h-screen flex flex-col">

  <!-- Navbar -->
  <nav class="fixed top-0 left-0 right-0 bg-cyan-500 navbar z-50 flex items-center justify-between px-4 md:px-6">
    <!-- Toggle Sidebar -->
    <i class="toggleSidebar fa fa-bars text-white cursor-pointer text-xl"></i>

    <!-- Title -->
    <span class="text-white text-sm font-bold">MIV - Management Instansi Vertikal</span>

    <!-- Profil -->
    <div class="relative">
      <img src="${pageContext.request.contextPath}/assets/img/profile.jpg"
           class="rounded-full cursor-pointer toggleSubmenuProfile transition-all duration-200 ease-in-out hover:scale-110 hover:shadow-lg hover:shadow-cyan-300/40"
           width="34" alt="Profile">

      <!-- Submenu Profil -->
      <div id="submenu-profile"
           class="absolute right-0 mt-2 w-48 bg-gray-700 text-white rounded-md shadow-lg z-50
                  transform scale-95 opacity-0 -translate-y-2 pointer-events-none transition-all duration-200 ease-out origin-top">
        <div class="text-center border-b border-gray-600 p-2">
          <span class="block text-xs">${sessionScope.username}</span>
          <span class="block text-[11px] text-gray-300">${sessionScope.userRole}</span>
        </div>
        <a href="#" class="block px-4 py-2 hover:bg-gray-600 transition-all">Setting</a>
        <a href="${pageContext.request.contextPath}/LogoutServlet" class="block px-4 py-2 hover:bg-gray-600 transition-all">Logout</a>
      </div>
    </div>
  </nav>

  <!-- Wrapper -->
  <div class="flex pt-[46px] h-[calc(100vh-46px)] overflow-hidden">
    <!-- Sidebar -->
    <aside id="sidebar"
           class="fixed top-[46px] left-0 h-[calc(100vh-46px)] w-64 text-gray-100 hidden md:flex flex-col z-40">
      <jsp:include page="/views/templates/sidebar.jsp" />
    </aside>

    <!-- Main Content -->
    <main class="flex-1 ml-64 overflow-auto bg-gray-100 transition-all duration-300 ease-in-out">
      <div class="bg-white rounded-xl shadow-md content-card min-h-full w-full">
        <jsp:include page="<%= currentPage %>" />
      </div>

      <!-- Footer -->
      <footer class="text-[12px] text-gray-500 text-center py-3 border-t border-gray-200 mt-4">
        <strong>MangAdi&copy; 2025 <a href="#" class="text-cyan-600 hover:underline">MIV</a>.</strong> All rights reserved.
      </footer>
    </main>
  </div>

  <!-- Scripts -->
  <script src="${pageContext.request.contextPath}/assets/bootstrap/dist/js/jquery.min.js"></script>
  <script src="${pageContext.request.contextPath}/assets/dataTables/js/jquery.dataTables.min.js"></script>
  <script src="${pageContext.request.contextPath}/assets/dataTables/js/dataTables.buttons.min.js"></script>
  <script src="${pageContext.request.contextPath}/assets/dataTables/js/buttons.html5.min.js"></script>
  <script src="${pageContext.request.contextPath}/assets/dataTables/js/jszip.min.js"></script>
  <script src="${pageContext.request.contextPath}/assets/bootstrap/dist/js/xlsx.full.min.js"></script>
  <script src="${pageContext.request.contextPath}/assets/js/style_tailwind_adis.js"></script>

  <script>
    const sidebar = document.getElementById('sidebar');
    const main = document.querySelector('main');
    const profileToggle = document.querySelector(".toggleSubmenuProfile");
    const profileMenu = document.getElementById("submenu-profile");

    // --- Toggle sidebar ---
    document.querySelectorAll(".toggleSidebar").forEach(btn => {
      btn.addEventListener("click", () => {
        if (window.innerWidth >= 768) {
          sidebar.classList.toggle("collapsed");
          main.classList.toggle("ml-16");
          main.classList.toggle("ml-64");
        } else {
          sidebar.classList.toggle("hidden");
          if (sidebar.classList.contains("hidden")) {
            main.classList.remove("ml-64");
          } else {
            main.classList.add("ml-64");
          }
        }
      });
    });

    // Reset sidebar saat resize
    window.addEventListener("resize", () => {
      if (window.innerWidth >= 768) {
        sidebar.classList.remove("hidden");
        main.classList.add("ml-64");
      } else {
        sidebar.classList.add("hidden");
        main.classList.remove("ml-64");
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

    function showProfileMenu() {
      profileMenu.classList.remove("opacity-0", "scale-95", "-translate-y-2", "pointer-events-none");
      profileMenu.classList.add("opacity-100", "scale-100", "translate-y-0", "show");
    }

    function hideProfileMenu() {
      profileMenu.classList.remove("opacity-100", "scale-100", "translate-y-0", "show");
      profileMenu.classList.add("opacity-0", "scale-95", "-translate-y-2", "pointer-events-none");
    }
  </script>
</body>
</html>
