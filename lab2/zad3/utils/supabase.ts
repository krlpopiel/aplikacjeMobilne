import 'react-native-url-polyfill/auto'
import AsyncStorage from '@react-native-async-storage/async-storage'
import { createClient, processLock } from '@supabase/supabase-js'
import { Platform } from 'react-native'

const authConfig = Platform.OS === 'web' ? {
  autoRefreshToken: true,
  persistSession: false,
  detectSessionInUrl: false,
  lock: processLock,
} : {
  storage: AsyncStorage,
  autoRefreshToken: true,
  persistSession: true,
  detectSessionInUrl: false,
  lock: processLock,
}

export const supabase = createClient(
  process.env.EXPO_PUBLIC_SUPABASE_URL!,
  process.env.EXPO_PUBLIC_SUPABASE_KEY!,
  {
    auth: authConfig,
  })
        