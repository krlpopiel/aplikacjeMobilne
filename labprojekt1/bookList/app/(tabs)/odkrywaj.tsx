import React, { useState, useCallback } from 'react';
import { View, Text, FlatList, TextInput, TouchableOpacity, StyleSheet, Alert, ActivityIndicator } from 'react-native';
import { useFocusEffect } from 'expo-router';
import { fetchDiscoverBooks, quickCopyBook, Book } from '@/services/books';
import { useStore } from '@/utils/userStore';

export default function Odkrywaj() {
    const [books, setBooks] = useState<Book[]>([]);
    const [search, setSearch] = useState('');
    const [loading, setLoading] = useState(false);
    const userId = useStore((s) => s.userId);

    const loadBooks = async () => {
        if (!userId) return;
        setLoading(true);
        try {
            const data = await fetchDiscoverBooks(userId);
            setBooks(data);
        } catch (e: any) {
            console.error(e.message);
        }
        setLoading(false);
    };

    useFocusEffect(
        useCallback(() => {
            loadBooks();
        }, [userId])
    );

    const filtered = books.filter(
        (b) =>
            (b.title?.toLowerCase() || '').includes(search.toLowerCase()) ||
            (b.author?.toLowerCase() || '').includes(search.toLowerCase())
    );

    const handleAdd = async (book: Book) => {
        if (!userId) return;
        try {
            await quickCopyBook(book.title, book.author, userId);
            Alert.alert('Sukces', 'Książka została dodana do Twojej listy jako "Do przeczytania"');
            // Usuń z lokalnej listy po dodaniu, by nie wisiała nadal jako propozycja
            setBooks(prev => prev.filter(b => b.title !== book.title || b.author !== book.author));
        } catch (e: any) {
            Alert.alert('Błąd', e.message);
        }
    };

    return (
        <View style={styles.container}>
            <TextInput
                style={styles.searchInput}
                placeholder="Szukaj po tytule lub autorze..."
                value={search}
                onChangeText={setSearch}
            />

            {loading ? (
                <ActivityIndicator size="large" color="#007AFF" style={{ marginTop: 20 }} />
            ) : (
                <FlatList
                    data={filtered}
                    keyExtractor={(item, index) => `${item.id}-${index}`}
                    renderItem={({ item }) => (
                        <View style={styles.card}>
                            <View style={styles.cardHeader}>
                                <Text style={styles.cardTitle} numberOfLines={1}>{item.title}</Text>
                            </View>
                            <Text style={styles.cardAuthor}>{item.author}</Text>
                            <View style={styles.cardFooter}>
                                <Text style={styles.statusBadge}>Propozycja</Text>
                                <TouchableOpacity style={styles.addBtn} onPress={() => handleAdd(item)}>
                                    <Text style={styles.addBtnText}>+ Dodaj do listy</Text>
                                </TouchableOpacity>
                            </View>
                        </View>
                    )}
                    ListEmptyComponent={<Text style={styles.empty}>Brak nowych propozycji od innych użytkowników.</Text>}
                />
            )}
        </View>
    );
}

const styles = StyleSheet.create({
    container: { flex: 1, padding: 16, backgroundColor: '#f5f5f5' },
    searchInput: { backgroundColor: '#fff', borderRadius: 8, padding: 12, marginBottom: 12, borderWidth: 1, borderColor: '#ddd', fontSize: 15 },
    card: { backgroundColor: '#fff', borderRadius: 10, padding: 14, marginBottom: 10, elevation: 2, shadowColor: '#000', shadowOpacity: 0.1, shadowRadius: 4, shadowOffset: { width: 0, height: 2 } },
    cardHeader: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
    cardTitle: { fontSize: 17, fontWeight: '600', flex: 1, marginRight: 8 },
    cardAuthor: { fontSize: 14, color: '#666', marginTop: 2 },
    cardFooter: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginTop: 12 },
    statusBadge: { fontSize: 12, color: '#ff9500', backgroundColor: '#fff3e0', paddingHorizontal: 8, paddingVertical: 3, borderRadius: 10, overflow: 'hidden' },
    addBtn: { backgroundColor: '#34c759', paddingHorizontal: 12, paddingVertical: 6, borderRadius: 14 },
    addBtnText: { color: '#fff', fontSize: 13, fontWeight: '600' },
    empty: { textAlign: 'center', marginTop: 40, color: '#999', fontSize: 16 },
});
