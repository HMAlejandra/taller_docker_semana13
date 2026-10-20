EcoAir Backend - Taller Docker Semana 13

**Proyecto:** Contenerización, Seguridad de Runtime y Estrés de cgroups  
**Estudiante ID:** 883413  
**Sistema:** eco-air-backend 

---

## 📁 Estructura del Proyecto

```
taller-docker-semana13/
├── Dockerfile                 # Construcción multietapa con seguridad
├── .dockerignore             # Exclusiones para optimizar build
├── pom.xml                   # Configuración Maven + Spring Boot
├── src/
│   └── main/
│       ├── java/com/ecoair/
│       │   └── EcoAirApplication.java
│       └── resources/
│           └── application.properties
├── run_audit.sh              # Script automatizado de auditoría
├── FORENSIC_REPORT.md        # Plantilla de reporte forense
└── README.md                 # Este archivo
```

---

## 🚀 Inicio Rápido

### 1️⃣ Construcción de la Imagen

```bash
docker build --build-arg STUDENT_ID="883413" -t eco-air-backend:1.0.0 .
```

### 2️⃣ Ejecutar Contenedor

```bash
docker run -d --name eco_air_active -p 8080:8080 eco-air-backend:1.0.0
```

### 3️⃣ Verificar Funcionamiento

```bash
# Ver logs
docker logs eco_air_active

# Probar endpoint
curl http://localhost:8080

# Verificar salud
curl http://localhost:8080/health
```

---

## 🔍 Auditoría Automatizada

Para ejecutar todos los retos de forma automatizada:

```bash
chmod +x run_audit.sh
./run_audit.sh | tee audit_session.log
```

Esto generará el archivo `audit_session.log` con todas las evidencias necesarias.

---

## 📋 Retos Implementados

### ✅ Reto 1: Construcción Multietapa con Huella Estricta

**Características:**
- Etapa builder: `maven:3.9.6-eclipse-temurin-17-alpine`
- Optimización de caché con `mvn dependency:go-offline`
- Etapa runtime: `eclipse-temurin:17-jre-alpine`
- Usuario sin privilegios: `sensor_user` (UID 10001)
- Variables JVM ergonómicas configuradas
- ID del estudiante inyectado: `OPERATOR_ID=883413`

### ✅ Reto 2: Auditoría Forense

**Pruebas incluidas:**
1. Verificación de capas (docker history)
2. Inspección de privilegios (docker top)
3. Test de inmutabilidad (intentar escribir en /etc/)
4. Auditoría de artefactos (verificar ausencia de Maven y .java)

### ✅ Reto 3: Calibración de cgroups

**Pruebas incluidas:**
1. Inducción de OOMKilled con 48MB
2. Calibración iterativa: 256MB → 384MB → 512MB
3. Profiling con docker stats

---

## 🛠️ Comandos Útiles

### Gestión de Contenedores

```bash
# Detener contenedor
docker stop eco_air_active

# Eliminar contenedor
docker rm eco_air_active

# Ver estadísticas en tiempo real
docker stats eco_air_active

# Inspeccionar configuración
docker inspect eco_air_active

# Acceder al contenedor
docker exec -it eco_air_active sh
```

### Diagnóstico

```bash
# Ver procesos internos
docker top eco_air_active

# Ver logs con timestamps
docker logs --timestamps eco_air_active

# Ver últimas 50 líneas
docker logs --tail 50 eco_air_active

# Seguir logs en tiempo real
docker logs -f eco_air_active
```

### Limpieza

```bash
# Detener y eliminar todos los contenedores relacionados
docker rm -f eco_air_active eco_air_crash

# Eliminar imagen
docker rmi eco-air-backend:1.0.0

# Limpieza completa de Docker
docker system prune -a
```

---

## 🧪 Endpoints Disponibles

| Endpoint | Descripción | Ejemplo |
|----------|-------------|---------|
| `GET /` | Información del servicio | `curl http://localhost:8080` |
| `GET /health` | Estado de salud | `curl http://localhost:8080/health` |
| `GET /alerts` | Estadísticas de alertas | `curl http://localhost:8080/alerts` |

---

## 🔐 Características de Seguridad Implementadas

1. **Usuario sin privilegios:** El contenedor NO se ejecuta como root
2. **Imagen base minimalista:** Alpine Linux (tamaño reducido)
3. **Construcción multietapa:** Sin herramientas de desarrollo en producción
4. **Variables JVM optimizadas:** Control de memoria container-aware
5. **Sin código fuente:** Solo JAR compilado en imagen final
6. **Inmutabilidad:** Sin permisos de escritura en directorios críticos

---

## 📊 Resultados Esperados

### Tamaño de Imagen
- Etapa builder: ~500-600 MB (con Maven y dependencias)
- Imagen final: ~200-250 MB (solo JRE + JAR)

### Memoria Mínima
- 48 MB: ❌ OOMKilled (insuficiente)
- 256 MB: ⚠️ Puede funcionar pero ajustado
- 384 MB: ✅ Recomendado mínimo
- 512 MB: ✅ Óptimo para producción

### Tiempo de Inicio
- Objetivo: < 15 segundos con memoria adecuada

---

## 📤 Entrega del Taller

### Archivos a Incluir

1. `Dockerfile` ✅
2. `.dockerignore` ✅
3. `pom.xml` ✅
4. `src/` (código fuente) ✅
5. `audit_session.log` (salida del script)
6. `FORENSIC_REPORT.md` (completar con evidencias)

### Formato de Entrega

```bash
# Crear archivo comprimido
tar -czf taller_docker_semana13.zip \
  Dockerfile \
  .dockerignore \
  pom.xml \
  src/ \
  audit_session.log \
  FORENSIC_REPORT.md
```

O simplemente comprimir la carpeta completa desde el explorador.

---

## 🐛 Solución de Problemas

### Error: "Cannot connect to Docker daemon"
```bash
# Verificar que Docker esté corriendo
sudo systemctl start docker
```

### Error: "Port 8080 already in use"
```bash
# Cambiar puerto en el comando run
docker run -d --name eco_air_active -p 8081:8080 eco-air-backend:1.0.0
```

### Error: "OOMKilled even with 512MB"
```bash
# Verificar logs y aumentar memoria
docker logs eco_air_active
docker run -d --name eco_air_active -m 768m -p 8080:8080 eco-air-backend:1.0.0
```

---

## 📚 Referencias

- [Spring Boot Documentation](https://spring.io/projects/spring-boot)
- [Docker Multi-stage Builds](https://docs.docker.com/build/building/multi-stage/)
- [Docker Resource Constraints](https://docs.docker.com/config/containers/resource_constraints/)
- [Java Container Memory](https://developers.redhat.com/articles/2022/04/19/java-17-whats-new-openjdks-container-awareness)

---

## ✉️ Contacto

**Estudiante ID:** 883413  
**Proyecto:** eco-air-backend  
**Fecha:** Octubre 2026

---

**🎯 ¡Buena suerte con el taller!**
