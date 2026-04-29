# Grinnell 4-Year Planner

React reads planner data from the SQL-backed API in `server/` instead of importing
JSON files directly.

## Setup

1. Create a PostgreSQL database.
2. Copy `.env.example` to `.env` and update the `PG*` values.
3. Load the schema and seed data:

```sh
psql "$DATABASE_URL" -f sql/99_run_all.sql
```

If you use separate `PGHOST`, `PGDATABASE`, `PGUSER`, and `PGPASSWORD` values,
run `psql -f sql/99_run_all.sql` after exporting those variables.

## Run

Use two terminals:

```sh
npm run server
```

```sh
npm run dev
```

The React app calls `/api/courses` and `/api/majors/CSC/requirements`; Vite

