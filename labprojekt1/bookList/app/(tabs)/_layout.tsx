import { Tabs } from 'expo-router';
import { Text } from 'react-native';

export default function TabsLayout() {
    return (
        <Tabs screenOptions={{ headerShown: true }}>
            <Tabs.Screen
                name="ksiazki"
                options={{
                    title: 'Książki',
                    tabBarIcon: ({ color }) => <Text style={{ fontSize: 20, color }}>📚</Text>,
                }}
            />
            <Tabs.Screen
                name="odkrywaj"
                options={{
                    title: 'Odkrywaj',
                    tabBarIcon: ({ color }) => <Text style={{ fontSize: 20, color }}>🌍</Text>,
                }}
            />
            <Tabs.Screen
                name="statystyki"
                options={{
                    title: 'Statystyki',
                    tabBarIcon: ({ color }) => <Text style={{ fontSize: 20, color }}>📊</Text>,
                }}
            />
            <Tabs.Screen
                name="obserwowani"
                options={{
                    title: 'Obserwowani',
                    tabBarIcon: ({ color }) => <Text style={{ fontSize: 20, color }}>👥</Text>,
                }}
            />
            <Tabs.Screen
                name="konto"
                options={{
                    title: 'Konto',
                    tabBarIcon: ({ color }) => <Text style={{ fontSize: 20, color }}>👤</Text>,
                }}
            />
        </Tabs>
    );
}
