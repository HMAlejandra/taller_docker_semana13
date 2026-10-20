#!/bin/bash

# ========================================
# Script de Auditoría Automatizada
# Taller Docker Semana 13 - ID: 883413
# ========================================

echo "================================================"
echo "🔍 INICIANDO AUDITORÍA FORENSE"
echo "================================================"
echo ""

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ========================================
# FASE 1: CONSTRUCCIÓN
# ========================================
echo -e "${YELLOW}[FASE 1] Construcción de la imagen${NC}"
echo "Ejecutando: docker build --build-arg STUDENT_ID=\"883413\" -t eco-air-backend:1.0.0 ."
docker build --build-arg STUDENT_ID="883413" -t eco-air-backend:1.0.0 .

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Construcción exitosa${NC}"
else
    echo -e "${RED}❌ Error en la construcción${NC}"
    exit 1
fi
echo ""

# ========================================
# RETO 2.1: Verificación de Capas
# ========================================
echo -e "${YELLOW}[RETO 2.1] Verificación del Desacoplamiento de Capas${NC}"
echo "Comando: docker history --human --format \"table {{.Size}}\t{{.CreatedBy}}\" eco-air-backend:1.0.0"
docker history --human --format "table {{.Size}}\t{{.CreatedBy}}" eco-air-backend:1.0.0
echo ""

# ========================================
# FASE 2: Identidad de la Imagen
# ========================================
echo -e "${YELLOW}[IDENTIDAD] Hash de la Imagen${NC}"
echo "Comando: docker inspect --format='{{.Id}}' eco-air-backend:1.0.0"
IMAGE_HASH=$(docker inspect --format='{{.Id}}' eco-air-backend:1.0.0)
echo "Hash: $IMAGE_HASH"
echo ""

# ========================================
# RETO 2.2: Inspección de Privilegios
# ========================================
echo -e "${YELLOW}[RETO 2.2] Iniciando contenedor y verificando privilegios${NC}"
echo "Limpiando contenedores previos..."
docker rm -f eco_air_active 2>/dev/null

echo "Comando: docker run -d --name eco_air_active -p 8080:8080 eco-air-backend:1.0.0"
docker run -d --name eco_air_active -p 8080:8080 eco-air-backend:1.0.0

echo "Esperando 10 segundos para que la aplicación inicie..."
sleep 10

echo ""
echo "Comando: docker top eco_air_active -o pid,user,comm"
docker top eco_air_active -o pid,user,comm
echo ""

echo "Verificando logs de inicio:"
echo "Comando: docker logs eco_air_active | head -20"
docker logs eco_air_active | head -20
echo ""

echo "Verificando OPERATOR_ID:"
echo "Comando: docker exec eco_air_active env | grep OPERATOR_ID"
docker exec eco_air_active env | grep OPERATOR_ID
echo ""

# ========================================
# RETO 2.3: Test de Inmutabilidad
# ========================================
echo -e "${YELLOW}[RETO 2.3] Test de Penetración - Inmutabilidad${NC}"
echo "Comando: docker exec eco_air_active touch /etc/crontab_fake"
docker exec eco_air_active touch /etc/crontab_fake 2>&1
if [ $? -ne 0 ]; then
    echo -e "${GREEN}✅ Protección correcta: No se puede escribir en /etc/${NC}"
else
    echo -e "${RED}❌ ALERTA: Se pudo escribir en /etc/${NC}"
fi
echo ""

# ========================================
# RETO 2.4: Auditoría de Artefactos
# ========================================
echo -e "${YELLOW}[RETO 2.4] Auditoría de Artefactos de Desarrollo${NC}"
echo "Comando: docker exec eco_air_active which mvn"
docker exec eco_air_active which mvn 2>&1
if [ $? -ne 0 ]; then
    echo -e "${GREEN}✅ Maven NO presente en imagen final${NC}"
else
    echo -e "${RED}❌ ALERTA: Maven encontrado en imagen${NC}"
fi
echo ""

echo "Comando: docker exec eco_air_active find / -name \"*.java\" 2>/dev/null"
JAVA_FILES=$(docker exec eco_air_active find / -name "*.java" 2>/dev/null | grep -v "jre")
if [ -z "$JAVA_FILES" ]; then
    echo -e "${GREEN}✅ Archivos .java NO presentes (excepto JRE)${NC}"
else
    echo -e "${RED}❌ ALERTA: Archivos .java encontrados:${NC}"
    echo "$JAVA_FILES"
fi
echo ""

# ========================================
# RETO 3.1: Inducción de OOM
# ========================================
echo -e "${YELLOW}[RETO 3.1] Inducción del Colapso por Memoria (OOMKilled)${NC}"
echo "Limpiando contenedor anterior..."
docker rm -f eco_air_crash 2>/dev/null

echo "Comando: docker run -d --name eco_air_crash -m 48m eco-air-backend:1.0.0"
docker run -d --name eco_air_crash -m 48m eco-air-backend:1.0.0

echo "Esperando 15 segundos para observar el colapso..."
sleep 15

echo ""
echo "Comando: docker inspect eco_air_crash --format='Status: {{.State.Status}} | ExitCode: {{.State.ExitCode}} | OOMKilled: {{.State.OOMKilled}}'"
docker inspect eco_air_crash --format='Status: {{.State.Status}} | ExitCode: {{.State.ExitCode}} | OOMKilled: {{.State.OOMKilled}}'

OOM_STATUS=$(docker inspect eco_air_crash --format='{{.State.OOMKilled}}')
if [ "$OOM_STATUS" = "true" ]; then
    echo -e "${GREEN}✅ OOMKilled confirmado - Límite de 48MB insuficiente${NC}"
else
    echo -e "${YELLOW}⚠️  Contenedor aún corriendo o error diferente${NC}"
    docker logs eco_air_crash 2>&1 | tail -20
fi
echo ""

# ========================================
# RETO 3.2: Calibración de Memoria
# ========================================
echo -e "${YELLOW}[RETO 3.2] Calibración del Límite Operativo Mínimo${NC}"

for MEMORY in 256m 384m 512m; do
    echo ""
    echo "=========================================="
    echo "Probando con memoria: $MEMORY"
    echo "=========================================="
    
    docker rm -f eco_air_active 2>/dev/null
    
    echo "Comando: docker run -d --name eco_air_active -m $MEMORY -p 8080:8080 eco-air-backend:1.0.0"
    docker run -d --name eco_air_active -m $MEMORY -p 8080:8080 eco-air-backend:1.0.0
    
    echo "Esperando 20 segundos para inicio completo..."
    sleep 20
    
    echo ""
    echo "Estado del contenedor:"
    docker inspect eco_air_active --format='Status: {{.State.Status}} | OOMKilled: {{.State.OOMKilled}}'
    
    echo ""
    echo "Buscando línea de inicio exitoso:"
    docker logs --timestamps eco_air_active 2>&1 | grep "Started EcoAirApplication"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Aplicación iniciada correctamente con $MEMORY${NC}"
        
        echo ""
        echo "Profiling de memoria en caliente:"
        echo "Comando: docker stats --no-stream eco_air_active"
        docker stats --no-stream eco_air_active
        
        echo ""
        echo -e "${GREEN}=========================================="
        echo "✅ UMBRAL MÍNIMO ENCONTRADO: $MEMORY"
        echo "==========================================${NC}"
        
        break
    else
        echo -e "${RED}❌ Fallo con $MEMORY - Probando siguiente valor...${NC}"
    fi
done

echo ""
echo ""
echo "================================================"
echo "🎯 AUDITORÍA COMPLETADA"
echo "================================================"
echo ""
echo "Próximos pasos:"
echo "1. Revisar la salida generada"
echo "2. Copiar los resultados a FORENSIC_REPORT.md"
echo "3. Probar endpoint: curl http://localhost:8080"
echo "4. Ver logs completos: docker logs eco_air_active"
echo "5. Detener contenedor: docker stop eco_air_active"
echo ""
echo "Información de la imagen:"
echo "Hash: $IMAGE_HASH"
echo "Tamaño: $(docker images eco-air-backend:1.0.0 --format '{{.Size}}')"
echo ""
