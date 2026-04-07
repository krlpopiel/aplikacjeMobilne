import React, { useState, useCallback } from 'react';
import { View, Text, FlatList, TextInput, TouchableOpacity, StyleSheet, Alert } from 'react-native';
import { useRouter, useFocusEffect } from 'expo-router';
import { fetchBooks, deleteBook, Book } from '@/services/books';
import { useStore } from '@/utils/userStore';

const STATUS_LABELS: Record<string, string> = {
    to_read: 'Do przeczytania',
    reading: 'Czytam',
    finished: 'Przeczytana',
    propozycja: 'Propozycja',
};

export default function Ksiazki() {
    const [books, setBooks] = useState<Book[]>([]);
    const [search, setSearch] = useState('');
    const [sortBy, setSortBy] = useState<'date' | 'status'>('date');
    const userId = useStore((s) => s.userId);
    const router = useRouter();

    const loadBooks = async () => {
        if (!userId) return;
        try {
            const data = await fetchBooks(userId);
            setBooks(data);
        } catch (e: any) {
            console.error(e.message);
        }
    };

    useFocusEffect(
        useCallback(() => {
            loadBooks();
        }, [userId])
    );

    const currentYear = new Date().getFullYear();
    const finishedThisYear = books.filter(
        (b) => b.status === 'finished' && new Date(b.date_added).getFullYear() === currentYear
    ).length;

    const filtered = books.filter(
        (b) =>
            (b.title?.toLowerCase() || '').includes(search.toLowerCase()) ||
            (b.author?.toLowerCase() || '').includes(search.toLowerCase())
    );

    const sorted = [...filtered].sort((a, b) => {
        if (sortBy === 'status') {
            const statusDiff = a.status.localeCompare(b.status);
            if (statusDiff !== 0) return statusDiff;
            return new Date(b.date_added).getTime() - new Date(a.date_added).getTime();
        }
        return new Date(b.date_added).getTime() - new Date(a.date_added).getTime();
    });

    const handleDelete = (id: number) => {
        Alert.alert('Usuń książkę', 'Czy na pewno chcesz usunąć tę książkę?', [
            { text: 'Anuluj' },
            {
                text: 'Usuń', style: 'destructive', onPress: async () => {
                    await deleteBook(id);
                    loadBooks();
                }
            },
        ]);
    };

    return (
        <View style={styles.container}>
            <Text style={styles.yearCounter}>
                Przeczytane w {currentYear}: {finishedThisYear}
            </Text>

            <TextInput
                style={styles.searchInput}
                placeholder="Szukaj po tytule lub autorze..."
                value={search}
                onChangeText={setSearch}
            />

            <View style={styles.sortRow}>
                <Text style={styles.sortLabel}>Sortuj:</Text>
                <TouchableOpacity onPress={() => setSortBy('date')} style={[styles.sortBtn, sortBy === 'date' && styles.sortBtnActive]}>
                    <Text style={sortBy === 'date' ? styles.sortTextActive : styles.sortText}>Data</Text>
                </TouchableOpacity>
                <TouchableOpacity onPress={() => setSortBy('status')} style={[styles.sortBtn, sortBy === 'status' && styles.sortBtnActive]}>
                    <Text style={sortBy === 'status' ? styles.sortTextActive : styles.sortText}>Status</Text>
                </TouchableOpacity>
            </View>

            <FlatList
                data={sorted}
                keyExtractor={(item) => item.id.toString()}
                renderItem={({ item }) => (
                    <TouchableOpacity style={styles.card} onPress={() => router.push(`/ksiazki/${item.id}`)}>
                        <View style={styles.cardHeader}>
                            <Text style={styles.cardTitle} numberOfLines={1}>{item.title}</Text>
                            <TouchableOpacity onPress={() => handleDelete(item.id)}>
                                <Text style={styles.deleteBtn}>✕</Text>
                            </TouchableOpacity>
                        </View>
                        <Text style={styles.cardAuthor}>{item.author}</Text>
                        <View style={styles.cardFooter}>
                            <Text style={styles.statusBadge}>{STATUS_LABELS[item.status]}</Text>
                            <Text style={styles.stars}>{'★'.repeat(item.rating)}{'☆'.repeat(5 - item.rating)}</Text>
                        </View>
                    </TouchableOpacity>
                )}
                ListEmptyComponent={<Text style={styles.empty}>Brak książek. Dodaj pierwszą!</Text>}
            />

            <TouchableOpacity style={styles.fab} onPress={() => router.push('/dodajKsiazke')}>
                <Text style={styles.fabText}>+</Text>
            </TouchableOpacity>
        </View>
    );
}

const styles = StyleSheet.create({
    container: { flex: 1, padding: 16, backgroundColor: '#f5f5f5' },
    yearCounter: { fontSize: 14, color: '#007AFF', marginBottom: 12, fontWeight: '600' },
    searchInput: { backgroundColor: '#fff', borderRadius: 8, padding: 12, marginBottom: 8, borderWidth: 1, borderColor: '#ddd', fontSize: 15 },
    sortRow: { flexDirection: 'row', alignItems: 'center', marginBottom: 12 },
    sortLabel: { fontSize: 14, marginRight: 8, color: '#666' },
    sortBtn: { paddingHorizontal: 12, paddingVertical: 6, borderRadius: 16, backgroundColor: '#e0e0e0', marginRight: 8 },
    sortBtnActive: { backgroundColor: '#007AFF' },
    sortText: { fontSize: 13, color: '#333' },
    sortTextActive: { fontSize: 13, color: '#fff' },
    card: { backgroundColor: '#fff', borderRadius: 10, padding: 14, marginBottom: 10, elevation: 2, shadowColor: '#000', shadowOpacity: 0.1, shadowRadius: 4, shadowOffset: { width: 0, height: 2 } },
    cardHeader: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
    cardTitle: { fontSize: 17, fontWeight: '600', flex: 1, marginRight: 8 },
    deleteBtn: { fontSize: 18, color: '#ff3b30', padding: 4 },
    cardAuthor: { fontSize: 14, color: '#666', marginTop: 2 },
    cardFooter: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginTop: 8 },
    statusBadge: { fontSize: 12, color: '#007AFF', backgroundColor: '#e8f0fe', paddingHorizontal: 8, paddingVertical: 3, borderRadius: 10, overflow: 'hidden' },
    stars: { fontSize: 16, color: '#f5a623' },
    empty: { textAlign: 'center', marginTop: 40, color: '#999', fontSize: 16 },
    fab: { position: 'absolute', right: 20, bottom: 30, width: 56, height: 56, borderRadius: 28, backgroundColor: '#007AFF', justifyContent: 'center', alignItems: 'center', elevation: 4 },
    fabText: { fontSize: 28, color: '#fff', lineHeight: 30 },
});
