-- Schema van de Supabase-tabel die de app gebruikt (ter referentie / om opnieuw aan te maken)
create table if not exists public.shauni_shop (
  id          text primary key,
  data        jsonb not null default '{}'::jsonb,
  updated_at  timestamptz not null default now()
);

-- De app gebruikt de anon key; deze policies laten lezen/schrijven toe
alter table public.shauni_shop enable row level security;
create policy "anon lezen"     on public.shauni_shop for select using (true);
create policy "anon toevoegen" on public.shauni_shop for insert with check (true);
create policy "anon wijzigen"  on public.shauni_shop for update using (true);

insert into public.shauni_shop (id, data) values ('main', '{"stock":[],"months":[]}')
on conflict (id) do nothing;
