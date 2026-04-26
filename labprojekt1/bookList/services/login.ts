import { supabase } from '@/utils/supabase'
import { useStore } from '@/utils/userStore'

export const loginUser = async (payload: any) => {
    try {
        const { data, error } = await supabase.auth.signInWithPassword({
            email: payload.email,
            password: payload.password,
        })

        if (error) {
            console.log(error)
            throw error
        }

        return {
            success: true,
            message: 'User logged in successfully',

        }

    } catch (error: any) {
        return {
            success: false,
            error: error?.message || JSON.stringify(error) || 'Nieznany błąd'
        }
    }
}