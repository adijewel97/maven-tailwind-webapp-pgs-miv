tailwind-webapp/
│
├─ src/
│  └─ main/
│     ├─ java/
│     │   └─ com/example/HelloServlet.java
│     └─ webapp/
│         ├─ WEB-INF/
│         │   └─ views/
│         │       └─ index.jsp
│         │
│         ├─ src/
│         │   └─ input.css       <-- file sumber Tailwind
│         │
│         ├─ assets/
│         │   └─ css/
│         │       └─ output.css  <-- hasil build Tailwind
│         │
│         ├─ package.json
│         └─ tailwind.config.js
│
└─ pom.xml

📄 src/main/webapp/src/input.css
@tailwind base;
@tailwind components;
@tailwind utilities;

📄 src/main/webapp/tailwind.config.js
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./WEB-INF/views/**/*.jsp", // scan semua JSP
    "./src/**/*.html",          // kalau ada HTML biasa
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}

📄 src/main/webapp/WEB-INF/views/index.jsp
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Tailwind + JSP</title>
    <link href="${pageContext.request.contextPath}/assets/css/output.css" rel="stylesheet">
</head>
<body class="bg-gray-100 flex items-center justify-center h-screen">
    <div class="p-8 bg-white shadow-xl rounded-lg">
        <h1 class="text-3xl font-bold text-blue-600">Hello Tailwind + JSP 🚀</h1>
        <p class="mt-4 text-gray-700">Ini contoh integrasi TailwindCSS dengan Tomcat 7 + Maven.</p>
    </div>
</body>
</html>

📄 package.json (final, Tailwind v3)
{
  "name": "webapp",
  "version": "1.0.0",
  "scripts": {
    "build": "tailwindcss -i ./src/input.css -o ./assets/css/output.css",
    "watch": "tailwindcss -i ./src/input.css -o ./assets/css/output.css --watch"
  },
  "devDependencies": {
    "autoprefixer": "^10.4.21",
    "postcss": "^8.5.6",
    "tailwindcss": "^3.4.14"
  }
}

▶️ Cara jalanin

Masuk ke folder src/main/webapp

Jalankan build sekali:

npm run build

-- D:\00_database_docker\APP_MAVEN\PRJ_JAVA_MAVEN\tailwind-webapp\src\main\webapp>npm run build

atau kalau mau auto update:

npm run watch


Start Tomcat via Maven:

mvn tomcat7:run


Akses di browser:

http://localhost:8080/tailwind-webapp/index.jsp


⚡ Dengan struktur ini, output CSS selalu ada di assets/css/output.css, dan JSP tinggal load pakai:

<link href="${pageContext.request.contextPath}/assets/css/output.css" rel="stylesheet">


npx tailwindcss -i ./src/input.css -o ./src/output.css --watch

1.
  cd src\main\webapp
2.
  npx tailwindcss -i ./src/input.css -o ./assets/css/output.css --watch
3.
  npx tailwindcss -i ./src/main/webapp/assets/css/input.css -o ./src/main/webapp/assets/css/output.css --watch
