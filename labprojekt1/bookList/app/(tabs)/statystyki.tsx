import React, { useState, useCallback } from 'react';
import { View, Text, ScrollView, StyleSheet } from 'react-native';
import { useFocusEffect } from 'expo-router';
import { fetchBooks, Book } from '@/services/books';
import { useStore } from '@/utils/userStore';

export default function Statystyki() {
    const [books, setBooks] = useState<Book[]>([]);
    const userId = useStore((s) => s.userId);

    useFocusEffect(
        useCallback(() => {
            if (!userId) return;
            fetchBooks(userId).then(setBooks).catch(console.error);
        }, [userId])
    );

    const total = books.length;
    const finished = books.filter((b) => b.status === 'finished');
    const reading = books.filter((b) => b.status === 'reading');
    const toRead = books.filter((b) => b.status === 'to_read');

    const currentYear = new Date().getFullYear();
    const finishedThisYear = finished.filter(
        (b) => new Date(b.date_added).getFullYear() === currentYear
    );

    const ratedFinished = finished.filter(b => b.rating > 0);
    const avgRating = ratedFinished.length > 0
        ? (ratedFinished.reduce((sum, b) => sum + b.rating, 0) / ratedFinished.length).toFixed(1)
        : '–';

    const bestBook = ratedFinished.length > 0
        ? ratedFinished.reduce((best, b) => (b.rating > best.rating ? b : best), ratedFinished[0])
        : null;

    return (
        <ScrollView style={styles.container} contentContainerStyle={styles.content}>
            <View style={styles.grid}>
                <View style={styles.statCard}>
                    <Text style={styles.statNumber}>{total}</Text>
                    <Text style={styles.statLabel}>Wszystkie książki</Text>
                </View>
                <View style={styles.statCard}>
                    <Text style={styles.statNumber}>{finished.length}</Text>
                    <Text style={styles.statLabel}>Przeczytane</Text>
                </View>
                <View style={styles.statCard}>
                    <Text style={styles.statNumber}>{finishedThisYear.length}</Text>
                    <Text style={styles.statLabel}>Przeczytane w {currentYear}</Text>
                </View>
                <View style={styles.statCard}>
                    <Text style={styles.statNumber}>{avgRating}</Text>
                    <Text style={styles.statLabel}>Średnia ocena</Text>
                </View>
            </View>

            <Text style={styles.sectionTitle}>Podział wg statusu</Text>
            <View style={styles.statusList}>
                <View style={styles.statusRow}>
                    <View style={[styles.dot, { backgroundColor: '#ff9500' }]} />
                    <Text style={styles.statusText}>Do przeczytania: {toRead.length}</Text>
                </View>
                <View style={styles.statusRow}>
                    <View style={[styles.dot, { backgroundColor: '#007AFF' }]} />
                    <Text style={styles.statusText}>Czytam: {reading.length}</Text>
                </View>
                <View style={styles.statusRow}>
                    <View style={[styles.dot, { backgroundColor: '#34c759' }]} />
                    <Text style={styles.statusText}>Przeczytane: {finished.length}</Text>
                </View>
            </View>

            {bestBook && (
                <View style={styles.bestSection}>
                    <Text style={styles.sectionTitle}>Najlepsza książka</Text>
                    <View style={styles.bestCard}>
                        <Text style={styles.bestTitle}>{bestBook.title}</Text>
                        <Text style={styles.bestAuthor}>{bestBook.author}</Text>
                        <Text style={styles.bestStars}>{'★'.repeat(bestBook.rating)}{'☆'.repeat(5 - bestBook.rating)}</Text>
                    </View>
                </View>
            )}
        </ScrollView>
    );
}

const styles = StyleSheet.create({
    container: { flex: 1, backgroundColor: '#f5f5f5' },
    content: { padding: 16 },
    grid: { flexDirection: 'row', flexWrap: 'wrap', gap: 10, marginBottom: 20 },
    statCard: { width: '47%', backgroundColor: '#fff', borderRadius: 12, padding: 16, alignItems: 'center', elevation: 2, shadowColor: '#000', shadowOpacity: 0.08, shadowRadius: 4, shadowOffset: { width: 0, height: 2 } },
    statNumber: { fontSize: 28, fontWeight: 'bold', color: '#007AFF' },
    statLabel: { fontSize: 12, color: '#666', marginTop: 4, textAlign: 'center' },
    sectionTitle: { fontSize: 18, fontWeight: '600', marginBottom: 10, marginTop: 8 },
    statusList: { backgroundColor: '#fff', borderRadius: 12, padding: 16, marginBottom: 16 },
    statusRow: { flexDirection: 'row', alignItems: 'center', marginBottom: 10 },
    dot: { width: 12, height: 12, borderRadius: 6, marginRight: 10 },
    statusText: { fontSize: 15, color: '#333' },
    bestSection: { marginTop: 4 },
    bestCard: { backgroundColor: '#fff', borderRadius: 12, padding: 16, elevation: 2, shadowColor: '#000', shadowOpacity: 0.08, shadowRadius: 4, shadowOffset: { width: 0, height: 2 } },
    bestTitle: { fontSize: 18, fontWeight: '600' },
    bestAuthor: { fontSize: 14, color: '#666', marginTop: 2 },
    bestStars: { fontSize: 20, color: '#f5a623', marginTop: 8 },
});
