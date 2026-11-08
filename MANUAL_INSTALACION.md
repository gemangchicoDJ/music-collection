# Manual de instalación y uso — Music Collection

## 1. Qué incluye
Esta versión web se publica en Cloudflare Pages, utiliza Supabase para usuarios, base de datos y carátulas, y permite guardar copias JSON y Excel en una carpeta de Google Drive. Se accede desde cualquier navegador con Internet. El plan gratuito de Supabase puede pausar proyectos con poca actividad; no equivale a un servicio con disponibilidad garantizada.

## 2. Crear la base de datos en Supabase
1. Entra en https://supabase.com/ y crea una cuenta.
2. Pulsa **New project**. Nombre: `MusicCollection`. Elige una región europea si está disponible.
3. Espera a que termine de crearse.
4. Abre **SQL Editor** > **New query**.
5. Abre el archivo `supabase/schema.sql` de este ZIP, copia todo su contenido y pégalo en SQL Editor.
6. Pulsa **Run**. Deben crearse la tabla `records`, las políticas de seguridad y el bucket privado `covers`.
7. Ve a **Project Settings > API**. Copia Project URL y la clave pública `anon` o `publishable`. Nunca copies `service_role`.

## 3. Publicar la web en Cloudflare Pages
1. Crea una cuenta en https://dash.cloudflare.com/.
2. Crea un repositorio privado en https://github.com/ y sube el contenido descomprimido de este ZIP.
3. En Cloudflare abre **Workers & Pages** > **Create** > **Pages** > **Connect to Git**.
4. Selecciona el repositorio.
5. Configuración: Framework preset `None`; Build command vacío; Build output directory `public`; Root directory `/`.
6. Pulsa **Save and Deploy**. Cloudflare asignará una dirección `https://...pages.dev`.
7. En Pages > tu proyecto > **Settings > Variables and Secrets**, crea `DISCOGS_TOKEN` con tu token personal de Discogs (opcional). Haz un nuevo despliegue para aplicar el secreto.

## 4. Configurar Supabase Auth
1. En Supabase abre **Authentication > URL Configuration**.
2. En **Site URL**, escribe tu URL Cloudflare, por ejemplo `https://music-collection.pages.dev`.
3. Añade esa misma dirección a **Redirect URLs**.
4. Si la confirmación de correo está activada, al crear la cuenta abre el correo y confirma la dirección.
5. Entra en la aplicación y crea tu cuenta con correo y contraseña.

## 5. Configurar la aplicación
1. Abre tu dirección Cloudflare.
2. En Configuración inicial pega Project URL y la clave pública anon/publishable.
3. Si quieres Drive, pega también Google OAuth Client ID (se explica en el apartado 6).
4. Pulsa **Guardar configuración**. Los datos de conexión se guardan en el navegador que estás usando. Si cambias de ordenador tendrás que introducirlos también allí.
5. Crea usuario o inicia sesión.

## 6. Conectar Google Drive
La conexión utiliza Google OAuth y el permiso `drive.file`, que limita el acceso a los archivos creados/abiertos por esta aplicación.
1. Entra en https://console.cloud.google.com/ y crea un proyecto de Google Cloud.
2. En **APIs & Services > Library**, habilita **Google Drive API**.
3. En **Google Auth Platform** configura la pantalla de consentimiento OAuth. Para uso personal puedes dejar la aplicación en modo de pruebas y añadir tu cuenta Google como usuario de prueba.
4. En **Clients** crea un OAuth Client ID de tipo **Web application**.
5. En **Authorized JavaScript origins**, añade tu URL Cloudflare exacta, por ejemplo `https://music-collection.pages.dev`. No pongas rutas ni barras finales.
6. Copia el Client ID terminado en `apps.googleusercontent.com`.
7. Pégalo en Configuración inicial de Music Collection y guarda.
8. Entra en **Herramientas y Drive** > **Conectar Google Drive**. Selecciona tu cuenta y acepta el permiso solicitado.
9. Pulsa **Guardar copia de la colección en Drive** o **Subir Excel a Drive**. La aplicación creará una carpeta `MusicCollection` si no existe y guardará los archivos generados por ella.
10. La autorización de acceso puede caducar; si ocurre, vuelve a pulsar **Conectar Google Drive**.

## 7. Uso de la aplicación
### Mi colección
- **Buscar**: filtra por artista, título, año, sello, número de catálogo, formato, género y otros campos.
- **Editar**: abre la ficha del disco para corregir los datos.
- **Discogs**: consulta coincidencias; elige la edición correcta antes de aplicar los datos.
- **Borrar**: elimina el registro. Descarga una copia antes si no estás seguro.
- **Exportar Excel**: descarga un fichero `.xlsx`.

### Añadir disco
Rellena artista, título, año, tipo, sello, catálogo, formato, calidad, género y estilo. Los campos que no conozcas pueden quedar vacíos. Pulsa **Guardar disco**. Para añadir una carátula, guarda primero el disco, vuelve a editarlo y utiliza el apartado de carátulas.

### Escanear una carpeta
En **Herramientas y Drive**, selecciona una carpeta desde el navegador y pulsa **Analizar carpeta seleccionada**. Se registran nombres de carpetas que contienen audio y archivos comprimidos detectados. El navegador no envía los MP3/FLAC/WAV al servidor. Revisa los resultados porque el análisis del nombre no sustituye la identificación manual.

### Copias
- **Descargar copia JSON**: guarda todos los registros en un fichero JSON.
- **Guardar copia en Drive**: sube un JSON a la carpeta MusicCollection.
- **Subir Excel a Drive**: crea una hoja Excel con los registros.
- **Restaurar copia JSON**: selecciona un backup previamente descargado. Haz una copia actual antes de restaurar.

## 8. Qué sincroniza y qué falta
La web comparte automáticamente sus registros entre los navegadores que inicien sesión en la misma cuenta. Las carátulas se guardan en el almacenamiento privado de Supabase y se sirven mediante enlaces temporales autenticados. La miniatura se genera en el navegador y se guarda en Supabase Storage. Si Drive está conectado cuando subes una carátula, también se intenta guardar el original en la carpeta MusicCollection. Los backups JSON y Excel se pueden copiar a Drive.

**Todavía no se sincroniza automáticamente la base SQLite de la antigua aplicación Windows 0.2 con Supabase.** La app Windows sigue siendo independiente hasta que se prepare e instale su módulo sincronizador. Tampoco se importan automáticamente archivos de audio ni se suben las carátulas a Drive en esta primera entrega; las carátulas se alojan en Supabase para que puedan verse desde otros dispositivos.

## 9. Solución de problemas
- **No inicia sesión**: comprueba URL y clave pública Supabase, confirma el correo y revisa Site URL/Redirect URLs.
- **Error al cargar registros**: verifica que ejecutaste todo `schema.sql` y que las políticas RLS están creadas.
- **Discogs no responde**: revisa que `DISCOGS_TOKEN` esté configurado como secreto en Cloudflare y vuelve a desplegar.
- **Google no autoriza**: comprueba que Drive API esté habilitada, el Client ID sea de tipo Web y la URL Cloudflare esté en Authorized JavaScript origins.
- **Drive pide autorizar otra vez**: vuelve a pulsar Conectar Google Drive; el token temporal puede caducar.
- **Proyecto Supabase pausado**: entra en el panel de Supabase y pulsa Resume project. El plan gratuito puede pausar proyectos con poca actividad durante una semana.

## 10. Seguridad y buenas prácticas
- No compartas la clave `service_role`, el token Discogs ni credenciales de Google.
- Usa una contraseña única y activa la confirmación de correo.
- Mantén copias JSON en tu ordenador además de Drive.
- Comprueba periódicamente el espacio disponible y las cuotas gratuitas.
- Los servicios gratuitos pueden cambiar sus condiciones y no ofrecen disponibilidad garantizada.
