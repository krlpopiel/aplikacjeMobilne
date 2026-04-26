import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet, Alert } from 'react-native';
import { useRouter } from 'expo-router';
import { supabase } from '@/utils/supabase';
import { useStore } from '@/utils/userStore';

export default function Konto() {
    const router = useRouter();
    const email = useStore((s) => s.email);
    const clearUser = useStore((s) => s.clearUser);

    const performLogout = async () => {
        try {
            await supabase.auth.signOut();
        } catch (error) {
            console.error("Logout error:", error);
        } finally {
            clearUser();
            router.replace('/login');
        }
    };

    const handleLogout = () => {
        if (typeof window !== 'undefined' && window.confirm) {
            const confirmed = window.confirm('Czy na pewno chcesz się wylogować?');
            if (confirmed) performLogout();
        } else {
            Alert.alert('Wyloguj', 'Czy na pewno chcesz się wylogować?', [
                { text: 'Anuluj' },
                { text: 'Wyloguj', style: 'destructive', onPress: performLogout },
            ]);
        }
    };

    return (
        <View style={styles.container}>
            <View style={styles.profileCard}>
                <Text style={styles.avatar}>👤</Text>
                <Text style={styles.email}>{email}</Text>
            </View>

            <TouchableOpacity style={styles.logoutBtn} onPress={handleLogout}>
                <Text style={styles.logoutBtnText}>Wyloguj się</Text>
            </TouchableOpacity>
        </View>
    );
}

const styles = StyleSheet.create({
    container: { flex: 1, padding: 24, backgroundColor: '#f5f5f5' },
    profileCard: { backgroundColor: '#fff', borderRadius: 12, padding: 24, alignItems: 'center', elevation: 2, shadowColor: '#000', shadowOpacity: 0.08, shadowRadius: 4, shadowOffset: { width: 0, height: 2 }, marginBottom: 24 },
    avatar: { fontSize: 48, marginBottom: 12 },
    email: { fontSize: 16, color: '#333' },
    logoutBtn: { backgroundColor: '#ff3b30', borderRadius: 10, padding: 16, alignItems: 'center' },
    logoutBtnText: { color: '#fff', fontSize: 17, fontWeight: '600' },
});
