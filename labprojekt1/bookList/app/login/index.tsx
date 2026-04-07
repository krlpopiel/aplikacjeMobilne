import { useState } from "react";
import { Alert, Button, StyleSheet, Text, TextInput, View } from "react-native";
import { useRouter } from "expo-router";
import { loginUser } from "@/services/login";
import { useStore } from "@/utils/userStore";
import { supabase } from "@/utils/supabase";

export default function Login() {
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [loading, setLoading] = useState(false);
    const router = useRouter();
    const setUser = useStore((s) => s.setUser);

    const handleLogin = async () => {
        if (!email || !password) {
            Alert.alert('Błąd', 'Wypełnij wszystkie pola');
            return;
        }
        setLoading(true);
        const result = await loginUser({ email, password });
        setLoading(false);

        if (result.success) {
            const { data: { user } } = await supabase.auth.getUser();
            if (user) {
                setUser(user.id, user.email || email);
            }
            router.replace('/(tabs)/ksiazki');
        } else {
            Alert.alert('Błąd logowania', result.error);
        }
    };

    return (
        <View style={styles.container}>
            <Text style={styles.title}>BookTracker</Text>
            <Text style={styles.subtitle}>Logowanie</Text>
            <TextInput
                style={styles.input}
                placeholder="Email"
                value={email}
                onChangeText={setEmail}
                keyboardType="email-address"
                autoCapitalize="none"
            />
            <TextInput
                style={styles.input}
                placeholder="Hasło"
                value={password}
                onChangeText={setPassword}
                secureTextEntry
            />
            <Button title={loading ? "Logowanie..." : "Zaloguj się"} onPress={handleLogin} disabled={loading} />
            <Text style={styles.link} onPress={() => router.push('/rejestracja')}>
                Nie masz konta? Zarejestruj się
            </Text>
        </View>
    );
}

const styles = StyleSheet.create({
    container: { flex: 1, justifyContent: 'center', padding: 24, backgroundColor: '#fff' },
    title: { fontSize: 28, fontWeight: 'bold', textAlign: 'center', marginBottom: 4 },
    subtitle: { fontSize: 18, textAlign: 'center', marginBottom: 24, color: '#666' },
    input: { borderWidth: 1, borderColor: '#ccc', borderRadius: 8, padding: 12, marginBottom: 12, fontSize: 16 },
    link: { marginTop: 16, textAlign: 'center', color: '#007AFF', fontSize: 14 },
});
