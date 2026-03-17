import { useState } from 'react';
import { StyleSheet, Text, View, TextInput, TouchableOpacity } from 'react-native';
import { create } from 'zustand';

interface UserState {
  username: string;
  setUsername: (name: string) => void;
}

const useStore = create<UserState>((set) => ({
  username: '',
  setUsername: (name) => set({ username: name }),
}));

export default function HomeScreen() {
  const [inputValue, setInputValue] = useState('');
  const username = useStore((state) => state.username);
  const setUsername = useStore((state) => state.setUsername);

  const handleSave = () => {
    setUsername(inputValue);
    setInputValue('');
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Zadanie 4: Zustand Username</Text>
      
      <View style={styles.inputContainer}>
        <Text style={styles.label}>Wpisz swoje imię:</Text>
        <TextInput
          style={styles.input}
          value={inputValue}
          onChangeText={setInputValue}
          placeholder="np. Jan"
        />
        <TouchableOpacity style={styles.button} onPress={handleSave}>
          <Text style={styles.buttonText}>Zapisz</Text>
        </TouchableOpacity>
      </View>

      <View style={styles.displayContainer}>
        <Text style={styles.displayLabel}>Zapisane imię ze store'a:</Text>
        {username ? (
          <Text style={styles.displayName}>{username}</Text>
        ) : (
          <Text style={styles.displayEmpty}>Brak zapisanego imienia</Text>
        )}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
    padding: 20,
    justifyContent: 'center',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 40,
    textAlign: 'center',
    color: '#333'
  },
  inputContainer: {
    backgroundColor: '#fff',
    padding: 20,
    borderRadius: 15,
    marginBottom: 30,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 3.84,
    elevation: 3,
  },
  label: {
    fontSize: 16,
    color: '#666',
    marginBottom: 10,
    fontWeight: '500'
  },
  input: {
    borderWidth: 1,
    borderColor: '#ddd',
    padding: 15,
    borderRadius: 10,
    fontSize: 16,
    backgroundColor: '#f9f9f9',
    marginBottom: 15,
  },
  button: {
    backgroundColor: '#007AFF',
    padding: 15,
    borderRadius: 10,
    alignItems: 'center',
  },
  buttonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: 'bold',
  },
  displayContainer: {
    backgroundColor: '#fff',
    padding: 25,
    borderRadius: 15,
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 3.84,
    elevation: 3,
    borderWidth: 1,
    borderColor: '#e0e0e0'
  },
  displayLabel: {
    fontSize: 16,
    color: '#666',
    marginBottom: 10,
  },
  displayName: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#333',
  },
  displayEmpty: {
    fontSize: 16,
    fontStyle: 'italic',
    color: '#aaa',
  }
});
