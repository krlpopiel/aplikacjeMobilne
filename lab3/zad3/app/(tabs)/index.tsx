import { StyleSheet, Text, View, TouchableOpacity } from 'react-native';
import { create } from 'zustand';

interface ThemeState {
  darkMode: boolean;
  toggleDarkMode: () => void;
}

const useStore = create<ThemeState>((set) => ({
  darkMode: false,
  toggleDarkMode: () => set((state) => ({ darkMode: !state.darkMode })),
}));

export default function HomeScreen() {
  const darkMode = useStore((state) => state.darkMode);
  const toggleDarkMode = useStore((state) => state.toggleDarkMode);

  return (
    <View style={[styles.container, darkMode ? styles.darkContainer : styles.lightContainer]}>
      <Text style={[styles.title, darkMode ? styles.darkText : styles.lightText]}>
        Zadanie 3: Zustand
      </Text>

      <View style={[styles.statusCard, darkMode ? styles.darkCard : styles.lightCard]}>
        <Text style={[styles.statusText, darkMode ? styles.darkText : styles.lightText]}>
          {darkMode ? 'Tryb ciemny włączony' : 'Tryb jasny włączony'}
        </Text>
      </View>

      <TouchableOpacity 
        style={[styles.button, darkMode ? styles.darkButton : styles.lightButton]} 
        onPress={toggleDarkMode}
      >
        <Text style={styles.buttonText}>
          Przełącz motyw
        </Text>
      </TouchableOpacity>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 20,
    transition: 'background-color 0.3s',
  },
  lightContainer: {
    backgroundColor: '#ffffff',
  },
  darkContainer: {
    backgroundColor: '#1a1a1a',
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    marginBottom: 40,
  },
  lightText: {
    color: '#333333',
  },
  darkText: {
    color: '#ffffff',
  },
  statusCard: {
    padding: 30,
    borderRadius: 15,
    marginBottom: 40,
    width: '100%',
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 3.84,
    elevation: 5,
  },
  lightCard: {
    backgroundColor: '#f5f5f5',
  },
  darkCard: {
    backgroundColor: '#2a2a2a',
  },
  statusText: {
    fontSize: 22,
    fontWeight: '600',
  },
  button: {
    paddingHorizontal: 30,
    paddingVertical: 15,
    borderRadius: 25,
    width: '80%',
    alignItems: 'center',
  },
  lightButton: {
    backgroundColor: '#007AFF',
  },
  darkButton: {
    backgroundColor: '#0A84FF',
  },
  buttonText: {
    color: '#ffffff',
    fontSize: 18,
    fontWeight: 'bold',
  }
});
