package com.example.utils;

import java.util.HashMap;
import java.util.Map;

public class HttpStatusHelper {

    private static final Map<Integer, StatusInfo> statusMap = new HashMap<>();

    public static class StatusInfo {
        private final String codeStatus;
        private final String codeMessage;

        public StatusInfo(String codeStatus, String codeMessage) {
            this.codeStatus = codeStatus;
            this.codeMessage = codeMessage;
        }

        public String getCodeStatus() { return codeStatus; }
        public String getCodeMessage() { return codeMessage; }
    }

    static {
        statusMap.put(200, new StatusInfo("OK", "Berhasil"));
        statusMap.put(201, new StatusInfo("Created", "Data berhasil dibuat"));
        statusMap.put(204, new StatusInfo("No Content", "Berhasil tetapi tidak ada data"));
        statusMap.put(400, new StatusInfo("Bad Request", "Parameter request salah"));
        statusMap.put(401, new StatusInfo("Unauthorized", "Belum login / session habis"));
        statusMap.put(402, new StatusInfo("Payment Required", "Gagal memproses data internal")); // Custom handle dari kode lama Anda
        statusMap.put(403, new StatusInfo("Forbidden", "Tidak punya hak akses"));
        statusMap.put(404, new StatusInfo("Not Found", "URL atau data tidak ditemukan"));
        statusMap.put(405, new StatusInfo("Method Not Allowed", "Salah method (GET/POST)"));
        statusMap.put(408, new StatusInfo("Request Timeout", "Request timeout"));
        statusMap.put(409, new StatusInfo("Conflict", "Data sudah ada"));
        statusMap.put(422, new StatusInfo("Unprocessable Entity", "Validasi gagal"));
        statusMap.put(429, new StatusInfo("Too Many Requests", "Terlalu banyak request"));
        statusMap.put(500, new StatusInfo("Internal Server Error", "Error program/server"));
        statusMap.put(502, new StatusInfo("Bad Gateway", "Error gateway"));
        statusMap.put(503, new StatusInfo("Service Unavailable", "Database/server tidak aktif"));
        statusMap.put(504, new StatusInfo("Gateway Timeout", "Database timeout"));
    }

    public static StatusInfo getInfo(int code) {
        return statusMap.getOrDefault(code, new StatusInfo("Unknown Error", "Terjadi kesalahan tidak dikenal"));
    }
}