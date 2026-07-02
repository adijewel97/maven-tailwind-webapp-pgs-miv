<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String menuAttr = (String) request.getAttribute("menu");
    if (menuAttr == null) menuAttr = "";

    boolean monitoringActive =
        "monitoring-rekon-bank-upi".equals(menuAttr) ||
        "Struk-bank-miv".equals(menuAttr) ||
        "chek-filertxt-bank".equals(menuAttr) ||
        "upload-filercn-bank".equals(menuAttr);
%>

<div class="flex flex-col h-full">

  <a href="index.jsp?page=/views/dashboard/dashboard.jsp&menu=dashboard"
     class="flex items-center gap-2 px-4 py-3 border-b border-gray-700">
    <img src="${pageContext.request.contextPath}/assets/img/logo-mivPLNBANK.png"
         alt="Logo" class="w-8 h-8 rounded-full">
    <span class="text-lg font-semibold text-white sidebar-text">MIV-P2APST</span>
  </a>

  <nav class="flex-1 overflow-y-auto">
    <ul class="mt-3 space-y-1">

      <li class="menu-treeview relative">
        <a href="index.jsp?page=/views/dashboard/dashboard.jsp&menu=dashboard"
           title="Dashboard"
           class="flex items-center gap-3 px-4 py-2 rounded-md transition
                  <%= "dashboard".equals(menuAttr)
                      ? "bg-gray-700 text-white font-semibold"
                      : "text-gray-300 hover:bg-gray-700 hover:text-white" %>">
          <i class="fa fa-tachometer-alt w-5 text-center"></i>
          <span class="sidebar-text">Dashboard</span>
        </a>
      </li>

      <li class="submenu-wrapper">
        <button class="flex items-center justify-between w-full px-4 py-2 text-left rounded-md transition
                       <%= monitoringActive
                           ? "bg-gray-700 text-white font-semibold"
                           : "text-gray-300 hover:bg-gray-700 hover:text-white" %>"
                onclick="toggleSubmenu('submenuMonitoring', this)">
          <div class="flex items-center gap-3">
            <i class="fa fa-tasks w-5 text-center"></i>
            <span class="sidebar-text">Monitoring</span>
          </div>
          <i class="fa fa-angle-down dropdown-icon transition-transform duration-200 <%= monitoringActive ? "rotate-180" : "" %>"></i>
        </button>

        <ul id="submenuMonitoring"
            class="submenu-popover md:pl-6 mt-1 space-y-1 transition-all duration-300 ease-in-out <%= monitoringActive ? "" : "hidden" %>">

          <li>
            <a href="index.jsp?page=/views/monitoring/mon01_rekonflag_pln_vs_bank.jsp&menu=monitoring-rekon-bank-upi"
               title="Mon Rekon BANK vs PLN"
               class="block px-4 py-2 rounded-md transition text-sm
                      <%= "monitoring-rekon-bank-upi".equals(menuAttr)
                          ? "bg-cyan-800 text-white font-semibold"
                          : "text-gray-300 hover:bg-cyan-600 hover:text-white" %>">
              <span class="sidebar-text">Mon Rekon PLN vs BANK</span>
            </a>
          </li>

          <li>
            <a href="index.jsp?page=/views/monitoring/mon02_cetak_struk_mivbank.jsp&menu=Struk-bank-miv"
               title="Cetak Struk"
               class="block px-4 py-2 rounded-md transition text-sm
                      <%= "Struk-bank-miv".equals(menuAttr)
                          ? "bg-cyan-800 text-white font-semibold"
                          : "text-gray-300 hover:bg-cyan-600 hover:text-white" %>">
              <span class="sidebar-text">Cetak Struk - BANK MIV</span>
            </a>
          </li>

          <li>
            <a href="index.jsp?page=/views/monitoring/mon03_chek_filetxtrcn_mivbank.jsp&menu=chek-filertxt-bank"
               title="Chek File Daftar Ke Bank"
               class="block px-4 py-2 rounded-md transition text-sm
                      <%= "chek-filertxt-bank".equals(menuAttr)
                          ? "bg-cyan-800 text-white font-semibold"
                          : "text-gray-300 hover:bg-cyan-600 hover:text-white" %>">
              <span class="sidebar-text">Chek File (TXT & RCN)</span>
            </a>
          </li>
          
          <li>
            <a href="index.jsp?page=/views/monitoring/mon04_upload_filercn_mivbank..jsp&menu=upload-filercn-bank"
               title="Upload File Pelunasan Dari Bank"
               class="block px-4 py-2 rounded-md transition text-sm
                      <%= "upload-filercn-bank".equals(menuAttr)
                          ? "bg-cyan-800 text-white font-semibold"
                          : "text-gray-300 hover:bg-cyan-600 hover:text-white" %>">
              <span class="sidebar-text">Upload File (RCN)</span>
            </a>
          </li>
        </ul>
      </li>

      <li>
        <a href="${pageContext.request.contextPath}/LogoutServlet"
           title="Logout"
           class="flex items-center gap-3 px-4 py-2 rounded-md transition text-gray-300 hover:bg-gray-700 hover:text-white">
          <i class="fa fa-sign-out-alt w-5 text-center"></i>
          <span class="sidebar-text">Logout</span>
        </a>
      </li>

    </ul>
  </nav>

  <div class="mt-auto border-t border-gray-700">
    <a href="${pageContext.request.contextPath}/LogoutServlet"
       class="flex items-center gap-3 px-4 py-3 text-gray-300 hover:bg-gray-700 hover:text-white transition">
      <i class="fa fa-sign-out-alt w-5 text-center"></i>
      <span class="sidebar-text">Logout</span>
    </a>
  </div>
</div>

<script>
  function toggleSubmenu(id, btn) {
    const sidebar = document.getElementById('sidebar');
    const submenu = document.getElementById(id);
    const icon = btn.querySelector('.dropdown-icon');
    
    // Periksa apakah posisi sidebar sedang mengecil (.collapsed) atau tidak
    if (sidebar && sidebar.classList.contains('collapsed')) {
        // Mode Popover / Melayang di Samping
        const isShown = submenu.classList.contains('show-popover');
        
        // Tutup popover menu lain terlebih dahulu jika ada
        document.querySelectorAll('.submenu-popover').forEach(el => {
            el.classList.remove('show-popover');
        });
        
        if (!isShown) {
            submenu.classList.add('show-popover');
        }
    } else {
        // Mode Normal / Akordion ke Bawah
        submenu.classList.toggle('hidden');
        if (icon) {
            icon.classList.toggle('rotate-180');
        }
    }
  }
</script>