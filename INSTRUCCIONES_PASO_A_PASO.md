# 📝 INSTRUCCIONES PASO A PASO - TALLER DOCKER SEMANA 13

**Estudiante ID:** 883413  
**Proyecto:** eco-air-backend

---

## ⚡ OPCIÓN RÁPIDA (Recomendada)

Si quieres ejecutar todo automáticamente:

```bash
# 1. Dar permisos al script
chmod +x run_audit.sh

# 2. Ejecutar auditoría completa
./run_audit.sh | tee audit_session.log

# 3. Probar el endpoint
curl http://localhost:8080

# 4. Completar FORENSIC_REPORT.md con los resultados
# 5. Crear archivo de entrega
tar -czf taller_docker_semana13.tar.gz Dockerfile .dockerignore pom.xml src/ audit_session.log FORENSIC_REPORT.md README.md
```

---

## 🔧 OPCIÓN MANUAL (Paso a Paso)

### PASO 1: Verificar Requisitos Previos

```bash
# Verificar que Docker está instalado y corriendo
docker --version

# Verificar que Docker daemon está activo
docker ps

# Verificar que tienes todos los archivos
ls -la
```

**Archivos que debes tener:**
- ✅ Dockerfile
- ✅ .dockerignore
- ✅ pom.xml
- ✅ src/main/java/com/ecoair/EcoAirApplication.java
- ✅ src/main/resources/application.properties

---

### PASO 2: Construir la Imagen (Reto 1)

```bash
# Construir con tu ID de estudiante
docker build --build-arg STUDENT_ID="883413" -t eco-air-backend:1.0.0 .
```

**⏱️ Tiempo estimado:** 3-5 minutos (primera vez, descarga de dependencias)

**✅ Verificación exitosa:**
```
Successfully built [hash]
Successfully tagged eco-air-backend:1.0.0
```

**Verificar que la imagen existe:**
```bash
docker images eco-air-backend:1.0.0
```

---

### PASO 3: Ejecutar Reto 2.1 - Verificación de Capas

```bash
# Ver historial de capas
docker history --human --format "table {{.Size}}\t{{.CreatedBy}}" eco-air-backend:1.0.0
```

**📋 Anotar:** Copiar la salida completa a FORENSIC_REPORT.md

---

### PASO 4: Obtener Hash de la Imagen (Identidad)

```bash
# Obtener hash SHA-256
docker inspect --format='{{.Id}}' eco-air-backend:1.0.0
```

**📋 Anotar:** Copiar el hash a FORENSIC_REPORT.md, sección "Tabla de Identidad"

---

### PASO 5: Ejecutar Reto 2.2 - Inspección de Privilegios

```bash
# Iniciar contenedor
docker run -d --name eco_air_active -p 8080:8080 eco-air-backend:1.0.0

# Esperar que inicie (10-15 segundos)
sleep 15

# Verificar que está corriendo
docker ps | grep eco_air_active

# Ver procesos y usuario
docker top eco_air_active -o pid,user,comm
```

**✅ Resultado esperado:** El proceso `java` debe mostrar usuario `sensor_user`, NO `root`

**📋 Anotar:** Copiar salida de `docker top` a FORENSIC_REPORT.md

```bash
# Verificar logs de inicio
docker logs eco_air_active | head -20

# Verificar variable OPERATOR_ID
docker exec eco_air_active env | grep OPERATOR_ID
```

**✅ Resultado esperado:** `OPERATOR_ID=883413`

**📋 Anotar:** Copiar a FORENSIC_REPORT.md

---

### PASO 6: Probar el Endpoint

```bash
# Probar endpoint principal
curl http://localhost:8080

# Probar health check
curl http://localhost:8080/health

# Probar alertas
curl http://localhost:8080/alerts
```

**✅ Resultado esperado:** JSON con `"status": "OPERATIONAL"` y `"operator_id": "883413"`

---

### PASO 7: Ejecutar Reto 2.3 - Test de Inmutabilidad

```bash
# Intentar escribir en /etc/ (debe fallar)
docker exec eco_air_active touch /etc/crontab_fake
```

**✅ Resultado esperado:** Error de permiso denegado

```
touch: /etc/crontab_fake: Permission denied
```

**📋 Anotar:** Copiar error a FORENSIC_REPORT.md y explicar por qué es correcto

---

### PASO 8: Ejecutar Reto 2.4 - Auditoría de Artefactos

```bash
# Verificar que Maven NO está presente
docker exec eco_air_active which mvn
```

**✅ Resultado esperado:** Error o vacío (Maven no debe estar)

```bash
# Buscar archivos .java (no deben existir, excepto del JRE)
docker exec eco_air_active find / -name "*.java" 2>/dev/null
```

**✅ Resultado esperado:** Vacío o solo archivos del JRE interno

**📋 Anotar:** Ambas salidas y explicación en FORENSIC_REPORT.md

---

### PASO 9: Ejecutar Reto 3.1 - Inducir OOMKilled

```bash
# Crear contenedor con solo 48MB de RAM
docker run -d --name eco_air_crash -m 48m eco-air-backend:1.0.0

# Esperar 15 segundos
sleep 15

# Verificar que fue terminado por OOM
docker inspect eco_air_crash --format='Status: {{.State.Status}} | ExitCode: {{.State.ExitCode}} | OOMKilled: {{.State.OOMKilled}}'
```

**✅ Resultado esperado:**
```
Status: exited | ExitCode: 137 | OOMKilled: true
```

**📋 Anotar:** Copiar salida completa a FORENSIC_REPORT.md

```bash
# Ver logs del crash (opcional)
docker logs eco_air_crash
```

---

### PASO 10: Ejecutar Reto 3.2 - Calibración de Memoria

#### Prueba con 256MB

```bash
# Limpiar contenedor anterior
docker rm -f eco_air_active

# Crear con 256MB
docker run -d --name eco_air_active -m 256m -p 8080:8080 eco-air-backend:1.0.0

# Esperar inicio
sleep 20

# Verificar estado
docker inspect eco_air_active --format='Status: {{.State.Status}} | OOMKilled: {{.State.OOMKilled}}'

# Buscar línea de inicio exitoso
docker logs --timestamps eco_air_active | grep "Started EcoAirApplication"

# Ver estadísticas
docker stats --no-stream eco_air_active
```

**📋 Anotar:** Si inició correctamente, copiar salida de `docker stats` a FORENSIC_REPORT.md

---

#### Prueba con 384MB

```bash
# Repetir proceso con 384MB
docker rm -f eco_air_active
docker run -d --name eco_air_active -m 384m -p 8080:8080 eco-air-backend:1.0.0
sleep 20
docker logs --timestamps eco_air_active | grep "Started EcoAirApplication"
docker stats --no-stream eco_air_active
```

**📋 Anotar:** Resultados en FORENSIC_REPORT.md

---

#### Prueba con 512MB

```bash
# Repetir proceso con 512MB
docker rm -f eco_air_active
docker run -d --name eco_air_active -m 512m -p 8080:8080 eco-air-backend:1.0.0
sleep 20
docker logs --timestamps eco_air_active | grep "Started EcoAirApplication"
docker stats --no-stream eco_air_active
```

**📋 Anotar:** Resultados en FORENSIC_REPORT.md

---

### PASO 11: Determinar Umbral Mínimo

Según tus pruebas, determina:
- **¿Con cuánta memoria inició exitosamente por primera vez?**
- **¿Cuánto tiempo tardó en iniciar?** (debe ser < 15 segundos)
- **¿Cuál es el uso real de memoria?** (MEM USAGE en docker stats)

**📋 Anotar:** Conclusiones en FORENSIC_REPORT.md, sección "Umbral Mínimo Operativo"

---

### PASO 12: Completar FORENSIC_REPORT.md

Abre el archivo `FORENSIC_REPORT.md` y completa:

1. ✅ Hash de la imagen (Paso 4)
2. ✅ Variable OPERATOR_ID (Paso 5)
3. ✅ Salida de docker history (Paso 3)
4. ✅ Salida de docker top (Paso 5)
5. ✅ Error de inmutabilidad (Paso 7)
6. ✅ Auditoría de artefactos (Paso 8)
7. ✅ Resultado OOMKilled (Paso 9)
8. ✅ Tablas de docker stats para cada memoria (Paso 10)
9. ✅ Umbral mínimo encontrado (Paso 11)
10. ✅ Conclusiones

---

### PASO 13: Crear Archivo de Entrega

```bash
# Opción 1: tar.gz (recomendado para Linux)
tar -czf taller_docker_semana13.tar.gz \
  Dockerfile \
  .dockerignore \
  pom.xml \
  src/ \
  audit_session.log \
  FORENSIC_REPORT.md \
  README.md

# Opción 2: zip (recomendado para Windows)
zip -r taller_docker_semana13.zip \
  Dockerfile \
  .dockerignore \
  pom.xml \
  src/ \
  audit_session.log \
  FORENSIC_REPORT.md \
  README.md

# Verificar que se creó el archivo
ls -lh taller_docker_semana13.*
```

---

### PASO 14: Verificación Final

```bash
# Checklist de verificación
echo "=== VERIFICACIÓN FINAL ==="

# 1. Imagen existe
docker images eco-air-backend:1.0.0

# 2. Contenedor corriendo
docker ps | grep eco_air_active

# 3. Endpoint responde
curl -s http://localhost:8080/health

# 4. Archivos completos
ls -l Dockerfile .dockerignore pom.xml FORENSIC_REPORT.md audit_session.log
ls -R src/
```

---

### PASO 15: Limpieza (Opcional)

Si quieres limpiar todo después de entregar:

```bash
# Detener y eliminar contenedores
docker rm -f eco_air_active eco_air_crash

# Eliminar imagen
docker rmi eco-air-backend:1.0.0

# Limpieza general de Docker
docker system prune -a
```

---

## 🎯 CHECKLIST FINAL DE ENTREGA

Antes de entregar, verifica que tienes:

- [ ] ✅ `Dockerfile` con construcción multietapa
- [ ] ✅ `.dockerignore` configurado
- [ ] ✅ `pom.xml` con dependencias correctas
- [ ] ✅ `src/` con código Java funcional
- [ ] ✅ `audit_session.log` con salida de comandos
- [ ] ✅ `FORENSIC_REPORT.md` completamente lleno
- [ ] ✅ `taller_docker_semana13.tar.gz` o `.zip`
- [ ] ✅ Imagen construida con ID: 883413
- [ ] ✅ Todos los comandos ejecutados y documentados
- [ ] ✅ OOMKilled demostrado con 48MB
- [ ] ✅ Umbral mínimo identificado
- [ ] ✅ Usuario sin privilegios verificado

---

## ❓ SOLUCIÓN DE PROBLEMAS COMUNES

### Error: "Cannot connect to Docker daemon"
```bash
# Linux
sudo systemctl start docker

# WSL2
# Asegúrate de que Docker Desktop esté corriendo en Windows
```

### Error: "Port 8080 already in use"
```bash
# Ver qué está usando el puerto
netstat -tuln | grep 8080

# Usar otro puerto
docker run -d --name eco_air_active -p 8081:8080 eco-air-backend:1.0.0
```

### Error: "The command 'mvn' returned a non-zero code: 1"
```bash
# Verificar pom.xml
cat pom.xml

# Reconstruir desde cero
docker build --no-cache --build-arg STUDENT_ID="883413" -t eco-air-backend:1.0.0 .
```

### Contenedor arranca pero no responde
```bash
# Ver logs detallados
docker logs eco_air_active

# Verificar que el puerto está expuesto
docker port eco_air_active

# Probar desde dentro del contenedor
docker exec eco_air_active wget -O- http://localhost:8080
```

### "Started EcoAirApplication" no aparece en los logs
```bash
# Esperar más tiempo (puede tardar hasta 30 segundos con poca RAM)
sleep 30
docker logs eco_air_active

# Ver todos los logs
docker logs eco_air_active 2>&1 | less
```

---

## 📚 RECURSOS ÚTILES

- Documentación oficial de Docker: https://docs.docker.com/
- Spring Boot con Docker: https://spring.io/guides/gs/spring-boot-docker/
- Docker Resource Constraints: https://docs.docker.com/config/containers/resource_constraints/

---

## ✉️ INFORMACIÓN DEL ESTUDIANTE

**ID:** 883413  
**Proyecto:** eco-air-backend  
**Sistema Operativo:** Linux / macOS / WSL2  
**Fecha:** Octubre 2026

---

**¡Buena suerte con el taller! 🚀**
