# Music Collection — Cloudflare Pages + Supabase

Versión web inicial adaptada desde el prototipo FastAPI/SQLite 0.2.

## Contenido
- `public/index.html`: aplicación web.
- `functions/api/discogs.js`: proxy de búsqueda Discogs (token solo en secreto de Cloudflare).
- `supabase/schema.sql`: tablas, políticas de seguridad (RLS) y almacenamiento privado de carátulas.
- `MANUAL_INSTALACION.pdf` y `.md`: manual de despliegue.

## Despliegue
1. Crea un proyecto Supabase y ejecuta `supabase/schema.sql` en SQL Editor.
2. En Supabase > Authentication > URL Configuration, añade el dominio Cloudflare Pages como Site URL y Redirect URL.
3. Copia Project URL y la clave `anon`/`publishable` desde Project Settings > API.
4. Sube este proyecto a un repositorio privado de GitHub.
5. En Cloudflare Pages crea un proyecto conectado a GitHub. Build command: vacío; Build output directory: `public`; raíz: `/`.
6. En Settings > Variables and Secrets añade `DISCOGS_TOKEN` como secreto (opcional).
7. Abre la URL `https://nombre.pages.dev`, introduce URL y clave pública Supabase y crea tu usuario.
8. Para Drive sigue el apartado correspondiente del manual.

## Seguridad
- Nunca introducir la clave `service_role` en la web.
- RLS protege los registros por `user_id`.
- Las carátulas se guardan en un bucket privado y se muestran con enlaces firmados temporales.
- Drive usa el scope limitado `drive.file`.
- El token de Discogs se guarda como secreto de Cloudflare.

## Estado y límites de esta entrega
Esta entrega contiene la aplicación web y el esquema cloud. No incorpora todavía el sincronizador de la aplicación Windows 0.2 con PostgreSQL; esa adaptación es una fase independiente. El escáner web envía nombres y rutas relativas, no los archivos de audio. La integración Drive permite subir backups JSON y Excel; la copia del original de carátula a Drive se intenta al subir una imagen si Drive está conectado; no hay restauración automática desde Drive, mientras las carátulas se almacenan en Supabase Storage para mostrarse entre dispositivos. El consentimiento Google se renueva cuando caduca el token.
