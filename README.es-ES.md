

# 📐 Math OCR Tool | Herramienta de conversión de imágenes de fórmulas matemáticas a LaTeX

<div align="center">

[![GHCR](https://img.shields.io/badge/GHCR-ghcr.io%2Fzhizinan1997%2Fmath--ocr--tool-blue)](https://github.com/zhizinan1997/math-ocr-tool/pkgs/container/math-ocr-tool)
[![GitHub Stars](https://img.shields.io/github/stars/zhizinan1997/math-ocr-tool.svg)](https://github.com/zhizinan1997/math-ocr-tool/stargazers)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Herramienta de reconocimiento de fórmulas matemáticas impulsada por IA y generación de código LaTeX**

[Inicio rápido](#-inicio-rápido) • [Guía de despliegue](#-guía-de-despliegue) • [Configuración](#️-configuración) • [Guía de uso](#-guía-de-uso) • [English](#english)

</div>

---

## ✨ Características

| Característica | Descripción |
|------|------|
| 🤖 **Reconocimiento inteligente con IA** | Basado en modelos avanzados de IA, identifica con precisión fórmulas matemáticas escritas a mano e impresas |
| 📸 **Múltiples métodos de carga** | Arrastrar y soltar, seleccionar haciendo clic, pegar capturas de pantalla (Ctrl+V) |
| 🎯 **Alta precisión de reconocimiento** | Admite fórmulas complejas: fracciones, integrales, matrices, sumatoriasetc. |
| 🔍 **Vista previa en tiempo real** | Renderizado de vista previa de fórmulas LaTeX en tiempo real con MathJax |
| 📋 **Copia con un clic** | Copiar rápidamente el código LaTeX generado al portapapeles |
| 🔐 **Autenticación de usuario** | Verificación de doble tabla (auth + user), admiene la gestión del estado de activación de cuentas |
| 👤 **Gestión de roles** | Admite tres estados de rol: admin, user, pending |
| 📝 **Historial** | Guarda automáticamente las imágenes subidas por el usuario y los resultados del reconocimiento de IA para facilitar la gestión |
| 🐳 **Despliegue con Docker** | Script de un solo clic para despliegue rápido en cualquier servidor |

---

## 🚀 Inicio rápido

### Método 1: Script de despliegue con un clic (recomendado)

**Linux / macOS:**
```bash
curl -fsSL https://raw.githubusercontent.com/zhizinan1997/math-ocr-tool/main/quick_deploy.sh -o quick_deploy.sh && chmod +x quick_deploy.sh && ./quick_deploy.sh
```

**Windows (PowerShell):**
```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/zhizinan1997/math-ocr-tool/main/quick_deploy.bat" -OutFile "quick_deploy.bat"; .\quick_deploy.bat
```

El script lo guiará a través de:
1. Clonar el proyecto desde GitHub
2. Configurar la información de conexión a la base de datos
3. Configurar la clave API de IA
4. Construir automáticamente la imagen de Docker
5. Desplegar e iniciar el servicio

### Método 2: Comando de Docker

```bash
docker run -d \
    --name math-ocr-tool \
    -p 5000:5000 \
    -e DB_HOST="host-de-la-base-de-datos" \
    -e DB_PORT="5432" \
    -e DB_NAME="postgres" \
    -e DB_USER="postgres" \
    -e DB_PASSWORD="contraseña-de-la-base-de-datos" \
    -e OPENAI_API_KEY="tu-clave-api" \
    -e OPENAI_API_BASE="https://api.openai.com/v1" \
    -e OPENAI_MODEL="gpt-4o" \
    --restart unless-stopped \
    ghcr.io/zhizinan1997/math-ocr-tool:latest
```

### Método 3: Docker Compose

1. Cree `docker-compose.yml`：

```yaml
version: '3.8'

services:
  math-ocr-tool:
    image: ghcr.io/zhizinan1997/math-ocr-tool:latest
    container_name: math-ocr-tool
    ports:
      - "5000:5000"
    environment:
      - DB_HOST=${DB_HOST}
      - DB_PORT=${DB_PORT:-5432}
      - DB_NAME=${DB_NAME:-postgres}
      - DB_USER=${DB_USER:-postgres}
      - DB_PASSWORD=${DB_PASSWORD}
      - OPENAI_API_KEY=${OPENAI_API_KEY}
      - OPENAI_API_BASE=${OPENAI_API_BASE:-https://api.openai.com/v1}
      - OPENAI_MODEL=${OPENAI_MODEL:-gpt-4o}
    restart: unless-stopped
```

2. Cree el archivo `.env`：

```env
DB_HOST=tu-host-de-base-de-datos
DB_PASSWORD=tu-contraseña-de-base-de-datos
OPENAI_API_KEY=tu-clave-api
OPENAI_API_BASE=https://api.openai.com/v1
OPENAI_MODEL=gpt-4o
```

3. Inicie：

```bash
docker-compose up -d
```

---

## 📖 Guía de despliegue

### Requisitos previos

- Docker 20.0+
- PostgreSQL 12+ (para la autenticación de usuarios)
- API de IA compatible con reconocimiento de imágenes (OpenAI GPT-4o o interfaz compatible)

### Preparación de la base de datos

Esta herramienta utiliza dos tablas de datos para la autenticación de usuarios y la gestión de permisos：

#### 1. Tabla `auth` - Almacena las credenciales de inicio de sesión

```sql
CREATE TABLE auth (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Crear usuario (se recomienda usar hash bcrypt para la contraseña)
INSERT INTO auth (email, password) VALUES ('admin@example.com', 'tu-contraseña-con-hash');
```

#### 2. Tabla `user` - Almacena los roles de usuario y el estado de activación

```sql
CREATE TABLE "user" (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    role VARCHAR(50) NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Establecer rol de usuario
-- Valores válidos para role: 'admin', 'user', 'pending'
-- 'pending' = Pendiente (no puede iniciar sesión)
-- 'user' = Usuario normal (puede iniciar sesión)
-- 'admin' = Administrador (puede iniciar sesión)
INSERT INTO "user" (email, role) VALUES ('admin@example.com', 'admin');
```

### Flujo de autenticación de usuarios

La verificación de inicio de sesión se realiza en el siguiente orden：

1. ❌ El correo no existe en la tabla `auth` → "Usuario no existe"
2. ❌ Contraseña incorrecta → "Contraseña incorrecta"
3. ❌ El correo no existe en la tabla `user` → "Información de usuario incompleta, por favor contacte al administrador"
4. ❌ En la tabla `user`, role = "pending" → "Cuenta no activada, espere la revisión del administrador"
5. ✅ role = "admin" o "user" → Inicio de sesión exitoso

### Gestión de usuarios

Los administradores pueden gestionar los permisos de usuario modificando la columna `role` en la tabla `user`：

```sql
-- Activar usuario
UPDATE "user" SET role = 'user' WHERE email = 'nuevo@ejemplo.com';

-- Deshabilitar usuario (establecer como pendiente, cerrará la sesión de cualquier usuario ya conectado)
UPDATE "user" SET role = 'pending' WHERE email = 'bloqueejemplo.com';

-- Eliminar usuario (se elimina de ambas tablas, cerrará la sesión de cualquier usuario ya conectado)
DELETE FROM auth WHERE email = 'eliminado@ejemplo.com';
DELETE FROM "user" WHERE email = 'eliminado@ejemplo.com';
```

> ⚠️ **Nota**: Cuando un usuario es eliminado o se establece en estado pending, será desconectado inmediatamente la próxima vez que intente acceder a cualquier página.

### Construcción desde el código fuente

```bash
# Clonar repositorio
git clone https://github.com/zhizinan1997/math-ocr-tool.git
cd math-ocr-tool

# Construir imagen
docker build -t math-ocr-tool:latest .

# Ejecutar contenedor
docker run -d --name math-ocr-tool -p 5000:5000 \
    -e DB_HOST="..." \
    -e DB_PASSWORD="..." \
    -e OPENAI_API_KEY="..." \
    math-ocr-tool:latest
```

---

## ⚙️ Configuración

### Variables de entorno obligatorias

| Nombre de variable | Descripción | Ejemplo |
|--------|------|------|
| `DB_HOST` | Host de la base de datos PostgreSQL | `localhost` |
| `DB_PASSWORD` | Contraseña de la base de datos | `tu-contraseña` |
| `OPENAI_API_KEY` | Clave API de IA | `sk-xxxxx` |

### Variables de entorno opcionales

| Nombre de variable | Valor predeterminado | Descripción |
|--------|--------|------|
| `DB_PORT` | `5432` | Puerto de la base de datos |
| `DB_NAME` | `postgres` | Nombre de la base de datos |
| `DB_USER` | `postgres` | Nombre de usuario de la base de datos |
| `OPENAI_API_BASE` | `https://api.openai.com/v1` | URL base de la API |
| `OPENAI_MODEL` | `gpt-4o` | Nombre del modelo utilizado |
| `MODEL_MAX_TOKENS` | `1000` | Máximo de tokens de salida |
| `MODEL_TEMPERATURE` | `0.1` | Temperatura del modelo (0-1) |
| `IMAGE_MAX_SIZE` | `1024` | Tamaño máximo de imagen (px) |
| `IMAGE_QUALITY` | `85` | Calidad de compresión de imagen (1-100) |
| `USER_HISTORY_FOLDER` | `user_history` | Directorio de guardado del historial de usuarios |
| `LOG_LEVEL` | `INFO` | Nivel de registro |

### Servicios de IA compatibles

Esta herramienta es compatible con cualquier servicio que utilice el formato de la API de OpenAI：

| Proveedor | URL base de la API |
|--------|--------------|
| OpenAI | `https://api.openai.com/v1` |
| Azure OpenAI | `https://your-resource.openai.azure.com/openai/deployments/your-deployment` |
| Proveedor de terceros | Configure según la dirección proporcionada por el proveedor |

---

## 📝 Guía de uso

1. Acceda a `http://localhost:5000`
2. Inicie sesión con su correo y contraseña
3. Suba una imagen de una fórmula matemática：
   - 🖱️ Haga clic en el área de carga para seleccionar un archivo
   - 📂 Arrastre la imagen al área de carga
   - 📋 Pegue directamente una captura de pantalla (Ctrl+V)
4. Haga clic en「Iniciar conversión」
5. Espere a que el reconocimiento de IA finalice
6. Copie el código LaTeX generado

### Uso en Word

1. Presione `Alt + =` para abrir el editor de fórmulas
2. Haga clic en el botón「LaTeX」en la parte superior para cambiar el modo
3. Pegue el código LaTeX
4. Presione Enter para completar la entrada

---

## 📁 Historial de usuarios

El sistema guarda automáticamente los registros de carga de cada usuario, lo que facilita la auditoría y gestión por parte del administrador.

### Estructura de directorios

```
user_history/
├── john_at_example_com/
│   ├── 20251208_143000_123456/
│   │   ├── image.png          # Imagen original subida por el usuario
│   │   ├── result.txt         # Código LaTeX devuelto por la IA
│   │   └── metadata.json      # Metadatos (hora, estado, etc.)
│   └── 20251208_144530_789012/
│       └── ...
└── jane_at_test_com/
    └── ...
```

### Ejemplo de metadatos (metadata.json)

```json
{
  "email": "john@example.com",
  "timestamp": "2025-12-08T14:30:00.123456",
  "success": true,
  "latex_length": 156
}
```

---

## 🔧 Solución de problemas

| Problema | Solución |
|------|----------|
| Fallo al iniciar el contenedor | Verifique que las variables de entorno estén configuradas correctamente |
| Fallo de conexión a la base de datos | Confirme que la dirección, el puerto y la contraseña de la base de datos son correctos |
| Fallo en la llamada a la API | Verifique que la clave API sea válida y que el modelo admita imágenes |
| "Usuario no existe" | Confirme que el correo existe en la tabla `auth` |
| "Contraseña incorrecta" | Confirme que la contraseña es correcta (admite texto plano o hash bcrypt) |
| "Cuenta no activada" | El administrador debe cambiar el role a 'user' o 'admin' en la tabla `user` |
| "Información de usuario incompleta" | Debe agregar un registro con el correo correspondiente en la tabla `user` |
| Desconectado | La cuenta podría haber sido eliminada o establecida en estado pending |

Para ver los registros del contenedor：
```bash
docker logs math-ocr-tool
```

---

## 📊 Interfaz de API

| Endpoint | Método | Descripción | Autenticación |
|------|------|------|------|
| `/health` | GET | Comprobación de salud | No |
| `/stats` | GET | Obtener estadísticas de conversión | No |
| `/login` | GET/POST | Inicio de sesión de usuario | No |
| `/logout` | GET | Cierre de sesión de usuario | No |
| `/` | GET | Página principal | Se requiere inicio de sesión |
| `/upload` | POST | Subir archivo de imagen | Se requiere inicio de sesión |
| `/upload_base64` | POST | Subir imagen en Base64 | Se requiere inicio de sesión |
| `/download_word` | POST | Descargar documento Word | Se requiere inicio de sesión |

---

## 🤝 Contribución

¡Se aceptan issues y pull requests!

1. Realice un Fork de este repositorio
2. Cree una rama：`git checkout -b feature/tu-caracteristica`
3. Realice commit de los cambios：`git commit -m 'Agrega tu característica'`
4. Empuje la rama：`git push origin feature/tu-caracteristica`
5. Envíe un Pull Request

---

## 📄 Licencia

Este proyecto utiliza la licencia [MIT License](LICENSE).

---

## Español

### Inicio rápido

**Despliegue con un clic (Linux/macOS):**：**
```bash
curl -fsSL https://raw.githubusercontent.com/zhizinan1997/math-ocr-tool/main/quick_deploy.sh -o quick_deploy.sh && chmod +x quick_deploy.sh && ./quick_deploy.sh
```

**Docker：**
```bash
docker run -d --name math-ocr-tool -p 5000:5000 \
    -e DB_HOST="tu-host-de-db" \
    -e DB_PASSWORD="tu-contraseña-de-db" \
    -e OPENAI_API_KEY="tu-clave-api" \
    ghcr.io/zhizinan1997/math-ocr-tool:latest
```

### Características

- 🤖 Reconocimiento de fórmulas matemáticas impulsado por IA
- 📸 Múltiples métodos de carga (arrastrar y soltar, hacer clic, pegar)
- 🔍 Vista previa de LaTeX en tiempo real con MathJax
- 📋 Copia con un clic al portapapeles
- 🔐 Autenticación de usuario con control de acceso basado en roles
- 📝 Registro del historial de usuarios para gestióngestión administrativaadmin
- 🐳 Listo para despliegue con Docker

### Configuración de la base de datos

Esta herramienta requiere dos tablas para la autenticación：

1. **Tabla `auth`** - Almacena las credenciales de inicio de sesión (correo, contraseña)
2. **Tabla `user`** - Almacena los roles de usuario (admin, user, pending)

Los usuarios con `role = 'pending'` no pueden iniciar sesión hasta que un administrador cambie su rol.

### Configuración

| Variable | Requeratorio | Descripción |
|----------|----------|-------------|
| `DB_HOST` | Sí | Host de la base de datos PostgreSQL |
| `DB_PASSWORD` | Sí | Contraseña de la base de datos |
| `OPENAI_API_KEY` | Sí | Clave API de IA |
| `OPENAI_API_BASE` | No | URL base de la API (predeterminado: OpenAI) |
| `OPENAI_MODEL` | No | Nombre del modelo (predeterminado: gpt-4o) |
| `USER_HISTORY_FOLDER` | No | Carpeta del historial de usuarios (predeterminado: user_history) |

---

<div align="center">

Hecho con ❤️ por [zhizinan1997](https://github.com/zhizinan1997)

</div>
