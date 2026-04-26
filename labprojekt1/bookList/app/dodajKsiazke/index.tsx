import React, { useState, useEffect } from 'react';
import { View, Text, TextInput, TouchableOpacity, StyleSheet, Alert, ScrollView } from 'react-native';
import { useRouter, useLocalSearchParams } from 'expo-router';
import { addBook, fetchBookById, updateBook } from '@/services/books';
import { useStore } from '@/utils/userStore';

const STATUSES = [
    { value: 'to_read', label: 'Do przeczytania' },
    { value: 'reading', label: 'Czytam' },
    { value: 'finished', label: 'Przeczytana' },
    { value: 'propozycja', label: 'Propozycja' },
] as const;

export default function DodajKsiazke() {
    const { editId } = useLocalSearchParams<{ editId?: string }>();
    const isEdit = !!editId;

    const [title, setTitle] = useState('');
    const [author, setAuthor] = useState('');
    const [status, setStatus] = useState<'to_read' | 'reading' | 'finished' | 'propozycja'>('to_read');
    const [rating, setRating] = useState(0);
    const [notes, setNotes] = useState('');
    const [loading, setLoading] = useState(false);

    const userId = useStore((s) => s.userId);
    const router = useRouter();

    useEffect(() => {
        if (isEdit) {
            fetchBookById(Number(editId)).then((book) => {
                setTitle(book.title);
                setAuthor(book.author);
                setStatus(book.status);
                setRating(book.rating);
                setNotes(book.notes || '');
            });
        }
    }, [editId]);

    const handleSave = async () => {
        if (!title.trim() || !author.trim()) {
            Alert.alert('Błąd', 'Tytuł i autor są wymagane');
            return;
        }
        if (!userId) return;

        setLoading(true);
        try {
            // Walidacja po stronie klienta
            const { isDuplicate } = require('@/services/books');
            const isDup = await isDuplicate(userId, title, author, isEdit ? Number(editId) : undefined);
            if (isDup) {
                Alert.alert('Błąd', 'Książka o tym tytule i autorze już istnieje na Twojej liście.');
                setLoading(false);
                return;
            }

            if (isEdit) {
                await updateBook(Number(editId), userId, { title, author, status, rating, notes });
            } else {
                await addBook({ user_id: userId, title, author, status, rating, notes });
            }
            router.back();
        } catch (e: any) {
            Alert.alert('Błąd', e.message);
        }
        setLoading(false);
    };

    return (
        <ScrollView style={styles.container} contentContainerStyle={styles.content}>
            <Text style={styles.header}>{isEdit ? 'Edytuj książkę' : 'Dodaj książkę'}</Text>

            <Text style={styles.label}>Tytuł</Text>
            <TextInput style={styles.input} value={title} onChangeText={setTitle} placeholder="Tytuł książki" />

            <Text style={styles.label}>Autor</Text>
            <TextInput style={styles.input} value={author} onChangeText={setAuthor} placeholder="Autor" />

            <Text style={styles.label}>Status</Text>
            <View style={styles.statusRow}>
                {STATUSES.map((s) => (
                    <TouchableOpacity
                        key={s.value}
                        style={[styles.statusBtn, status === s.value && styles.statusBtnActive]}
                        onPress={() => setStatus(s.value)}
                    >
                        <Text style={status === s.value ? styles.statusTextActive : styles.statusText}>{s.label}</Text>
                    </TouchableOpacity>
                ))}
            </View>

            <Text style={styles.label}>Ocena</Text>
            <View style={styles.ratingRow}>
                {[1, 2, 3, 4, 5].map((star) => (
                    <TouchableOpacity key={star} onPress={() => setRating(star)}>
                        <Text style={[styles.star, star <= rating && styles.starActive]}>★</Text>
                    </TouchableOpacity>
                ))}
            </View>

            <Text style={styles.label}>Notatki</Text>
            <TextInput
                style={[styles.input, styles.notesInput]}
                value={notes}
                onChangeText={setNotes}
                placeholder="Twoje notatki..."
                multiline
                numberOfLines={4}
            />

            <TouchableOpacity style={styles.saveBtn} onPress={handleSave} disabled={loading}>
                <Text style={styles.saveBtnText}>{loading ? 'Zapisywanie...' : 'Zapisz'}</Text>
            </TouchableOpacity>
        </ScrollView>
    );
}

const styles = StyleSheet.create({
    container: { flex: 1, backgroundColor: '#fff' },
    content: { padding: 24 },
    header: { fontSize: 22, fontWeight: 'bold', marginBottom: 20 },
    label: { fontSize: 14, fontWeight: '600', color: '#333', marginBottom: 6, marginTop: 12 },
    input: { borderWidth: 1, borderColor: '#ccc', borderRadius: 8, padding: 12, fontSize: 16 },
    notesInput: { height: 100, textAlignVertical: 'top' },
    statusRow: { flexDirection: 'row', gap: 8 },
    statusBtn: { paddingHorizontal: 14, paddingVertical: 8, borderRadius: 20, backgroundColor: '#e0e0e0' },
    statusBtnActive: { backgroundColor: '#007AFF' },
    statusText: { fontSize: 13, color: '#333' },
    statusTextActive: { fontSize: 13, color: '#fff' },
    ratingRow: { flexDirection: 'row', gap: 8 },
    star: { fontSize: 32, color: '#ccc' },
    starActive: { color: '#f5a623' },
    saveBtn: { marginTop: 24, backgroundColor: '#007AFF', borderRadius: 10, padding: 16, alignItems: 'center' },
    saveBtnText: { color: '#fff', fontSize: 17, fontWeight: '600' },
});
