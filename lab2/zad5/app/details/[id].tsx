import React, { useEffect, useState } from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { useLocalSearchParams } from 'expo-router';
import { supabase } from '@/utils/supabase';

const Details = () => {
  const { id } = useLocalSearchParams();
  const [post, setPost] = useState(null);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchPost = async () => {
      const { data, error } = await supabase.from('posts')
        .select('*')
        .eq('id', id)
        .single();

      if (error) {
        setError(error);
      } else {
        setPost(data);
      }
    };

    fetchPost();
  }, [id]);

  if (error) {
    return (
      <View style={styles.container}>
        <Text style={styles.errorText}>Post nie został znaleziony.</Text>
      </View>
    );
  }

  if (!post) {
    return (
      <View style={styles.container}>
        <Text>Ładowanie...</Text>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Tytuł: {post.title}</Text>
      <Text style={styles.context}>Treść: {post.context}</Text>
    </View>
  );
};

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
  context: {
    fontSize: 18,
    color: '#666',
  },
  errorText: {
    fontSize: 18,
    color: 'red',
  },
});

export default Details;