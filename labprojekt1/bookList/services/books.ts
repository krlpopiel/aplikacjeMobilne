import { supabase } from '@/utils/supabase'

export type Book = {
    id: number;
    user_id: string;
    title: string;
    author: string;
    status: 'to_read' | 'reading' | 'finished' | 'propozycja';
    rating: number;
    notes: string;
    date_added: string;
}

export const fetchBooks = async (userId: string) => {
    const { data, error } = await supabase
        .from('books')
        .select('*')
        .eq('user_id', userId)
        .order('date_added', { ascending: false })

    if (error) throw error
    return data as Book[]
}

export const fetchBookById = async (id: number) => {
    const { data, error } = await supabase
        .from('books')
        .select('*')
        .eq('id', id)
        .single()

    if (error) throw error
    return data as Book
}

export const addBook = async (book: Omit<Book, 'id' | 'date_added'>) => {
    const { data, error } = await supabase
        .from('books')
        .insert([book])
        .select()
        .single()

    if (error) throw error
    return data as Book
}

export const updateBook = async (id: number, userId: string, updates: Partial<Book>) => {
    const { data, error } = await supabase
        .from('books')
        .update({ ...updates, user_id: userId })
        .eq('id', id)
        .eq('user_id', userId)
        .select()
        .single()

    if (error) throw error
    return data as Book
}

export const deleteBook = async (id: number) => {
    const { error } = await supabase
        .from('books')
        .delete()
        .eq('id', id)

    if (error) throw error
}

export const fetchOtherReaders = async (title: string, author: string, currentUserId: string) => {
    const { data, error } = await supabase
        .from('books')
        .select('user_id, rating, date_added')
        .eq('title', title)
        .eq('author', author)
        .eq('status', 'finished')
        .neq('user_id', currentUserId)

    if (error) throw error
    return data as { user_id: string; rating: number; date_added: string }[]
}

export const fetchUserFinishedBooks = async (userId: string) => {
    const { data, error } = await supabase
        .from('books')
        .select('*')
        .eq('user_id', userId)
        .eq('status', 'finished')
        .order('date_added', { ascending: false })

    if (error) throw error
    return data as Book[]
}

export const quickCopyBook = async (title: string, author: string, userId: string) => {
    // Protection before insert
    const isDup = await isDuplicate(userId, title, author);
    if (isDup) throw new Error("Już masz tę książkę na swojej liście.");

    const { data, error } = await supabase
        .from('books')
        .insert([{ title, author, status: 'to_read', user_id: userId, rating: 0, notes: '' }])
        .select()
        .single()

    if (error) throw error
    return data as Book
}

export const isDuplicate = async (userId: string, title: string, author: string, excludeId?: number) => {
    let query = supabase
        .from('books')
        .select('id')
        .eq('user_id', userId)
        .ilike('title', title)
        .ilike('author', author);

    if (excludeId) {
        query = query.neq('id', excludeId);
    }

    const { data, error } = await query;
    if (error) throw error;
    return data && data.length > 0;
};

export const fetchDiscoverBooks = async (userId: string) => {
    const { data: othersBooks, error: othersError } = await supabase
        .from('books')
        .select('*')
        .neq('user_id', userId)
        .order('date_added', { ascending: false })
        .limit(100);

    if (othersError) throw othersError;

    const { data: myBooks, error: myError } = await supabase
        .from('books')
        .select('title, author')
        .eq('user_id', userId);

    if (myError) throw myError;

    const myBooksSet = new Set((myBooks || []).map(b => `${b.title.toLowerCase()}|${b.author.toLowerCase()}`));
    const uniqueProposals: Book[] = [];
    const seenSet = new Set<string>();

    for (const book of othersBooks as Book[]) {
        const key = `${book.title.toLowerCase()}|${book.author.toLowerCase()}`;
        if (!myBooksSet.has(key) && !seenSet.has(key)) {
            uniqueProposals.push(book);
            seenSet.add(key);
        }
    }

    return uniqueProposals;
};
