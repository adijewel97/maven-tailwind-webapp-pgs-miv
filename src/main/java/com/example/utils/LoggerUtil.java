package com.example.utils;

import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.*;

public class LoggerUtil {
    private static final String LOG_DIRECTORY = "src/main/resources/logs";
    private static final Map<Class<?>, Logger> loggers = new HashMap<>();

    public static Logger getLogger(Class<?> clazz) {
        return loggers.computeIfAbsent(clazz, key -> {
            Logger logger = Logger.getLogger(key.getName());
            logger.setUseParentHandlers(false); // Hindari duplikasi log di konsol

            try {
                // Buat folder log jika belum ada
                File logDir = new File(LOG_DIRECTORY);
                if (!logDir.exists()) {
                    logDir.mkdirs();
                }

                // Nama file log dengan format tanggal
                String logFileName = new SimpleDateFormat("yyyyMMdd").format(new Date()) + "_LogClientApp.log";
                File logFile = new File(LOG_DIRECTORY, logFileName);
                
                // Cegah duplikasi handler
                if (logger.getHandlers().length == 0) {
                    FileHandler fileHandler = new FileHandler(logFile.getAbsolutePath(), 10 * 1024 * 1024, 1, true);
                    
                    // Formatter log dengan timestamp milidetik
                    Formatter customFormatter = new Formatter() {
                        private final SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");

                        @Override
                        public String format(LogRecord record) {
                            return dateFormat.format(new Date(record.getMillis())) + " - " +
                                   record.getLevel() + ": " +
                                   formatMessage(record) + System.lineSeparator();
                        }
                    };

                    fileHandler.setFormatter(customFormatter);
                    logger.addHandler(fileHandler);

                    // Tambahkan ConsoleHandler agar log tampil di terminal
                    ConsoleHandler consoleHandler = new ConsoleHandler();
                    consoleHandler.setLevel(Level.INFO);
                    consoleHandler.setFormatter(customFormatter);
                    logger.addHandler(consoleHandler);
                }

            } catch (IOException e) {
                e.printStackTrace();
            }

            return logger;
        });
    }
}
