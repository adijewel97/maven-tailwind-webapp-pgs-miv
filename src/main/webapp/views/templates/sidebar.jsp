<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String menuAttr = (String) request.getAttribute("menu");
    if (menuAttr == null) menuAttr = "";

    boolean monitoringActive =
        "monitoring-rekon-bank-upi".equals(menuAttr) ||
        "Daftar-prov-upi".equals(menuAttr) ||
        "monitoring-rekon-upi".equals(menuAttr);
%>

<div class="flex flex-col h-full">

  <!-- Brand -->
  <a href="index.jsp?page=/views/dashboard/dashboard.jsp&menu=dashboard"
     class="flex items-center gap-2 px-4 py-3 border-b border-gray-700">
    <img src="${pageContext.request.contextPath}/assets/img/logo-mivPLNBANK.png"
         alt="Logo" class="w-8 h-8 rounded-full">
    <span class="text-lg font-semibold text-white sidebar-text">MIV-P2APST</span>
  </a>

  <!-- Menu scrollable -->
  <nav class="flex-1 overflow-y-auto">
    <ul class="mt-3 space-y-1">

      <!-- Dashboard -->
      <li>
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

      <!-- Monitoring -->
      <li>
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

        <!-- Submenu -->
        <ul id="submenuMonitoring"
            class="submenu pl-10 mt-1 space-y-1 transition-all duration-300 ease-in-out <%= monitoringActive ? "" : "hidden" %>">

          <li>
            <a href="index.jsp?page=/views/monitoring/mon_rekonflag_pln_vs_bank.jsp&menu=monitoring-rekon-bank-upi"
               title="Mon Rekon BANK vs PLN (Per-UID/UIW)"
               class="block px-4 py-2 rounded-md transition
                      <%= "monitoring-rekon-bank-upi".equals(menuAttr)
                          ? "bg-cyan-700 text-white font-semibold"
                          : "text-gray-300 hover:bg-gray-700 hover:text-white" %>">
              <span class="sidebar-text">Mon Rekon BANK vs PLN</span>
            </a>
          </li>

          <li>
            <a href="index.jsp?page=/views/monitoring/v2a_daftar_prov_upi.jsp&menu=Daftar-prov-upi"
               title="Daftar Provinsi / UPI"
               class="block px-4 py-2 rounded-md transition
                      <%= "Daftar-prov-upi".equals(menuAttr)
                          ? "bg-cyan-700 text-white font-semibold"
                          : "text-gray-300 hover:bg-gray-700 hover:text-white" %>">
              <span class="sidebar-text">Daftar Provinsi / UPI</span>
            </a>
          </li>

          <li>
            <a href="index.jsp?page=/views/monitoring/v3a_rekon_per_upi.jsp&menu=monitoring-rekon-upi"
               title="Monitoring Rekon per UPI"
               class="block px-4 py-2 rounded-md transition
                      <%= "monitoring-rekon-upi".equals(menuAttr)
                          ? "bg-cyan-700 text-white font-semibold"
                          : "text-gray-300 hover:bg-gray-700 hover:text-white" %>">
              <span class="sidebar-text">Monitoring Rekon per UPI</span>
            </a>
          </li>

        </ul>
      </li>
    </ul>
  </nav>

  <!-- Logout selalu di bawah -->
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
    const submenu = document.getElementById(id);
    const icon = btn.querySelector('.dropdown-icon');
    submenu.classList.toggle('hidden');
    icon.classList.toggle('rotate-180');
  }
</script>
