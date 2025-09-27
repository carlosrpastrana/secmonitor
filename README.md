SecMonitor 🛡️

Monitoreo de Seguridad en Linux con Bash

SecMonitor es un script de monitoreo y detección de seguridad para sistemas Linux.
Su objetivo es ayudar a administradores de sistemas y entusiastas de ciberseguridad a detectar de forma rápida eventos sospechosos y potenciales riesgos de intrusión.

🚀 Características

✅ Detección de intentos de acceso fallidos (SSH y otros servicios)

✅ Monitoreo de puertos abiertos usando ss o netstat

✅ Verificación de integridad de archivos críticos (/etc/passwd, /etc/shadow, /etc/sudoers)

✅ Detección de procesos sospechosos y conexiones de red activas

✅ Registro en log de todas las acciones en /var/log/secmonitor.log

📥 Instalación

Clona este repositorio en tu sistema:

git clone https://github.com/carlosrpastrana/secmonitor.git
cd secmonitor
chmod +x secmonitor.sh


Recomendado: ejecuta como root o con sudo para obtener resultados completos.

⚙️ Uso

Ejecuta el script con las siguientes opciones:

./secmonitor.sh [OPCIÓN]

Opciones disponibles:

--setup	"Configura la verificación de integridad inicial (genera hashes de archivos)"

--monitor	"Ejecuta todas las verificaciones de seguridad"

--help	"Muestra la ayuda y opciones disponibles"

(sin opción)	Ejecuta todas las verificaciones excepto la configuración de integridad.

📊 Ejemplos de uso

1️⃣ Generar hashes iniciales de archivos críticos
sudo ./secmonitor.sh --setup

2️⃣ Ejecutar monitoreo completo
sudo ./secmonitor.sh --monitor

3️⃣ Ver resultados en el log
cat /var/log/secmonitor.log

📂 Archivos críticos monitoreados

/etc/passwd

/etc/shadow

/etc/sudoers

Puedes agregar más rutas editando la variable CRITICAL_FILES en el script.

📌 Requisitos

Linux (Debian, Ubuntu, CentOS, etc.)

Comandos básicos disponibles: grep, ss o netstat, sha256sum

Permisos de root (recomendado para mejores resultados)

🛠 Personalización

Puedes modificar:

Archivos críticos: en CRITICAL_FILES

Ruta de logs: en LOG_FILE

Directorio temporal: en TEMP_DIR

⚠️ Nota de Seguridad

Este script no reemplaza un IDS profesional (como Snort, OSSEC o Wazuh).
Es una herramienta ligera de detección temprana, ideal para entornos pequeños o pruebas de laboratorio.

🚧 Roadmap

- [ ] Alertas en tiempo real (email, Slack, Discord)
- [ ] Reporte diario en formato HTML
- [ ] Bloqueo automático de IPs con múltiples intentos fallidos
- [ ] Honeypot ligero para detectar escaneo de puertos
- [ ] Exportación de resultados en JSON para SIEM
- [ ] Dashboard en consola para monitoreo en vivo


📄 Licencia

Distribuido bajo licencia MIT.
Puedes usarlo, modificarlo y compartirlo libremente, siempre que mantengas el aviso de copyright.
