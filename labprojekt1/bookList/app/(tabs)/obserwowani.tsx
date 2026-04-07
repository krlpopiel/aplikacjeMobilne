import React, { useState, useCallback } from 'react';
import { View, Text, FlatList, TouchableOpacity, StyleSheet, Alert } from 'react-native';
import { useRouter, useFocusEffect } from 'expo-router';
import { fetchFollowing, unfollowUser, UserFollow } from '@/services/follows';
import { useStore } from '@/utils/userStore';

export default function Obserwowani() {
    const [following, setFollowing] = useState<UserFollow[]>([]);
    const userId = useStore((s) => s.userId);
    const router = useRouter();

    const loadFollowing = async () => {
        if (!userId) return;
        try {
            const data = await fetchFollowing(userId);
            setFollowing(data);
        } catch (e: any) {
            console.error(e.message);
        }
    };

    useFocusEffect(
        useCallback(() => {
            loadFollowing();
        }, [userId])
    );

    const handleUnfollow = (followingId: string) => {
        Alert.alert('Przestań obserwować', 'Czy na pewno?', [
            { text: 'Anuluj' },
            {
                text: 'Tak', style: 'destructive', onPress: async () => {
                    if (!userId) return;
                    await unfollowUser(userId, followingId);
                    loadFollowing();
                }
            },
        ]);
    };

    return (
        <View style={styles.container}>
            <FlatList
                data={following}
                keyExtractor={(item) => item.id.toString()}
                renderItem={({ item }) => (
                    <View style={styles.card}>
                        <TouchableOpacity style={styles.userInfo} onPress={() => router.push(`/profil/${item.following_id}`)}>
                            <Text style={styles.userId}>{item.following_id.substring(0, 12)}...</Text>
                            <Text style={styles.dateText}>Od: {new Date(item.created_at).toLocaleDateString('pl-PL')}</Text>
                        </TouchableOpacity>
                        <View style={styles.actions}>
                            <TouchableOpacity style={styles.viewBtn} onPress={() => router.push(`/profil/${item.following_id}`)}>
                                <Text style={styles.viewBtnText}>Książki</Text>
                            </TouchableOpacity>
                            <TouchableOpacity style={styles.unfollowBtn} onPress={() => handleUnfollow(item.following_id)}>
                                <Text style={styles.unfollowBtnText}>Usuń</Text>
                            </TouchableOpacity>
                        </View>
                    </View>
                )}
                ListEmptyComponent={<Text style={styles.empty}>Nie obserwujesz jeszcze nikogo.</Text>}
            />
        </View>
    );
}

const styles = StyleSheet.create({
    container: { flex: 1, padding: 16, backgroundColor: '#f5f5f5' },
    card: { backgroundColor: '#fff', borderRadius: 10, padding: 14, marginBottom: 10, flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', elevation: 2, shadowColor: '#000', shadowOpacity: 0.08, shadowRadius: 4, shadowOffset: { width: 0, height: 2 } },
    userInfo: { flex: 1 },
    userId: { fontSize: 15, fontWeight: '600', color: '#007AFF' },
    dateText: { fontSize: 12, color: '#999', marginTop: 2 },
    actions: { flexDirection: 'row', gap: 8 },
    viewBtn: { backgroundColor: '#e8f0fe', paddingHorizontal: 12, paddingVertical: 8, borderRadius: 8 },
    viewBtnText: { color: '#007AFF', fontSize: 13, fontWeight: '600' },
    unfollowBtn: { backgroundColor: '#ffe5e5', paddingHorizontal: 12, paddingVertical: 8, borderRadius: 8 },
    unfollowBtnText: { color: '#ff3b30', fontSize: 13, fontWeight: '600' },
    empty: { textAlign: 'center', marginTop: 40, color: '#999', fontSize: 16 },
});
