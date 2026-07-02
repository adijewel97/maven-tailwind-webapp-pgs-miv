<!-- Navbar -->
  <div class="fixed top-0 left-0 right-0 bg-cyan-500 h-[50px] z-50 flex items-center justify-between px-4 md:px-6">
    <!-- Toggle Sidebar (mobile & desktop) -->
    <i class="toggleSidebar fa fa-bars text-white cursor-pointer text-xl"></i>

    <!-- Title -->
    <span class="text-white text-sm font-bold">MIV - Management Instansi Vertikal</span>

    <!-- Right: Profil wrapper -->
    <div class="relative">
      <img src="${pageContext.request.contextPath}/assets/img/profile.jpg"
          class="rounded-full cursor-pointer toggleSubmenuProfile"
          width="30" alt="Profile">

      <!-- Submenu -->
      <div id="submenu-profile" class="hidden absolute right-0 mt-1 w-48 bg-gray-700 text-white rounded-md shadow-lg z-50">
        <label class="block p-2 text-center border-b">
          ${sessionScope.username} | ${sessionScope.userRole}
        </label>
        <a href="#" class="block px-4 py-2 hover:bg-gray-600">Setting</a>
        <a href="${pageContext.request.contextPath}/LogoutServlet" class="block px-4 py-2 hover:bg-gray-600">Logout</a>
      </div>
    </div>

  </div>

<script>
    // Toggle sidebar
    document.querySelectorAll(".toggleSidebar").forEach(btn => {
      btn.addEventListener("click", () => {
        const sidebar = document.getElementById('sidebar');
        if (window.innerWidth >= 768) {
          sidebar.classList.toggle("collapsed");
        } else {
          sidebar.classList.toggle("hidden");
        }
      });
    });

    // Toggle profile submenu
    document.querySelector(".toggleSubmenuProfile").addEventListener("click", () => {
      const prof = document.getElementById("submenu-profile");
      prof.classList.toggle("hidden");
    });
</script>