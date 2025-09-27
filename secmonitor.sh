#!/bin/bash

# SecMonitor - Script de monitoreo de seguridad para Linux
# Funcionalidades: 
# 1. Detección de intentos de acceso fallidos
# 2. Monitoreo de puertos abiertos
# 3. Verificación de integridad de archivos críticos
# 4. Detección de procesos sospechosos

# Configuración
LOG_FILE="/var/log/secmonitor.log"
CRITICAL_FILES=("/etc/passwd" "/etc/shadow" "/etc/sudoers")
TEMP_DIR="/tmp/secmonitor"
HASH_STORE="$TEMP_DIR/file_hashes"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para logging
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Función para verificar e crear directorio temporal
setup() {
    if [ ! -d "$TEMP_DIR" ]; then
        mkdir -p "$TEMP_DIR"
        log "Directorio temporal creado: $TEMP_DIR"
    fi
}

# Función para detección de intentos de acceso fallidos
check_failed_logins() {
    echo -e "${YELLOW}[+] Verificando intentos de acceso fallidos...${NC}"
    
    local failed_ssh=$(grep "Failed password" /var/log/auth.log /var/log/secure 2>/dev/null | wc -l)
    local failed_ssh_today=$(grep "Failed password" /var/log/auth.log /var/log/secure 2>/dev/null | grep "$(date '+%b %d')" | wc -l)
    
    echo "Intentos fallidos totales: $failed_ssh"
    echo "Intentos fallidos hoy: $failed_ssh_today"
    
    if [ "$failed_ssh_today" -gt 10 ]; then
        echo -e "${RED}[!] ALTO número de intentos fallidos hoy!${NC}"
        log "ALERTA: Alto número de intentos de acceso fallidos: $failed_ssh_today"
    fi
    
    log "Verificación de accesos fallidos completada"
    echo
}

# Función para escaneo de puertos
check_open_ports() {
    echo -e "${YELLOW}[+] Escaneando puertos abiertos...${NC}"
    
    # Usar netstat o ss dependiendo de disponibilidad
    if command -v ss &> /dev/null; then
        ss -tuln | grep LISTEN
        log "Puertos abiertos verificados con ss"
    elif command -v netstat &> /dev/null; then
        netstat -tuln | grep LISTEN
        log "Puertos abiertos verificados con netstat"
    else
        echo -e "${RED}[!] No se encontró netstat ni ss${NC}"
        log "ERROR: No se pudo verificar puertos abiertos"
    fi
    
    echo
}

# Función para verificación de integridad de archivos
setup_file_integrity() {
    echo -e "${YELLOW}[+] Configurando verificación de integridad...${NC}"
    
    # Generar hashes iniciales si no existen
    if [ ! -f "$HASH_STORE" ]; then
        echo "Generando hashes iniciales para archivos críticos..."
        for file in "${CRITICAL_FILES[@]}"; do
            if [ -f "$file" ]; then
                sha256sum "$file" >> "$HASH_STORE"
            fi
        done
        log "Hashes iniciales generados"
        echo -e "${GREEN}[+] Hashes iniciales guardados en $HASH_STORE${NC}"
    fi
    
    echo
}

check_file_integrity() {
    echo -e "${YELLOW}[+] Verificando integridad de archivos críticos...${NC}"
    
    if [ ! -f "$HASH_STORE" ]; then
        echo -e "${RED}[!] No se encontraron hashes de referencia. Ejecuta con --setup primero.${NC}"
        return 1
    fi
    
    local temp_check="$TEMP_DIR/integrity_check.tmp"
    > "$temp_check"
    
    for file in "${CRITICAL_FILES[@]}"; do
        if [ -f "$file" ]; then
            sha256sum "$file" >> "$temp_check"
        fi
    done
    
    # Comparar con hashes almacenados
    if diff "$HASH_STORE" "$temp_check" > /dev/null; then
        echo -e "${GREEN}[+] Todos los archivos críticos verificados correctamente${NC}"
        log "Verificación de integridad: PASS"
    else
        echo -e "${RED}[!] ALERTA: Cambios detectados en archivos críticos!${NC}"
        diff "$HASH_STORE" "$temp_check"
        log "ALERTA: Cambios detectados en archivos críticos"
    fi
    
    rm -f "$temp_check"
    echo
}

# Función para detectar procesos sospechosos
check_suspicious_processes() {
    echo -e "${YELLOW}[+] Buscando procesos sospechosos...${NC}"
    
    # Procesos con conexiones de red
    echo "Procesos con conexiones de red:"
    if command -v ss &> /dev/null; then
        ss -tupn | grep -E "(ESTAB|LISTEN)"
    elif command -v netstat &> /dev/null; then
        netstat -tupn | grep -E "(ESTAB|LISTEN)"
    fi
    
    # Procesos con nombres inusuales
    echo -e "\nProcesos con nombres potencialmente sospechosos:"
    ps aux | grep -E "(\.sh|\.py|\.pl|\.php|\.cgi|http|curl|wget|nc|netcat|nmap|sqlmap|hydra)" | \
        grep -v grep | grep -v "$0"
    
    log "Verificación de procesos completada"
    echo
}

# Función para mostrar ayuda
show_help() {
    echo "Uso: $0 [OPCIÓN]"
    echo "Opciones:"
    echo "  --setup          Configurar verificación de integridad"
    echo "  --monitor        Ejecutar todas las verificaciones"
    echo "  --help           Mostrar esta ayuda"
    echo
    echo "Sin opciones: ejecuta todas las verificaciones excepto setup"
}

# Main
case "${1:-}" in
    "--setup")
        setup
        setup_file_integrity
        ;;
    "--monitor")
        setup
        check_failed_logins
        check_open_ports
        check_file_integrity
        check_suspicious_processes
        ;;
    "--help")
        show_help
        ;;
    *)
        setup
        check_failed_logins
        check_open_ports
        check_suspicious_processes
        ;;
esac

echo -e "${GREEN}[+] Monitoreo completado. Ver $LOG_FILE para detalles.${NC}"
