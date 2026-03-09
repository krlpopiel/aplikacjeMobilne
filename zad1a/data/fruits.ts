import { createClient } from '@supabase/supabase-js'


const SUPABASE_URL = process.env.EXPO_PUBLIC_PROJECT_URL;
const SUPABASE_KEY = process.env.EXPO_PUBLIC_PUBLISHABLE_KEY;

if (!SUPABASE_URL || !SUPABASE_KEY) {
  throw new Error(
    'Brak danych logowania Supabase. Sprawdź, czy zmienne EXPO_PUBLIC_PROJECT_URL ' +
    'oraz EXPO_PUBLIC_PUBLISHABLE_KEY są zdefiniowane w pliku .env.local'
  );
}

export const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);