# 🚀 EMPEZAR AQUÍ - Taller Docker Semana 13

**¡Bienvenido!** Este es tu punto de partida para completar el taller.

---

## 👤 TU INFORMACIÓN

- **ID de Estudiante:** 883413
- **Proyecto:** eco-air-backend
- **Objetivo:** Contenerización, Seguridad y Calibración de cgroups

---

## ⚡ INICIO RÁPIDO (5 MINUTOS)

### Si estás en Linux/macOS/WSL2:

```bash
# 1. Dar permisos a los scripts
chmod +x run_audit.sh VERIFICACION_RAPIDA.sh

# 2. Ejecutar auditoría completa (esto hace TODO)
./run_audit.sh | tee audit_session.log

# 3. Verificar que todo funcionó
./VERIFICACION_RAPIDA.sh

# 4. Probar la aplicación
curl http://localhost:8080

# 5. Completar el reporte forense
# Abre FORENSIC_REPORT.md y copia las evidencias de audit_session.log

# 6. Crear archivo de entrega
tar -czf taller_docker_semana13.tar.gz \
  Dockerfile .dockerignore pom.xml src/ \
  audit_session.log FORENSIC_REPORT.md README.md
```

### Si estás en Windows (sin WSL):

Necesitas **WSL2 (Windows Subsystem for Linux)** para ejecutar Docker correctamente.

**Instalar WSL2:**
```powershell
# En PowerShell como Administrador
wsl --install
```

Luego reinicia y trabaja desde WSL2 con los comandos de arriba.

---

## 📁 ¿QUÉ HAY EN ESTE PROYECTO?

```
taller-docker-semana13/
│
├── 📘 EMPEZAR_AQUI.md              ← ESTÁS AQUÍ
├── 📘 README.md                    ← Documentación principal
├── 📘 RESUMEN_PROYECTO.md          ← Vista global completa
├── 📘 INSTRUCCIONES_PASO_A_PASO.md ← Guía detallada manual
├── 📘 INDICE_DOCUMENTACION.md      ← Guía de todos los archivos
│
├── 🤖 run_audit.sh                 ← Script de auditoría automática
├── 🤖 VERIFICACION_RAPIDA.sh       ← Script de verificación
├── 📄 comandos_rapidos.txt         ← Cheatsheet de comandos
│
├── 🐳 Dockerfile                   ← Construcción multietapa
├── 🐳 .dockerignore               ← Exclusiones de build
├── ⚙️  pom.xml                     ← Dependencias Maven
│
├── 📝 FORENSIC_REPORT.md           ← COMPLETAR CON EVIDENCIAS
├── 📊 audit_session.log            ← Se genera automáticamente
│
└── 📂 src/                         ← Código Spring Boot
    └── main/
        ├── java/com/ecoair/
        │   └── EcoAirApplication.java
        └── resources/
            └── application.properties
```

---

## 🎯 TU MISIÓN

### RETO 1: Construcción Multietapa ✅
**Ya está hecho** - Dockerfile configurado con:
- Usuario sin privilegios: `sensor_user`
- ID de estudiante: `883413`
- Optimización de caché
- Imagen ligera y segura

### RETO 2: Auditoría Forense 🔍
**Ejecutar** comandos y **documentar** evidencias:
- Verificar capas de Docker
- Confirmar usuario sin privilegios
- Test de inmutabilidad
- Auditar ausencia de herramientas de desarrollo

### RETO 3: Calibración de cgroups 💥
**Probar** límites de memoria:
- Inducir OOMKilled con 48MB
- Encontrar umbral mínimo operativo
- Documentar consumo real

---

## 📖 ¿QUÉ ARCHIVO LEER?

### Escenario 1: "Quiero hacerlo rápido"
```
1. Este archivo (ya estás aquí) ✅
2. Ejecuta: ./run_audit.sh | tee audit_session.log
3. Completa FORENSIC_REPORT.md
4. ¡Listo para entregar!
```

### Escenario 2: "Quiero entender cada paso"
```
1. Este archivo ✅
2. README.md (visión general)
3. INSTRUCCIONES_PASO_A_PASO.md (guía detallada)
4. Ejecuta comando por comando
5. Completa FORENSIC_REPORT.md
```

### Escenario 3: "Necesito referencia rápida"
```
1. comandos_rapidos.txt (todos los comandos)
2. RESUMEN_PROYECTO.md (objetivos y métricas)
```

---

## ✅ CHECKLIST DE 3 PASOS

### PASO 1: EJECUTAR ⚡
```bash
# Opción A: Automático (recomendado)
./run_audit.sh | tee audit_session.log

# Opción B: Manual
# Sigue INSTRUCCIONES_PASO_A_PASO.md
```

### PASO 2: DOCUMENTAR 📝
```
Abre FORENSIC_REPORT.md
Reemplaza todos los [PENDIENTE] con:
- Salidas de comandos (de audit_session.log)
- Hashes y verificaciones
- Tablas de docker stats
- Conclusiones
```

### PASO 3: ENTREGAR 📦
```bash
# Verificar que todo está bien
./VERIFICACION_RAPIDA.sh

# Crear archivo de entrega
tar -czf taller_docker_semana13.tar.gz \
  Dockerfile .dockerignore pom.xml src/ \
  audit_session.log FORENSIC_REPORT.md README.md

# O en Windows (desde WSL o usando 7-Zip):
zip -r taller_docker_semana13.zip \
  Dockerfile .dockerignore pom.xml src/ \
  audit_session.log FORENSIC_REPORT.md README.md
```

---

## 🚨 ANTES DE EMPEZAR - REQUISITOS

### ✅ Verifica que tienes:

```bash
# Docker instalado
docker --version
# Debe mostrar: Docker version 20.x.x o superior

# Docker corriendo
docker ps
# Debe mostrar tabla de contenedores (puede estar vacía)

# Acceso a bash/shell (Linux/macOS/WSL2)
bash --version
# Debe mostrar: GNU bash, version 4.x o superior
```

### ❌ Si algo falla:

**Docker no instalado:**
- Linux: `sudo apt install docker.io` o visita https://docs.docker.com/engine/install/
- macOS: Instala Docker Desktop
- Windows: Instala Docker Desktop + WSL2

**Docker daemon no corre:**
- Linux: `sudo systemctl start docker`
- macOS/Windows: Abre Docker Desktop

---

## 🎬 COMANDOS ESENCIALES

### Construcción
```bash
docker build --build-arg STUDENT_ID="883413" -t eco-air-backend:1.0.0 .
```

### Ejecución Normal
```bash
docker run -d --name eco_air_active -p 8080:8080 eco-air-backend:1.0.0
```

### Verificación
```bash
# Ver logs
docker logs eco_air_active

# Probar endpoint
curl http://localhost:8080

# Ver estadísticas
docker stats --no-stream eco_air_active
```

### Limpieza
```bash
# Detener y eliminar
docker rm -f eco_air_active eco_air_crash

# Eliminar imagen
docker rmi eco-air-backend:1.0.0
```

---

## 🎯 RESULTADOS ESPERADOS

### ✅ Si todo funciona bien:

1. **Imagen construida:** ~200-250 MB
2. **Contenedor inicia en:** 8-15 segundos (con 512MB RAM)
3. **Endpoint responde:**
   ```json
   {
     "service": "EcoAir Backend",
     "status": "OPERATIONAL",
     "operator_id": "883413"
   }
   ```
4. **Usuario sin privilegios:** `sensor_user` (UID 10001)
5. **OOMKilled con 48MB:** ✅ Confirmado
6. **Umbral mínimo:** ~384-512 MB

---

## 🆘 AYUDA RÁPIDA

### Problema: "Port 8080 already in use"
```bash
# Usar otro puerto
docker run -d --name eco_air_active -p 8081:8080 eco-air-backend:1.0.0
# Luego accede a http://localhost:8081
```

### Problema: "Cannot connect to Docker daemon"
```bash
# Linux
sudo systemctl start docker

# Verificar status
systemctl status docker
```

### Problema: Contenedor no inicia
```bash
# Ver logs completos
docker logs eco_air_active

# Ver últimas 50 líneas
docker logs --tail 50 eco_air_active

# Verificar memoria asignada
docker inspect eco_air_active | grep -i memory
```

### Problema: Endpoint no responde
```bash
# Esperar 15 segundos más (Spring Boot tarda en iniciar)
sleep 15

# Verificar que el contenedor está corriendo
docker ps | grep eco_air_active

# Ver si llegó a iniciarse
docker logs eco_air_active | grep "Started EcoAirApplication"
```

---

## 📊 TABLA DE TIEMPOS

| Tarea | Tiempo Estimado |
|-------|----------------|
| Lectura inicial (este archivo) | 5 min |
| Ejecución automática (run_audit.sh) | 5-10 min |
| Completar FORENSIC_REPORT.md | 10-15 min |
| Verificación y empaquetado | 5 min |
| **TOTAL (automático)** | **25-35 min** |
| **TOTAL (manual)** | **45-60 min** |

---

## 🎓 CRITERIOS DE EVALUACIÓN

| Criterio | Puntos | Cómo verificarlo |
|----------|--------|------------------|
| Dockerfile multietapa | 25% | Verificar construcción exitosa |
| Usuario sin privilegios | 15% | `docker top` muestra sensor_user |
| Variable OPERATOR_ID | 10% | Presente en respuesta del endpoint |
| Evidencias de auditoría | 25% | FORENSIC_REPORT.md completado |
| OOMKilled demostrado | 10% | Exit code 137 documentado |
| Umbral mínimo | 10% | Valor correcto con justificación |
| Documentación | 5% | Claridad y completitud |

**Total:** 100%

---

## 📦 ARCHIVOS DE ENTREGA

### ✅ OBLIGATORIOS (debes incluir):
- `Dockerfile`
- `.dockerignore`
- `pom.xml`
- `src/` (carpeta completa)
- `audit_session.log`
- `FORENSIC_REPORT.md` (completado)

### ⭐ OPCIONALES (recomendados):
- `README.md`

### ❌ NO INCLUIR:
- `target/` (generado por Maven)
- `.vscode/`
- Archivos `.md` de instrucciones
- Scripts `.sh`

---

## 🎉 SIGUIENTE PASO

**¡Estás listo para empezar!**

### Opción Recomendada (Rápida):
```bash
chmod +x run_audit.sh
./run_audit.sh | tee audit_session.log
```

### Opción Educativa (Paso a paso):
```bash
# Abre y sigue:
cat INSTRUCCIONES_PASO_A_PASO.md
```

---

## 📞 INFORMACIÓN DEL ESTUDIANTE

- **ID:** 883413
- **Proyecto:** eco-air-backend  
- **Taller:** Docker Semana 13
- **Sistema:** Linux / macOS / WSL2

---

**🚀 ¡Buena suerte! Todo está configurado y listo para ejecutar.**

**⏱️ Tiempo total estimado:** 30-45 minutos

**🎯 Próxima acción:** Ejecutar `./run_audit.sh | tee audit_session.log`

---

**Estado del proyecto:** ✅ COMPLETO Y LISTO PARA EJECUTAR

¿Dudas? Consulta **INDICE_DOCUMENTACION.md** para guía de archivos.
