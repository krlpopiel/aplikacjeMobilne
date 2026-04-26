import { create } from 'zustand'

type Store = {
    userId: string | null;
    email: string;
    setUser: (userId: string, email: string) => void;
    clearUser: () => void;
}

export const useStore = create<Store>()((set) => ({
    userId: null,
    email: '',
    setUser: (userId: string, email: string) => set({ userId, email }),
    clearUser: () => set({ userId: null, email: '' }),
}))
