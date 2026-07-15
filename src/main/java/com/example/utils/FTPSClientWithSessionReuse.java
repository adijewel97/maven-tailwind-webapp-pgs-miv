package com.example.utils;

import org.apache.commons.net.ftp.FTPSClient;
import javax.net.ssl.SSLSession;
import javax.net.ssl.SSLSessionContext;
import javax.net.ssl.SSLSocket;
import java.io.IOException;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.net.Socket;
import java.util.logging.Logger;

public class FTPSClientWithSessionReuse extends FTPSClient {
    private static final Logger logger = 
            Logger.getLogger(FTPSClientWithSessionReuse.class.getName());

    public FTPSClientWithSessionReuse(String protocol, boolean isImplicit) {
        super(protocol, isImplicit);
    }

    @Override
    protected void _prepareDataSocket_(Socket socket) throws IOException {
        if (socket instanceof SSLSocket) {
            SSLSocket dataSocket = (SSLSocket) socket;
            SSLSocket controlSocket = (SSLSocket) _socket_;

            SSLSession controlSession = controlSocket.getSession();
            if (controlSession != null) {
                try {
                    // 1. Ambil session context dari sesi kontrol (Ini mengembalikan SSLSessionContext)
                    SSLSessionContext context = controlSession.getSessionContext();
                    if (context != null) {
                        // 2. Di Java 8, kelas aslinya adalah sun.security.ssl.SSLSessionContextImpl
                        // Kita cari field "sessionHostPortCache" di dalam kelas implementasi tersebut
                        Field keyCol = context.getClass().getDeclaredField("sessionHostPortCache");
                        keyCol.setAccessible(true);
                        Object cache = keyCol.get(context);

                        if (cache != null) {
                            // 3. Masukkan sesi kontrol ke dalam cache data socket yang baru akan dibuka
                            Method putMethod = cache.getClass().getDeclaredMethod("put", Object.class, Object.class);
                            putMethod.setAccessible(true);
                            
                            String key = String.format("%s:%s", 
                                    dataSocket.getInetAddress().getHostAddress(), 
                                    String.valueOf(dataSocket.getPort())).toLowerCase();
                            
                            putMethod.invoke(cache, key, controlSession);
                            logger.info("[FTP] Berhasil menginjeksikan TLS Session Reuse untuk Java 8.");
                        }
                    }
                } catch (Exception e) {
                    // Jika gagal, log error-nya secara detail agar kita tahu field mana yang meleset
                    logger.warning("[FTP] Gagal mengaplikasikan TLS Session Reuse di Java 8: " + e.toString());
                }
            }
        }
    }
}