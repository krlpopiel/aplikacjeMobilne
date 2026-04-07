import { Stack, useRouter, useSegments } from "expo-router";
import { useEffect, useState } from "react";
import { supabase } from "@/utils/supabase";
import { useStore } from "@/utils/userStore";

export default function RootLayout() {
    const router = useRouter();
    const segments = useSegments();
    const [initialized, setInitialized] = useState(false);
    
    const userId = useStore((s) => s.userId);
    const setUser = useStore((s) => s.setUser);
    const clearUser = useStore((s) => s.clearUser);

    useEffect(() => {
        const { data: { subscription } } = supabase.auth.onAuthStateChange(
            (event, session) => {
                if (session?.user) {
                    setUser(session.user.id, session.user.email || '');
                } else {
                    clearUser();
                }
                setInitialized(true);
            }
        );
        return () => subscription.unsubscribe();
    }, []);

    useEffect(() => {
        if (!initialized) return;

        const inAuthGroup = segments[0] === 'login' || segments[0] === 'rejestracja';

        if (!userId && !inAuthGroup) {
            router.replace('/login');
        } else if (userId && inAuthGroup) {
            router.replace('/(tabs)/ksiazki');
        } else if (userId && !segments[0]) {
            router.replace('/(tabs)/ksiazki');
        }
    }, [userId, initialized, segments]);

    return (
        <Stack>
            <Stack.Screen name="index" options={{ headerShown: false }} />
            <Stack.Screen name="login/index" options={{ headerShown: false, title: 'Logowanie' }} />
            <Stack.Screen name="rejestracja/index" options={{ headerShown: false, title: 'Rejestracja' }} />
            <Stack.Screen name="(tabs)" options={{ headerShown: false }} />
            <Stack.Screen name="dodajKsiazke/index" options={{ title: 'Dodaj/Edytuj', presentation: 'modal' }} />
            <Stack.Screen name="ksiazki/[id]/index" options={{ title: 'Szczegóły książki' }} />
            <Stack.Screen name="profil/[id]/index" options={{ title: 'Profil' }} />
        </Stack>
    );
}
