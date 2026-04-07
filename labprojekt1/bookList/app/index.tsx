import { useEffect } from 'react';
import { View, ActivityIndicator } from 'react-native';
import { useRouter } from 'expo-router';
import { supabase } from '@/utils/supabase';
import { useStore } from '@/utils/userStore';

export default function Index() {
    const router = useRouter();
    const setUser = useStore((s) => s.setUser);

    useEffect(() => {
        supabase.auth.getSession()
        .then(({ data: { session } }) => {
            if (session?.user) {
                setUser(session.user.id, session.user.email || '');
                router.replace('/(tabs)/ksiazki');
            } else {
                router.replace('/login');
            }
        })
        .catch((error) => {
            console.error("Session fetch error:", error);
            router.replace('/login');
        });
    }, []);

    return (
        <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
            <ActivityIndicator size="large" />
        </View>
    );
}
