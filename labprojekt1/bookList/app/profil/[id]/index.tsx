import React, { useState, useEffect } from 'react';
import { View, Text, FlatList, TouchableOpacity, StyleSheet, Alert } from 'react-native';
import { useLocalSearchParams } from 'expo-router';
import { fetchUserFinishedBooks, quickCopyBook, Book } from '@/services/books';
import { followUser, isFollowing, unfollowUser } from '@/services/follows';
import { useStore } from '@/utils/userStore';

export default function PublicProfile() {
    const { id: profileUserId } = useLocalSearchParams<{ id: string }>();
    const [books, setBooks] = useState<Book[]>([]);
    const [followed, setFollowed] = useState(false);
    const userId = useStore((s) => s.userId);

    useEffect(() => {
        if (!profileUserId) return;
        fetchUserFinishedBooks(profileUserId).then(setBooks).catch(console.error);
        if (userId && profileUserId) {
            isFollowing(userId, profileUserId).then(setFollowed);
        }
    }, [profileUserId, userId]);

    const toggleFollow = async () => {
        if (!userId || !profileUserId) return;
        try {
            if (followed) {
                await unfollowUser(userId, profileUserId);
                setFollowed(false);
            } else {
                await followUser(userId, profileUserId);
                setFollowed(true);
            }
        } catch (e: any) {
            Alert.alert('Błąd', e.message);
        }
    };

    const handleQuickCopy = async (title: string, author: string) => {
        if (!userId) return;
        try {
            await quickCopyBook(title, author, userId);
            Alert.alert('Sukces', 'Dodano do Twojej listy jako "Do przeczytania"');
        } catch (e: any) {
            Alert.alert('Błąd', e.message);
        }
    };

    return (
        <View style={styles.container}>
            <View style={styles.profileHeader}>
                <Text style={styles.header}>Profil użytkownika</Text>
                <Text style={styles.userId}>{profileUserId?.substring(0, 16)}...</Text>
                {userId !== profileUserId && (
                    <TouchableOpacity style={[styles.followBtn, followed && styles.followBtnActive]} onPress={toggleFollow}>
                        <Text style={styles.followBtnText}>{followed ? 'Obserwujesz' : 'Obserwuj'}</Text>
                    </TouchableOpacity>
                )}
            </View>

            <Text style={styles.sectionTitle}>Przeczytane książki ({books.length})</Text>

            <FlatList
                data={books}
                keyExtractor={(item) => item.id.toString()}
                renderItem={({ item }) => (
                    <View style={styles.card}>
                        <View style={styles.cardInfo}>
                            <Text style={styles.cardTitle}>{item.title}</Text>
                            <Text style={styles.cardAuthor}>{item.author}</Text>
                            <View style={styles.cardMeta}>
                                <Text style={styles.stars}>{'★'.repeat(item.rating)}{'☆'.repeat(5 - item.rating)}</Text>
                                <Text style={styles.dateText}>{new Date(item.date_added).toLocaleDateString('pl-PL')}</Text>
                            </View>
                        </View>
                        {userId !== profileUserId && (
                            <TouchableOpacity style={styles.copyBtn} onPress={() => handleQuickCopy(item.title, item.author)}>
                                <Text style={styles.copyBtnText}>+ Moja lista</Text>
                            </TouchableOpacity>
                        )}
                    </View>
                )}
                ListEmptyComponent={<Text style={styles.empty}>Brak przeczytanych książek.</Text>}
            />
        </View>
    );
}

const styles = StyleSheet.create({
    container: { flex: 1, padding: 16, backgroundColor: '#f5f5f5' },
    profileHeader: { marginBottom: 16 },
    header: { fontSize: 24, fontWeight: 'bold' },
    userId: { fontSize: 13, color: '#999', marginTop: 2 },
    followBtn: { marginTop: 10, backgroundColor: '#007AFF', borderRadius: 8, paddingVertical: 10, alignItems: 'center' },
    followBtnActive: { backgroundColor: '#34c759' },
    followBtnText: { color: '#fff', fontSize: 15, fontWeight: '600' },
    sectionTitle: { fontSize: 18, fontWeight: '600', marginBottom: 10 },
    card: { backgroundColor: '#fff', borderRadius: 10, padding: 14, marginBottom: 10, flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', elevation: 2, shadowColor: '#000', shadowOpacity: 0.08, shadowRadius: 4, shadowOffset: { width: 0, height: 2 } },
    cardInfo: { flex: 1, marginRight: 10 },
    cardTitle: { fontSize: 16, fontWeight: '600' },
    cardAuthor: { fontSize: 13, color: '#666', marginTop: 2 },
    cardMeta: { flexDirection: 'row', justifyContent: 'space-between', marginTop: 6 },
    stars: { fontSize: 16, color: '#f5a623' },
    dateText: { fontSize: 12, color: '#999' },
    copyBtn: { backgroundColor: '#34c759', paddingHorizontal: 10, paddingVertical: 8, borderRadius: 8 },
    copyBtnText: { color: '#fff', fontSize: 12, fontWeight: '600' },
    empty: { textAlign: 'center', marginTop: 40, color: '#999', fontSize: 16 },
});
