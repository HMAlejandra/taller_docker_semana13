#!/bin/bash

echo "================================================================"
echo "🧪 PRUEBAS DE CALIBRACIÓN DE MEMORIA - RETO 3.2"
echo "================================================================"
echo ""

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# ========================================
# Prueba con 256MB
# ========================================
echo -e "${YELLOW}[PRUEBA 1/3] Probando con 256MB de RAM...${NC}"
docker rm -f eco_air_active 2>/dev/null
docker run -d --name eco_air_active -m 256m -p 8080:8080 eco-air-backend:1.0.0

echo "Esperando 20 segundos para que la aplicación inicie..."
sleep 20

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "RESULTADO CON 256MB:"
echo "═══════════════════════════════════════════════════════════════"
docker logs --timestamps eco_air_active 2>&1 | grep "Started EcoAirApplication"
echo ""
echo "Estadísticas:"
docker stats --no-stream eco_air_active
echo "═══════════════════════════════════════════════════════════════"
echo ""

# ========================================
# Prueba con 384MB
# ========================================
echo -e "${YELLOW}[PRUEBA 2/3] Probando con 384MB de RAM...${NC}"
docker rm -f eco_air_active 2>/dev/null
docker run -d --name eco_air_active -m 384m -p 8080:8080 eco-air-backend:1.0.0

echo "Esperando 20 segundos para que la aplicación inicie..."
sleep 20

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "RESULTADO CON 384MB:"
echo "═══════════════════════════════════════════════════════════════"
docker logs --timestamps eco_air_active 2>&1 | grep "Started EcoAirApplication"
echo ""
echo "Estadísticas:"
docker stats --no-stream eco_air_active
echo "═══════════════════════════════════════════════════════════════"
echo ""

# ========================================
# Prueba con 512MB
# ========================================
echo -e "${YELLOW}[PRUEBA 3/3] Probando con 512MB de RAM...${NC}"
docker rm -f eco_air_active 2>/dev/null
docker run -d --name eco_air_active -m 512m -p 8080:8080 eco-air-backend:1.0.0

echo "Esperando 20 segundos para que la aplicación inicie..."
sleep 20

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "RESULTADO CON 512MB:"
echo "═══════════════════════════════════════════════════════════════"
docker logs --timestamps eco_air_active 2>&1 | grep "Started EcoAirApplication"
echo ""
echo "Estadísticas:"
docker stats --no-stream eco_air_active
echo "═══════════════════════════════════════════════════════════════"
echo ""

# ========================================
# Resumen
# ========================================
echo ""
echo "================================================================"
echo -e "${GREEN}✅ PRUEBAS COMPLETADAS${NC}"
echo "================================================================"
echo ""
echo "Copia estos resultados a FORENSIC_REPORT.md"
echo ""
