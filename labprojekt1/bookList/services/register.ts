import { supabase } from '@/utils/supabase'

export const registerUser = async (payload: any) => {
    try {
        const { data, error } = await supabase.auth.signUp({
            email: payload.email!,
            password: payload.password!,
        })

        if (error) {
            console.log(error)
            throw error
        }

        const { data: profileData, error: profileError } = await supabase.from('user_profiles').insert([
            {
                id: data.user?.id,
                email: payload.email,
                name: payload.name
            }
        ])

        if (profileError) {
            console.log(profileError)
            throw profileError
        }

        return {
            success: true,
            message: 'User registered successfully',
        }

    } catch (error: any) {
        return {
            success: false,
            error: error?.message || JSON.stringify(error) || 'Nieznany błąd'
        }
    }
}