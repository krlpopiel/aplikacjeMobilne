import React, { useState, useEffect } from 'react';
import { View, Text, ScrollView, TouchableOpacity, StyleSheet, Alert, FlatList } from 'react-native';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { fetchBookById, fetchOtherReaders, quickCopyBook, Book } from '@/services/books';
import { followUser, isFollowing } from '@/services/follows';
import { useStore } from '@/utils/userStore';

const STATUS_LABELS: Record<string, string> = {
    to_read: 'Do przeczytania',
    reading: 'Czytam',
    finished: 'Przeczytana',
    propozycja: 'Propozycja',
};

export default function BookDetail() {
    const { id } = useLocalSearchParams<{ id: string }>();
    const [book, setBook] = useState<Book | null>(null);
    const [otherReaders, setOtherReaders] = useState<{ user_id: string; rating: number; date_added: string }[]>([]);
    const userId = useStore((s) => s.userId);
    const router = useRouter();

    useEffect(() => {
        if (!id) return;
        fetchBookById(Number(id)).then(setBook);
    }, [id]);

    useEffect(() => {
        if (!book || !userId) return;
        fetchOtherReaders(book.title, book.author, userId).then(setOtherReaders);
    }, [book]);

    const handleFollow = async (targetId: string) => {
        if (!userId) return;
        try {
            const already = await isFollowing(userId, targetId);
            if (already) {
                Alert.alert('Info', 'Już obserwujesz tego użytkownika');
                return;
            }
            await followUser(userId, targetId);
            Alert.alert('Sukces', 'Zaobserwowano użytkownika');
        } catch (e: any) {
            Alert.alert('Błąd', e.message);
        }
    };

    if (!book) return <View style={styles.container}><Text>Ładowanie...</Text></View>;

    const isOwner = book.user_id === userId;

    return (
        <ScrollView style={styles.container} contentContainerStyle={styles.content}>
            <Text style={styles.title}>{book.title}</Text>
            <Text style={styles.author}>{book.author}</Text>

            <View style={styles.infoRow}>
                <Text style={styles.statusBadge}>{STATUS_LABELS[book.status]}</Text>
                <Text style={styles.stars}>{'★'.repeat(book.rating)}{'☆'.repeat(5 - book.rating)}</Text>
            </View>

            {book.notes ? (
                <View style={styles.notesSection}>
                    <Text style={styles.sectionTitle}>Notatki</Text>
                    <Text style={styles.notesText}>{book.notes}</Text>
                </View>
            ) : null}

            <Text style={styles.dateText}>Dodana: {new Date(book.date_added).toLocaleDateString('pl-PL')}</Text>

            {isOwner && (
                <TouchableOpacity
                    style={styles.editBtn}
                    onPress={() => router.push({ pathname: '/dodajKsiazke', params: { editId: book.id.toString() } })}
                >
                    <Text style={styles.editBtnText}>Edytuj</Text>
                </TouchableOpacity>
            )}

            {!isOwner && userId && (
                <TouchableOpacity
                    style={styles.copyBtn}
                    onPress={async () => {
                        await quickCopyBook(book.title, book.author, userId);
                        Alert.alert('Sukces', 'Dodano do Twojej listy jako "Do przeczytania"');
                    }}
                >
                    <Text style={styles.copyBtnText}>Dodaj do mojej listy</Text>
                </TouchableOpacity>
            )}

            {otherReaders.length > 0 && (
                <View style={styles.readersSection}>
                    <Text style={styles.sectionTitle}>Inni czytelnicy ({otherReaders.length})</Text>
                    {otherReaders.map((reader) => (
                        <View key={reader.user_id} style={styles.readerRow}>
                            <View>
                                <TouchableOpacity onPress={() => router.push(`/profil/${reader.user_id}`)}>
                                    <Text style={styles.readerLink}>{reader.user_id.substring(0, 8)}...</Text>
                                </TouchableOpacity>
                                <Text style={styles.readerInfo}>
                                    Ocena: {reader.rating > 0 ? reader.rating : '-'}/5 | Przeczytano: {new Date(reader.date_added).toLocaleDateString('pl-PL')}
                                </Text>
                            </View>
                            <TouchableOpacity style={styles.followSmallBtn} onPress={() => handleFollow(reader.user_id)}>
                                <Text style={styles.followSmallText}>Obserwuj</Text>
                            </TouchableOpacity>
                        </View>
                    ))}
                </View>
            )}
        </ScrollView>
    );
}

const styles = StyleSheet.create({
    container: { flex: 1, backgroundColor: '#fff' },
    content: { padding: 24 },
    title: { fontSize: 24, fontWeight: 'bold' },
    author: { fontSize: 16, color: '#666', marginTop: 4 },
    infoRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginTop: 16 },
    statusBadge: { fontSize: 14, color: '#007AFF', backgroundColor: '#e8f0fe', paddingHorizontal: 12, paddingVertical: 5, borderRadius: 12, overflow: 'hidden' },
    stars: { fontSize: 20, color: '#f5a623' },
    notesSection: { marginTop: 20 },
    sectionTitle: { fontSize: 16, fontWeight: '600', marginBottom: 8 },
    notesText: { fontSize: 15, color: '#444', lineHeight: 22 },
    dateText: { fontSize: 13, color: '#999', marginTop: 16 },
    editBtn: { marginTop: 20, backgroundColor: '#007AFF', borderRadius: 10, padding: 14, alignItems: 'center' },
    editBtnText: { color: '#fff', fontSize: 16, fontWeight: '600' },
    copyBtn: { marginTop: 12, backgroundColor: '#34c759', borderRadius: 10, padding: 14, alignItems: 'center' },
    copyBtnText: { color: '#fff', fontSize: 16, fontWeight: '600' },
    readersSection: { marginTop: 24, borderTopWidth: 1, borderTopColor: '#eee', paddingTop: 16 },
    readerRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', paddingVertical: 8, borderBottomWidth: 1, borderBottomColor: '#f0f0f0' },
    readerLink: { color: '#007AFF', fontSize: 14, fontWeight: '500' },
    readerInfo: { fontSize: 12, color: '#666', marginTop: 2 },
    followSmallBtn: { backgroundColor: '#007AFF', paddingHorizontal: 12, paddingVertical: 6, borderRadius: 14 },
    followSmallText: { color: '#fff', fontSize: 12 },
});
