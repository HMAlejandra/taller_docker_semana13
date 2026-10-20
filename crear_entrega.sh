#!/bin/bash

echo "================================================================"
echo "📦 CREANDO ARCHIVO DE ENTREGA"
echo "================================================================"
echo ""

# Archivos obligatorios
echo "✅ Verificando archivos obligatorios..."
FILES=(
    "Dockerfile"
    ".dockerignore"
    "pom.xml"
    "FORENSIC_REPORT.md"
    "audit_session.log"
)

MISSING=0
for FILE in "${FILES[@]}"; do
    if [ -f "$FILE" ]; then
        echo "  ✅ $FILE"
    else
        echo "  ❌ $FILE - NO ENCONTRADO"
        MISSING=$((MISSING + 1))
    fi
done

if [ -d "src" ]; then
    echo "  ✅ src/"
else
    echo "  ❌ src/ - NO ENCONTRADO"
    MISSING=$((MISSING + 1))
fi

echo ""

if [ $MISSING -gt 0 ]; then
    echo "❌ Faltan $MISSING archivo(s). No se puede crear el archivo de entrega."
    exit 1
fi

# Crear archivo tar.gz
echo "📦 Creando taller_docker_semana13.tar.gz..."
tar -czf taller_docker_semana13.tar.gz \
  Dockerfile \
  .dockerignore \
  pom.xml \
  src/ \
  audit_session.log \
  FORENSIC_REPORT.md \
  README.md

if [ $? -eq 0 ]; then
    echo ""
    echo "================================================================"
    echo "✅ ARCHIVO CREADO EXITOSAMENTE"
    echo "================================================================"
    echo ""
    ls -lh taller_docker_semana13.tar.gz
    echo ""
    echo "📋 Contenido del archivo:"
    tar -tzf taller_docker_semana13.tar.gz | head -20
    echo ""
    echo "✅ ¡Listo para entregar!"
    echo ""
else
    echo "❌ Error al crear el archivo"
    exit 1
fi
