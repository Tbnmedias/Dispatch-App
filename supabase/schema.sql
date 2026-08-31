-- Phase 1 schema: dispatch + load tracking
-- Run this in the Supabase SQL editor, or via `supabase db push` once
-- this file is placed in supabase/migrations/.

create table if not exists drivers (
  id uuid primary key default gen_random_uuid(),
  full_name text not null,
  phone text,
  created_at timestamptz default now()
);

create table if not exists trucks (
  id uuid primary key default gen_random_uuid(),
  truck_number text not null unique,
  license_plate text,
  capacity_tons numeric,
  driver_id uuid references drivers(id),
  driver_name text, -- denormalized for quick dashboard reads
  status text not null default 'available'
    check (status in ('available','loading','delivering','returning','maintenance')),
  current_job text,
  loads_today integer not null default 0,
  updated_at timestamptz default now()
);

create table if not exists customers (
  id uuid primary key default gen_random_uuid(),
  company_name text not null,
  contact_name text,
  phone text,
  payment_terms text default 'cash', -- cash | credit
  created_at timestamptz default now()
);

create table if not exists orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  customer_id uuid references customers(id),
  material text not null,
  quantity numeric not null,
  unit text not null default 'load', -- load | cubic_yard | ton
  price_per_unit numeric,
  delivery_location text,
  requested_at timestamptz default now(),
  payment_status text not null default 'unpaid'
    check (payment_status in ('unpaid','partial','paid')),
  notes text
);

create table if not exists loads (
  id uuid primary key default gen_random_uuid(),
  order_id uuid references orders(id),
  truck_id uuid references trucks(id),
  loaded_at timestamptz,
  delivered_at timestamptz,
  status text not null default 'waiting'
    check (status in ('waiting','en_route','loading','delivering','completed')),
  photo_url text,
  signature_url text
);

-- Row Level Security: locked down by default, open up as you add auth roles
alter table drivers enable row level security;
alter table trucks enable row level security;
alter table customers enable row level security;
alter table orders enable row level security;
alter table loads enable row level security;

-- Starter policy: any authenticated user can read/write everything.
-- Tighten this once you add dispatcher vs driver roles (e.g. drivers should
-- only see their own truck's loads).
create policy "authenticated read/write" on drivers
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "authenticated read/write" on trucks
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "authenticated read/write" on customers
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "authenticated read/write" on orders
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "authenticated read/write" on loads
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
