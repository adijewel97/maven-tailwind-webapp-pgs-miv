// ===============================
//  UIController v3.1 - Adis Edition (Stable & Auto-Restore)
// ===============================
class UIController {
    constructor() {
        this.sidebar = document.getElementById('sidebar');
        this.content = document.getElementById('content-wrapper');
        this.pageContent = document.getElementById('page-content');
        this.initEventListeners();

        // ✅ Saat halaman pertama kali dibuka / refresh
        const lastPage = localStorage.getItem('lastPage');
        if (lastPage) {
            this.setActiveLink(lastPage);
            this.loadPage(lastPage);
        } else {
            const defaultPage = 'views/dashboard/dashboard';
            this.setActiveLink(defaultPage);
            this.loadPage(defaultPage);
        }
    }

    // ===============================
    // 🔸 Event Listener
    // ===============================
    initEventListeners() {
        // 🔹 Toggle sidebar
        const toggleBtn = document.querySelector('.toggleSidebar');
        if (toggleBtn) toggleBtn.addEventListener('click', () => this.toggleSidebar());

        // 🔹 Klik link sidebar
        document.querySelectorAll('.sidebar-link').forEach(link => {
            link.addEventListener('click', (e) => {
                e.preventDefault();
                const page = link.dataset.page;
                if (!page) return;

                // Reset semua link jadi normal
                document.querySelectorAll('.sidebar-link').forEach(l => {
                    l.classList.remove(
                        'bg-orange-100', 'text-orange-600', 'text-red-900',
                        'font-semibold', 'border-l-4', 'border-orange-600'
                    );
                });

                // Tandai aktif
                link.classList.add(
                    'bg-orange-100', 'text-red-900', 'font-semibold',
                    'border-l-4', 'border-orange-600'
                );

                // Jika submenu, buka parent
                const parentDropdown = link.closest('#submenu-monitoring');
                if (parentDropdown) {
                    parentDropdown.classList.remove('hidden');
                    const arrow = document.getElementById('arrow-monitoring');
                    if (arrow) arrow.classList.add('rotate-180');
                }

                // Simpan dan muat halaman
                localStorage.setItem('lastPage', page);
                this.loadPage(page);
            });
        });

        // 🔹 Toggle dropdown submenu
        document.querySelectorAll('.toggleDropdown').forEach(btn => {
            btn.addEventListener('click', () => {
                const menuId = btn.dataset.menu;
                const arrowId = btn.dataset.arrow;
                this.toggleDropdown(menuId, arrowId);
            });
        });

        // 🔹 Bell & Profile submenu
        document.querySelectorAll('.toggleSubmenuBell').forEach(btn => {
            btn.addEventListener('click', () => this.toggleSubmenuBell());
        });
        document.querySelectorAll('.toggleSubmenuProfile').forEach(btn => {
            btn.addEventListener('click', () => this.toggleSubmenuProfile());
        });

        // 🔹 Tutup submenu kalau klik di luar
        document.addEventListener('click', (event) => this.closeSubmenusOnOutsideClick(event));
    }

    // ===============================
    // 🔸 Sidebar & Dropdown
    // ===============================
    toggleSidebar() {
        if (this.sidebar.classList.contains('w-[300px]')) {
            this.sidebar.classList.replace('w-[300px]', 'w-0');
            this.sidebar.classList.add('hidden');
            this.content.classList.replace('ml-[300px]', 'ml-0');
        } else {
            this.sidebar.classList.remove('hidden', 'w-0');
            this.sidebar.classList.add('w-[300px]');
            this.content.classList.replace('ml-0', 'ml-[300px]');
        }
    }

    toggleDropdown(menuId, arrowId) {
        const submenu = document.getElementById(menuId);
        const arrow = document.getElementById(arrowId);
        if (!submenu || !arrow) return;

        const isHidden = submenu.classList.contains('hidden');
        if (isHidden) {
            submenu.classList.remove('hidden');
            submenu.style.maxHeight = submenu.scrollHeight + 'px';
            arrow.classList.add('rotate-180');
            submenu.addEventListener('transitionend', () => submenu.style.maxHeight = 'none', { once: true });
        } else {
            submenu.style.maxHeight = submenu.scrollHeight + 'px';
            submenu.offsetHeight;
            submenu.style.transition = 'max-height 0.3s ease-in-out';
            submenu.style.maxHeight = '0';
            arrow.classList.remove('rotate-180');
            submenu.addEventListener('transitionend', () => {
                submenu.classList.add('hidden');
                submenu.style.maxHeight = '';
            }, { once: true });
        }
    }

    toggleSubmenuBell() {
        const submenuBell = document.getElementById("submenu-bell");
        const submenuProfile = document.getElementById("submenu-profile");
        submenuBell?.classList.toggle("hidden");
        submenuProfile?.classList.add("hidden");
    }

    toggleSubmenuProfile() {
        const submenuProfile = document.getElementById("submenu-profile");
        const submenuBell = document.getElementById("submenu-bell");
        submenuProfile?.classList.toggle("hidden");
        submenuBell?.classList.add("hidden");
    }

    closeSubmenusOnOutsideClick(event) {
        const submenuBell = document.getElementById("submenu-bell");
        const submenuProfile = document.getElementById("submenu-profile");
        const bell = document.querySelector(".toggleSubmenuBell");
        const profile = document.querySelector(".toggleSubmenuProfile");
        if (submenuBell && bell && !bell.contains(event.target) && !submenuBell.contains(event.target))
            submenuBell.classList.add("hidden");
        if (submenuProfile && profile && !profile.contains(event.target) && !submenuProfile.contains(event.target))
            submenuProfile.classList.add("hidden");
    }

    // ===============================
    // 🔸 Load Page via Fetch
    // ===============================
    loadPage(pagePath) {
        if (!this.pageContent) return;

        // ✅ Perbaikan path agar selalu dari root context
        const contextPath = window.location.pathname.split("/")[1];
        const fullUrl = `/${contextPath}/${pagePath.replace(/^\//, "")}${pagePath.endsWith(".jsp") ? "" : ".jsp"}`;

        // Efek fade
        this.pageContent.classList.add('opacity-0', 'transition-opacity', 'duration-300');
        window.scrollTo({ top: 0, behavior: 'smooth' });

        setTimeout(() => {
            this.pageContent.innerHTML = `
                <div class="flex items-center justify-center py-10 text-gray-500">
                    <i class="fa fa-spinner fa-spin mr-2"></i> Memuat halaman...
                </div>
            `;

            fetch(fullUrl, { cache: "no-store" })
                .then(resp => {
                    if (!resp.ok) throw new Error(`Halaman tidak ditemukan (${resp.status})`);
                    return resp.text();
                })
                .then(html => {
                    this.pageContent.innerHTML = html;
                    setTimeout(() => this.pageContent.classList.remove('opacity-0'), 50);

                    // Jalankan ulang script
                    const scripts = this.pageContent.querySelectorAll('script');
                    scripts.forEach(oldScript => {
                        const newScript = document.createElement('script');
                        if (oldScript.src) newScript.src = oldScript.src;
                        else newScript.textContent = oldScript.textContent;
                        document.body.appendChild(newScript);
                        setTimeout(() => newScript.remove(), 1000);
                    });

                    // Auto init DataTables
                    if (typeof this.autoInitDataTables === "function") {
                        this.autoInitDataTables();
                    }
                })
                .catch(err => {
                    console.error(err);
                    this.pageContent.innerHTML = `
                        <div class="text-center text-red-600 py-10">
                            <i class="fa fa-exclamation-triangle text-3xl mb-2"></i><br>
                            <strong>Gagal memuat halaman!</strong><br>
                            <span class="text-gray-500 text-sm">${err.message}</span>
                        </div>
                    `;
                    this.pageContent.classList.remove('opacity-0');
                });
        }, 200);
    }

    // ===============================
    // 🔸 Auto Init DataTables
    // ===============================
    autoInitDataTables() {
        if (typeof $ === 'undefined' || !$.fn.DataTable) return;
        this.pageContent.querySelectorAll('table').forEach(tbl => {
            const id = tbl.id ? `#${tbl.id}` : null;
            if (id && !$.fn.DataTable.isDataTable(id)) {
                $(id).DataTable({
                    pageLength: 10,
                    searching: true,
                    responsive: true,
                    language: {
                        url: '//cdn.datatables.net/plug-ins/1.13.4/i18n/id.json'
                    }
                });
            }
        });
    }

    // ===============================
    // 🔸 Set Active Link
    // ===============================
    setActiveLink(page) {
        document.querySelectorAll('.sidebar-link').forEach(link => {
            const linkPage = link.dataset.page;
            if (linkPage === page) {
                link.classList.add('bg-orange-100', 'text-red-900', 'font-semibold', 'border-l-4', 'border-orange-600');
                const parentDropdown = link.closest('#submenu-monitoring');
                if (parentDropdown) {
                    parentDropdown.classList.remove('hidden');
                    const arrow = document.getElementById('arrow-monitoring');
                    if (arrow) arrow.classList.add('rotate-180');
                }
            } else {
                link.classList.remove('bg-orange-100', 'text-red-900', 'font-semibold', 'border-l-4', 'border-orange-600');
            }
        });
    }
}

// ✅ Inisialisasi controller setelah DOM siap
document.addEventListener('DOMContentLoaded', () => new UIController());
