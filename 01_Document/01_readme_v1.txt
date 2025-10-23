cara membuat java web scpect
- tomcat 7
- jdk 8
- MAVEN
- hatml menggunakan tail win versi 4 terkahir

ChatGPT said:

Baik, saya buatkan panduan step-by-step membuat Java Web Project (Servlet/JSP) dengan Maven, menggunakan Tomcat 7, JDK 8, dan TailwindCSS v4 terbaru:

1. Persiapan Lingkungan

Install JDK 8 → pastikan java -version menampilkan JDK 1.8.

Install Apache Tomcat 7 → misalnya di D:\apache-tomcat-7.0.109.

Install Maven → cek dengan mvn -v.

Tambahkan JAVA_HOME, CATALINA_HOME, dan MAVEN_HOME ke Environment Variables.

2. Membuat Project Maven

Buka terminal lalu jalankan:

mvn archetype:generate -DgroupId=com.example \
    -DartifactId=tailwind-webapp \
    -DarchetypeArtifactId=maven-archetype-webapp \
    -DinteractiveMode=false


Struktur project akan terbentuk:

tailwind-webapp/
 ├─ src/main/java/        → kode Java (servlet, service, dll)
 ├─ src/main/webapp/      → JSP, HTML, CSS, JS
 │   └─ WEB-INF/web.xml
 ├─ pom.xml

3. Konfigurasi pom.xml

Tambahkan dependency untuk Servlet API dan JSP (supaya bisa compile):

<dependencies>
    <!-- Servlet API (disediakan Tomcat saat runtime, jadi scope=provided) -->
    <dependency>
        <groupId>javax.servlet</groupId>
        <artifactId>javax.servlet-api</artifactId>
        <version>3.0.1</version>
        <scope>provided</scope>
    </dependency>

    <!-- JSTL untuk JSP -->
    <dependency>
        <groupId>javax.servlet</groupId>
        <artifactId>jstl</artifactId>
        <version>1.2</version>
    </dependency>
</dependencies>

<build>
    <finalName>tailwind-webapp</finalName>
    <plugins>
        <!-- Plugin untuk Tomcat7 Maven -->
        <plugin>
            <groupId>org.apache.tomcat.maven</groupId>
            <artifactId>tomcat7-maven-plugin</artifactId>
            <version>2.2</version>
            <configuration>
                <url>http://localhost:8080/manager/text</url>
                <server>TomcatServer</server>
                <path>/tailwind-webapp</path>
            </configuration>
        </plugin>
    </plugins>
</build>


Catatan: Untuk server perlu konfigurasi di settings.xml Maven agar bisa deploy langsung ke Tomcat.

4. Tambah Servlet

Buat file HelloServlet.java di src/main/java/com/example/HelloServlet.java:

package com.example;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;

public class HelloServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        out.println("<!DOCTYPE html>");
        out.println("<html lang='en'>");
        out.println("<head>");
        out.println("<meta charset='UTF-8'>");
        out.println("<meta name='viewport' content='width=device-width, initial-scale=1.0'>");
        out.println("<title>Hello Tailwind</title>");
        out.println("<script src='https://cdn.tailwindcss.com'></script>");
        out.println("</head>");
        out.println("<body class='bg-gray-100 flex items-center justify-center h-screen'>");
        out.println("<div class='p-6 max-w-sm bg-white rounded-xl shadow-lg space-y-4'>");
        out.println("<h1 class='text-2xl font-bold text-blue-600'>Hello, TailwindCSS + Servlet!</h1>");
        out.println("<p class='text-gray-500'>Java Web dengan Tomcat 7, JDK 8, Maven, Tailwind v4.</p>");
        out.println("</div>");
        out.println("</body>");
        out.println("</html>");
    }
}

5. Konfigurasi web.xml

Edit src/main/webapp/WEB-INF/web.xml:

<web-app xmlns="http://java.sun.com/xml/ns/javaee" version="3.0">
    <servlet>
        <servlet-name>hello</servlet-name>
        <servlet-class>com.example.HelloServlet</servlet-class>
    </servlet>
    <servlet-mapping>
        <servlet-name>hello</servlet-name>
        <url-pattern>/hello</url-pattern>
    </servlet-mapping>
</web-app>

6. Tambah TailwindCSS v4

Karena Tailwind v4 sudah tersedia via CDN, cukup tambahkan di <head> JSP/HTML:

<script src="https://cdn.tailwindcss.com"></script>


Kalau ingin offline build dengan npm (lebih advanced), bisa integrasi dengan frontend-maven-plugin, tapi untuk awal cukup CDN.

7. Build & Run

Build war file:

mvn clean package


→ menghasilkan target/tailwind-webapp.war.

Deploy ke Tomcat:
Salin file .war ke TOMCAT_HOME/webapps/.

Jalankan Tomcat:

startup.bat   # Windows
./startup.sh  # Linux/Mac


Akses di browser:

http://localhost:8080/tailwind-webapp/hello


👉 Hasilnya: Tampilan sederhana dengan TailwindCSS 4, dijalankan di Tomcat 7 + JDK 8 via Maven.