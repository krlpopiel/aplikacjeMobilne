import { useState } from "react";
import { Alert, Button, StyleSheet, Text, TextInput, View } from "react-native";
import { useRouter } from "expo-router";
import { registerUser } from "@/services/register";

export default function Rejestracja() {
    const [email, setEmail] = useState('');
    const [name, setName] = useState('');
    const [password, setPassword] = useState('');
    const [loading, setLoading] = useState(false);
    const router = useRouter();

    const handleRegister = async () => {
        if (!email || !password || !name) {
            Alert.alert('Błąd', 'Wypełnij wszystkie pola');
            return;
        }
        setLoading(true);
        const result = await registerUser({ email, password, name });
        setLoading(false);

        if (result.success) {
            Alert.alert('Sukces', 'Konto utworzone! Możesz się zalogować.', [
                { text: 'OK', onPress: () => router.replace('/login') }
            ]);
        } else {
            Alert.alert('Błąd rejestracji', result.error);
        }
    };

    return (
        <View style={styles.container}>
            <Text style={styles.title}>BookTracker</Text>
            <Text style={styles.subtitle}>Rejestracja</Text>
            <TextInput
                style={styles.input}
                placeholder="Nazwa użytkownika"
                value={name}
                onChangeText={setName}
            />
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
            <Button title={loading ? "Rejestracja..." : "Zarejestruj się"} onPress={handleRegister} disabled={loading} />
            <Text style={styles.link} onPress={() => router.back()}>
                Masz już konto? Zaloguj się
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
