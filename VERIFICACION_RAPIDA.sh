#!/bin/bash

# ========================================
# Script de Verificación Rápida
# Taller Docker Semana 13 - ID: 883413
# ========================================

echo "================================================"
echo "🔍 VERIFICACIÓN RÁPIDA DEL PROYECTO"
echo "================================================"
echo ""

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

ERRORS=0

# ========================================
# 1. Verificar Archivos del Proyecto
# ========================================
echo -e "${YELLOW}[1/10] Verificando archivos del proyecto...${NC}"

FILES=("Dockerfile" ".dockerignore" "pom.xml" "src/main/java/com/ecoair/EcoAirApplication.java" "src/main/resources/application.properties")

for FILE in "${FILES[@]}"; do
    if [ -f "$FILE" ]; then
        echo "  ✅ $FILE"
    else
        echo -e "  ${RED}❌ $FILE NO ENCONTRADO${NC}"
        ERRORS=$((ERRORS + 1))
    fi
done
echo ""

# ========================================
# 2. Verificar Docker
# ========================================
echo -e "${YELLOW}[2/10] Verificando Docker...${NC}"
if command -v docker &> /dev/null; then
    echo "  ✅ Docker instalado: $(docker --version)"
else
    echo -e "  ${RED}❌ Docker NO está instalado${NC}"
    ERRORS=$((ERRORS + 1))
fi

if docker ps &> /dev/null; then
    echo "  ✅ Docker daemon corriendo"
else
    echo -e "  ${RED}❌ Docker daemon NO está corriendo${NC}"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# ========================================
# 3. Verificar Imagen
# ========================================
echo -e "${YELLOW}[3/10] Verificando imagen Docker...${NC}"
if docker images eco-air-backend:1.0.0 | grep -q "1.0.0"; then
    SIZE=$(docker images eco-air-backend:1.0.0 --format '{{.Size}}')
    echo "  ✅ Imagen eco-air-backend:1.0.0 existe (Tamaño: $SIZE)"
else
    echo -e "  ${YELLOW}⚠️  Imagen NO construida aún${NC}"
    echo "  💡 Ejecuta: docker build --build-arg STUDENT_ID=\"883413\" -t eco-air-backend:1.0.0 ."
fi
echo ""

# ========================================
# 4. Verificar Contenedor Activo
# ========================================
echo -e "${YELLOW}[4/10] Verificando contenedor activo...${NC}"
if docker ps | grep -q "eco_air_active"; then
    echo "  ✅ Contenedor eco_air_active corriendo"
    
    # Verificar puerto
    if docker ps | grep eco_air_active | grep -q "8080"; then
        echo "  ✅ Puerto 8080 mapeado"
    fi
else
    echo -e "  ${YELLOW}⚠️  Contenedor NO está corriendo${NC}"
    echo "  💡 Ejecuta: docker run -d --name eco_air_active -p 8080:8080 eco-air-backend:1.0.0"
fi
echo ""

# ========================================
# 5. Verificar ID del Estudiante
# ========================================
echo -e "${YELLOW}[5/10] Verificando ID del estudiante en Dockerfile...${NC}"
if grep -q "STUDENT_ID" Dockerfile; then
    echo "  ✅ ARG STUDENT_ID presente en Dockerfile"
fi
if grep -q "OPERATOR_ID" Dockerfile; then
    echo "  ✅ ENV OPERATOR_ID presente en Dockerfile"
fi

if docker ps | grep -q "eco_air_active"; then
    OPERATOR_ID=$(docker exec eco_air_active env 2>/dev/null | grep OPERATOR_ID | cut -d'=' -f2)
    if [ "$OPERATOR_ID" = "883413" ]; then
        echo -e "  ${GREEN}✅ OPERATOR_ID=883413 verificado en contenedor${NC}"
    else
        echo -e "  ${RED}❌ OPERATOR_ID incorrecto: $OPERATOR_ID${NC}"
        ERRORS=$((ERRORS + 1))
    fi
fi
echo ""

# ========================================
# 6. Verificar Usuario sin Privilegios
# ========================================
echo -e "${YELLOW}[6/10] Verificando usuario sin privilegios...${NC}"
if grep -q "sensor_user" Dockerfile; then
    echo "  ✅ Usuario sensor_user configurado en Dockerfile"
fi

if docker ps | grep -q "eco_air_active"; then
    USER_CHECK=$(docker top eco_air_active -o user 2>/dev/null | grep -v USER | head -1)
    if echo "$USER_CHECK" | grep -q "sensor_user\|10001"; then
        echo -e "  ${GREEN}✅ Contenedor ejecutándose como sensor_user${NC}"
    else
        echo -e "  ${RED}❌ Contenedor ejecutándose como: $USER_CHECK${NC}"
        ERRORS=$((ERRORS + 1))
    fi
fi
echo ""

# ========================================
# 7. Verificar Endpoint
# ========================================
echo -e "${YELLOW}[7/10] Verificando endpoint HTTP...${NC}"
if docker ps | grep -q "eco_air_active"; then
    if curl -s http://localhost:8080 &> /dev/null; then
        RESPONSE=$(curl -s http://localhost:8080)
        if echo "$RESPONSE" | grep -q "OPERATIONAL"; then
            echo -e "  ${GREEN}✅ Endpoint / responde correctamente${NC}"
        else
            echo -e "  ${RED}❌ Endpoint responde pero contenido inesperado${NC}"
            ERRORS=$((ERRORS + 1))
        fi
        
        if echo "$RESPONSE" | grep -q "883413"; then
            echo -e "  ${GREEN}✅ operator_id=883413 presente en respuesta${NC}"
        else
            echo -e "  ${RED}❌ operator_id no encontrado en respuesta${NC}"
            ERRORS=$((ERRORS + 1))
        fi
    else
        echo -e "  ${YELLOW}⚠️  Endpoint no responde (contenedor iniciando o error)${NC}"
        echo "  💡 Espera unos segundos o verifica logs: docker logs eco_air_active"
    fi
else
    echo -e "  ${YELLOW}⚠️  Contenedor no está corriendo${NC}"
fi
echo ""

# ========================================
# 8. Verificar .dockerignore
# ========================================
echo -e "${YELLOW}[8/10] Verificando .dockerignore...${NC}"
IGNORE_ITEMS=("target/" ".git/" "*.log" "README.md")
for ITEM in "${IGNORE_ITEMS[@]}"; do
    if grep -q "$ITEM" .dockerignore; then
        echo "  ✅ $ITEM en .dockerignore"
    else
        echo -e "  ${YELLOW}⚠️  $ITEM falta en .dockerignore${NC}"
    fi
done
echo ""

# ========================================
# 9. Verificar pom.xml
# ========================================
echo -e "${YELLOW}[9/10] Verificando pom.xml...${NC}"
if grep -q "spring-boot-starter-web" pom.xml; then
    echo "  ✅ spring-boot-starter-web presente"
fi
if grep -q "eco-air-backend" pom.xml; then
    echo "  ✅ artifactId correcto"
fi
if grep -q "<finalName>eco-air-backend</finalName>" pom.xml; then
    echo "  ✅ finalName configurado correctamente"
fi
echo ""

# ========================================
# 10. Verificar Archivos de Documentación
# ========================================
echo -e "${YELLOW}[10/10] Verificando archivos de documentación...${NC}"
DOC_FILES=("README.md" "FORENSIC_REPORT.md" "INSTRUCCIONES_PASO_A_PASO.md" "RESUMEN_PROYECTO.md")
for FILE in "${DOC_FILES[@]}"; do
    if [ -f "$FILE" ]; then
        echo "  ✅ $FILE"
    else
        echo -e "  ${YELLOW}⚠️  $FILE no encontrado${NC}"
    fi
done

if [ -f "audit_session.log" ]; then
    echo "  ✅ audit_session.log (generado)"
else
    echo -e "  ${YELLOW}⚠️  audit_session.log no generado aún${NC}"
    echo "  💡 Ejecuta: ./run_audit.sh | tee audit_session.log"
fi
echo ""

# ========================================
# RESUMEN FINAL
# ========================================
echo "================================================"
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✅ VERIFICACIÓN EXITOSA - SIN ERRORES${NC}"
    echo "================================================"
    echo ""
    echo "🎉 ¡El proyecto está listo!"
    echo ""
    echo "Próximos pasos:"
    echo "1. Si no lo has hecho, ejecuta la auditoría completa:"
    echo "   ./run_audit.sh | tee audit_session.log"
    echo ""
    echo "2. Completa FORENSIC_REPORT.md con las evidencias"
    echo ""
    echo "3. Crea el archivo de entrega:"
    echo "   tar -czf taller_docker_semana13.tar.gz Dockerfile .dockerignore pom.xml src/ audit_session.log FORENSIC_REPORT.md"
else
    echo -e "${RED}❌ VERIFICACIÓN COMPLETADA CON $ERRORS ERROR(ES)${NC}"
    echo "================================================"
    echo ""
    echo "⚠️  Revisa los errores anteriores y corrige antes de continuar"
fi
echo ""

# ========================================
# COMANDOS ÚTILES
# ========================================
echo "📋 Comandos útiles:"
echo "  • Ver logs:        docker logs eco_air_active"
echo "  • Ver stats:       docker stats --no-stream eco_air_active"
echo "  • Detener:         docker stop eco_air_active"
echo "  • Eliminar:        docker rm -f eco_air_active"
echo "  • Reconstruir:     docker build --build-arg STUDENT_ID=\"883413\" -t eco-air-backend:1.0.0 ."
echo ""
