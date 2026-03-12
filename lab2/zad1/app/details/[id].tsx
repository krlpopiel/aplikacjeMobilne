import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { cities } from '@/db/cities';
import { useLocalSearchParams } from 'expo-router';

function Details() {
  const { id } = useLocalSearchParams();
  const city = cities.find((c) => c.id === id);

  if (!city) {
    return (
      <View style={styles.container}>
        <Text style={styles.errorText}>Miasto nie zostało znalezione.</Text>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <Text style={styles.title}>{city.name}</Text>
      <Text style={styles.population}>Populacja: {city.population}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
    backgroundColor: '#f5f5f5',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 10,
    color: '#333',
  },
  population: {
    fontSize: 18,
    color: '#666',
  },
  errorText: {
    fontSize: 18,
    color: 'red',
  },
});

export default Details;