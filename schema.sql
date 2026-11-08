-- Music Collection: ejecutar TODO este archivo en Supabase > SQL Editor > New query.
create extension if not exists pgcrypto;

create table if not exists public.records (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  artist text,
  title text,
  year integer,
  record_type text default 'single' check (record_type in ('single','album','compilation','other')),
  label text,
  catalog_number text,
  barcode text,
  format text,
  mp3_bitrate text,
  genre text,
  styles text,
  discogs_url text,
  original_name text,
  source_path text,
  discogs_release_id text,
  search_status text default 'Pendiente',
  edition text,
  extra_info text,
  cover_path text,
  cover_url text,
  drive_cover_file_id text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create unique index if not exists records_user_source_unique
on public.records(user_id, coalesce(source_path,''), coalesce(original_name,''));

create index if not exists records_user_artist_title_idx
on public.records(user_id, artist, title);

alter table public.records enable row level security;

drop policy if exists "Users can view their own records" on public.records;
create policy "Users can view their own records" on public.records
for select to authenticated using (auth.uid() = user_id);

drop policy if exists "Users can insert their own records" on public.records;
create policy "Users can insert their own records" on public.records
for insert to authenticated with check (auth.uid() = user_id);

drop policy if exists "Users can update their own records" on public.records;
create policy "Users can update their own records" on public.records
for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "Users can delete their own records" on public.records;
create policy "Users can delete their own records" on public.records
for delete to authenticated using (auth.uid() = user_id);

create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end; $$;

drop trigger if exists records_set_updated_at on public.records;
create trigger records_set_updated_at before update on public.records
for each row execute function public.set_updated_at();

-- Almacenamiento privado para carátulas: las políticas limitan cada usuario a su propia carpeta.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('covers', 'covers', false, 12582912, array['image/jpeg','image/png','image/webp','image/bmp'])
on conflict (id) do nothing;

drop policy if exists "Users can read their cover files" on storage.objects;
create policy "Users can read their cover files" on storage.objects
for select to authenticated using (bucket_id = 'covers' and (storage.foldername(name))[1] = auth.uid()::text);

drop policy if exists "Users can upload their cover files" on storage.objects;
create policy "Users can upload their cover files" on storage.objects
for insert to authenticated with check (bucket_id = 'covers' and (storage.foldername(name))[1] = auth.uid()::text);

drop policy if exists "Users can update their cover files" on storage.objects;
create policy "Users can update their cover files" on storage.objects
for update to authenticated using (bucket_id = 'covers' and (storage.foldername(name))[1] = auth.uid()::text)
with check (bucket_id = 'covers' and (storage.foldername(name))[1] = auth.uid()::text);

drop policy if exists "Users can delete their cover files" on storage.objects;
create policy "Users can delete their cover files" on storage.objects
for delete to authenticated using (bucket_id = 'covers' and (storage.foldername(name))[1] = auth.uid()::text);
