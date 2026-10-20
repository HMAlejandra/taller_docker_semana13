# 📦 RESUMEN DEL PROYECTO - TALLER DOCKER SEMANA 13

## 🎯 INFORMACIÓN GENERAL

| Campo | Valor |
|-------|-------|
| **Estudiante ID** | 883413 |
| **Proyecto** | eco-air-backend |
| **Descripción** | Sistema de Alertas Ambientales Críticas |
| **Tecnologías** | Spring Boot 3.1.5 + Java 17 + Maven + Docker |
| **Puerto** | 8080 |

---

## 📂 ESTRUCTURA DEL PROYECTO

```
taller-docker-semana13/
│
├── 📄 Dockerfile                           # Construcción multietapa (Reto 1)
├── 📄 .dockerignore                        # Exclusiones de build
├── 📄 pom.xml                              # Dependencias Maven
│
├── 📁 src/
│   └── 📁 main/
│       ├── 📁 java/com/ecoair/
│       │   └── EcoAirApplication.java      # Aplicación Spring Boot
│       └── 📁 resources/
│           └── application.properties      # Configuración
│
├── 📄 run_audit.sh                         # Script de auditoría automatizada
├── 📄 FORENSIC_REPORT.md                   # Plantilla de reporte (completar)
├── 📄 README.md                            # Documentación principal
├── 📄 INSTRUCCIONES_PASO_A_PASO.md         # Guía detallada
├── 📄 comandos_rapidos.txt                 # Referencia de comandos
└── 📄 audit_session.log                    # Salida de auditoría (generar)
```

---

## 🐳 DOCKERFILE - ARQUITECTURA MULTIETAPA

### Etapa 1: Builder (Compilación)
```dockerfile
FROM maven:3.9.6-eclipse-temurin-17-alpine
```
- ✅ Imagen base Alpine (ligera)
- ✅ Maven 3.9.6 + JDK 17
- ✅ Caché de dependencias optimizado
- ✅ Build sin tests
- ✅ ARG STUDENT_ID inyectado

### Etapa 2: Runtime (Producción)
```dockerfile
FROM eclipse-temurin:17-jre-alpine
```
- ✅ Solo JRE (sin JDK ni Maven)
- ✅ Usuario sin privilegios: `sensor_user` (UID 10001)
- ✅ Grupo: `sensorgroup`
- ✅ Variables JVM optimizadas
- ✅ ENV OPERATOR_ID=${STUDENT_ID}
- ✅ Solo JAR ejecutable

**Resultado:** Imagen final ~200-250 MB vs ~600 MB si fuera single-stage

---

## 🔐 CARACTERÍSTICAS DE SEGURIDAD

| Característica | Estado | Descripción |
|----------------|--------|-------------|
| **Usuario no root** | ✅ | Proceso corre como `sensor_user` (UID 10001) |
| **Multi-stage build** | ✅ | Sin herramientas de desarrollo en producción |
| **Imagen Alpine** | ✅ | Base minimalista, menos superficie de ataque |
| **Sin código fuente** | ✅ | Solo JAR compilado en imagen final |
| **Sin Maven** | ✅ | Herramientas de build excluidas |
| **Inmutabilidad** | ✅ | Sin permisos de escritura en /etc/ |
| **Variables JVM** | ✅ | Control de memoria container-aware |

---

## 🚀 ENDPOINTS DISPONIBLES

| Método | Ruta | Descripción | Respuesta |
|--------|------|-------------|-----------|
| GET | `/` | Información del servicio | JSON con status y operator_id |
| GET | `/health` | Health check | `{"status":"UP","operator":"883413"}` |
| GET | `/alerts` | Estadísticas de alertas | JSON con contadores de alertas |

### Ejemplo de Respuesta (/)
```json
{
  "service": "EcoAir Backend",
  "status": "OPERATIONAL",
  "operator_id": "883413",
  "timestamp": "2026-10-20T14:30:00",
  "message": "Sistema de alertas ambientales críticas activo"
}
```

---

## 📊 RETOS Y OBJETIVOS

### ✅ RETO 1: Construcción Multietapa con Huella Estricta
**Objetivo:** Crear Dockerfile optimizado y seguro

**Requisitos cumplidos:**
- [x] Etapa builder con maven:3.9.6-eclipse-temurin-17-alpine
- [x] Aislamiento de dependencias (mvn dependency:go-offline)
- [x] ARG STUDENT_ID declarado
- [x] Build sin tests (-DskipTests)
- [x] Etapa runtime con eclipse-temurin:17-jre-alpine
- [x] Usuario sensor_user (UID 10001) + grupo sensorgroup
- [x] Variables JVM ergonómicas
- [x] ENV OPERATOR_ID=${STUDENT_ID}
- [x] USER sensor_user antes de ENTRYPOINT

**Comando de construcción:**
```bash
docker build --build-arg STUDENT_ID="883413" -t eco-air-backend:1.0.0 .
```

---

### ✅ RETO 2: Auditoría Forense y Comprobación de Vulnerabilidades
**Objetivo:** Validar seguridad y aislamiento

#### 2.1 Verificación del Desacoplamiento de Capas
```bash
docker history --human --format "table {{.Size}}\t{{.CreatedBy}}" eco-air-backend:1.0.0
```
**Evidencia:** Capas de builder grandes, runtime ligero

#### 2.2 Inspección de Privilegios
```bash
docker top eco_air_active -o pid,user,comm
```
**Evidencia:** Proceso java ejecutado por sensor_user, NO root

#### 2.3 Test de Inmutabilidad
```bash
docker exec eco_air_active touch /etc/crontab_fake
```
**Evidencia:** Permission denied (correcto)

#### 2.4 Auditoría de Artefactos
```bash
docker exec eco_air_active which mvn
docker exec eco_air_active find / -name "*.java" 2>/dev/null
```
**Evidencia:** Maven y archivos .java ausentes (correcto)

---

### ✅ RETO 3: Calibración de cgroups y Captura del Asesino OOM
**Objetivo:** Encontrar límite mínimo de memoria operativa

#### 3.1 Inducción de OOMKilled (48MB)
```bash
docker run -d --name eco_air_crash -m 48m eco-air-backend:1.0.0
```
**Resultado esperado:** OOMKilled=true, ExitCode=137

#### 3.2 Calibración Iterativa
| Memoria | Estado Esperado | Tiempo Inicio | Observaciones |
|---------|----------------|---------------|---------------|
| 48 MB | ❌ OOMKilled | N/A | Insuficiente para JVM + Spring |
| 256 MB | ⚠️ Límite | 15-30s | Puede funcionar pero ajustado |
| 384 MB | ✅ Estable | 10-15s | Mínimo recomendado |
| 512 MB | ✅ Óptimo | 8-12s | Recomendado para producción |

**Comando de verificación:**
```bash
docker stats --no-stream eco_air_active
```

---

## 🔬 TECNOLOGÍAS Y DEPENDENCIAS

### Maven Dependencies (pom.xml)
```xml
- spring-boot-starter-web       # REST API
- spring-boot-starter-data-jpa  # Persistencia (Hibernate)
- h2                            # Base de datos en memoria
- spring-boot-starter-actuator  # Monitoreo y health checks
```

### Versiones
- **Spring Boot:** 3.1.5
- **Java:** 17 (LTS)
- **Maven:** 3.9.6
- **Base OS:** Alpine Linux

---

## 📈 MÉTRICAS ESPERADAS

### Tamaños de Imagen
```
ETAPA              TAMAÑO
Builder            ~550-600 MB
Runtime Final      ~200-250 MB
Reducción          ~60% más ligera
```

### Tiempos de Construcción
```
Primera build:     3-5 minutos (descarga de dependencias)
Builds posteriores: 30-60 segundos (con caché)
```

### Uso de Recursos (512MB)
```
CPU:               5-15% (idle)
Memoria:           180-250 MB (de 512 MB límite)
Tiempo inicio:     8-12 segundos
```

---

## 🎓 CONCEPTOS CLAVE DEL TALLER

### 1. Multi-Stage Builds
Separa build de runtime para imágenes más ligeras y seguras.

### 2. Principio de Mínimo Privilegio
Usuario sin privilegios reduce superficie de ataque.

### 3. Container-Aware JVM
Variables como `-XX:+UseContainerSupport` permiten que Java respete límites de cgroups.

### 4. OOM Killer
Kernel termina procesos que exceden límites de memoria (exit code 137).

### 5. cgroups (Control Groups)
Mecanismo del kernel Linux para limitar recursos (CPU, memoria, I/O).

---

## ✅ CRITERIOS DE EVALUACIÓN

### Construcción (Reto 1)
- [ ] Dockerfile multietapa funcional
- [ ] Usuario sin privilegios configurado
- [ ] Variable STUDENT_ID inyectada correctamente
- [ ] Imagen construida exitosamente

### Auditoría (Reto 2)
- [ ] Comandos forenses ejecutados
- [ ] Evidencias capturadas correctamente
- [ ] Análisis de seguridad documentado
- [ ] Ausencia de artefactos de desarrollo verificada

### Calibración (Reto 3)
- [ ] OOMKilled con 48MB demostrado
- [ ] Umbral mínimo identificado
- [ ] Docker stats documentado
- [ ] Análisis de memoria completado

### Documentación
- [ ] FORENSIC_REPORT.md completado
- [ ] audit_session.log generado
- [ ] Evidencias claras y legibles
- [ ] Conclusiones fundamentadas

---

## 🎯 COMANDOS ESENCIALES

```bash
# Construir
docker build --build-arg STUDENT_ID="883413" -t eco-air-backend:1.0.0 .

# Ejecutar
docker run -d --name eco_air_active -p 8080:8080 eco-air-backend:1.0.0

# Probar
curl http://localhost:8080

# Auditar (automático)
./run_audit.sh | tee audit_session.log

# Empaquetar
tar -czf taller_docker_semana13.tar.gz Dockerfile .dockerignore pom.xml src/ audit_session.log FORENSIC_REPORT.md
```

---

## 📝 NOTAS IMPORTANTES

1. **ID del Estudiante:** El ID `883413` está hard-coded en varios archivos. Si necesitas cambiarlo, busca y reemplaza en:
   - Dockerfile (línea ENV OPERATOR_ID)
   - run_audit.sh (línea docker build)
   - Todos los archivos .md

2. **Puerto 8080:** Si está ocupado, cambia `-p 8081:8080` en los comandos

3. **WSL2:** Asegúrate de que Docker Desktop esté corriendo en Windows

4. **Permisos:** En Linux, puede requerir `sudo` o agregar tu usuario al grupo docker:
   ```bash
   sudo usermod -aG docker $USER
   ```

5. **Memoria:** Los valores de calibración pueden variar ligeramente según tu sistema

---

## 🏆 CHECKLIST FINAL DE ENTREGA

Antes de entregar, verifica:

- [ ] ✅ Todos los archivos presentes en el directorio
- [ ] ✅ Dockerfile funcional y optimizado
- [ ] ✅ Imagen construida con ID 883413
- [ ] ✅ Todos los retos ejecutados
- [ ] ✅ FORENSIC_REPORT.md completado con evidencias
- [ ] ✅ audit_session.log generado
- [ ] ✅ Archivo comprimido .tar.gz o .zip creado
- [ ] ✅ Endpoints probados y funcionando
- [ ] ✅ OOMKilled demostrado
- [ ] ✅ Umbral mínimo documentado

---

## 📧 INFORMACIÓN DE CONTACTO

**Estudiante ID:** 883413  
**Proyecto:** eco-air-backend  
**Taller:** Docker Semana 13 - Contenerización y Seguridad  
**Fecha:** Octubre 2026

---

**Estado del Proyecto:** ✅ LISTO PARA EJECUTAR Y ENTREGAR

¡Todo está configurado! Solo falta ejecutar los comandos y completar el FORENSIC_REPORT.md con las evidencias.

---

## 🚀 PRÓXIMOS PASOS

1. Ejecutar `./run_audit.sh | tee audit_session.log`
2. Completar FORENSIC_REPORT.md con resultados
3. Crear archivo comprimido
4. ¡Entregar!

**Tiempo estimado total:** 30-45 minutos
