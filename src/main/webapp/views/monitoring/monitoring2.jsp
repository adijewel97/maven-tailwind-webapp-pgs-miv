<div class="bg-white w-full max-w-full p-6">
  <fieldset class="border border-gray-300 rounded-lg p-6 w-full max-w-5xl mx-0 sm:mx-4">
    <legend class="text-lg font-semibold px-3 py-1">
      Monitoring Rekon PLN Vs Bank
    </legend>

    <div class="flex flex-col gap-4">
      <!-- Contoh isi form / konten -->
      <div>
        <label class="block text-gray-700">Nama:</label>
        <input type="text" class="border border-gray-300 rounded-md p-2 w-full" />
      </div>

      <div>
        <label class="block text-gray-700">Tanggal:</label>
        <input type="date" class="border border-gray-300 rounded-md p-2 w-full" />
      </div>
    </div>

    <!-- Table wrapper -->
    <div class="p-4 overflow-x-auto">
        <table class="min-w-full table-auto border border-gray-300 text-sm rounded-lg">
            <thead class="bg-gray-200">
                <tr>
                    <th class="px-3 py-2 border border-gray-300">No</th>
                    <th class="px-3 py-2 border border-gray-300">Kolom A</th>
                    <th class="px-3 py-2 border border-gray-300">Kolom B</th>
                    <th class="px-3 py-2 border border-gray-300">Kolom C</th>
                    <th class="px-3 py-2 border border-gray-300">Kolom D</th>
                </tr>
            </thead>
            <tbody>
                <% for(int i=1;i<=80;i++){ %>
                <tr class="<%= i%2==0 ? "bg-gray-50" : "" %>">
                    <td class="px-3 py-2 border border-gray-300"><%= i %></td>
                    <td class="px-3 py-2 border border-gray-300">Data A<%= i %></td>
                    <td class="px-3 py-2 border border-gray-300">Data B<%= i %></td>
                    <td class="px-3 py-2 border border-gray-300">Data C<%= i %></td>
                    <td class="px-3 py-2 border border-gray-300">Data D<%= i %></td>
                </tr>
                <% } %>
            </tbody>
        </table>
    </div>
  </fieldset>
</div>