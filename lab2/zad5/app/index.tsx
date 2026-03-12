import 'react-native-url-polyfill/auto';
import { View, Text, FlatList, TouchableOpacity, StyleSheet } from 'react-native';
import React, { useState } from "react";
import { useRouter } from "expo-router";
import { supabase } from '@/utils/supabase';


export default function Index() {
  const router = useRouter();

  const [posts, setPosts] = useState<any[]>([]);

  async function fetchPosts() {
    const { data, error } = await supabase
      .from('posts')
      .select('*')
      .order('created_at', { ascending: false });

    if (error) {
      console.error('Error fetching posts:', error);
    } else {
      setPosts(data);
    }
  }

  React.useEffect(() => {
    fetchPosts();
  }, []);



  const colors = ['#fecaca', '#bfdbfe', '#bbf7d0', '#fef08a', '#ddd6fe', '#fbcfe8', '#c7d2fe', '#99f6e4'];

  const renderPostItem = ({ item, index }: { item: any; index: any }) => {
    const backgroundColor = colors[index % colors.length];

    return (
      <TouchableOpacity 
        style={[styles.card, { backgroundColor }]} 
        onPress={() => router.push(`/details/${item.id}`)}
        activeOpacity={0.7}
      >
        <Text style={styles.PostText}>{item.title}</Text>
      </TouchableOpacity>
    );
  };


  return (
    <View style={styles.container}>
      <Text style={styles.title}>Posty</Text>
      <FlatList
        data={posts}
        keyExtractor={(item) => item.id.toString()}
        renderItem={renderPostItem}
        contentContainerStyle={styles.listPadding}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f3f4f6',
    padding: 16,
  },
  title: {
    fontSize: 26,
    fontWeight: 'bold',
    textAlign: 'center',
    marginBottom: 20,
    marginTop: 40,
    color: '#111827',
  },
  card: {
    padding: 24,
    marginVertical: 8,
    borderRadius: 16,
    // Cień dla Android
    elevation: 4,
    // Cień dla iOS
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.15,
    shadowRadius: 4,
  },
  PostText: {
    fontSize: 20,
    fontWeight: '700',
    color: '#374151',
    textAlign: 'center',
  },
  listPadding: {
    paddingBottom: 40,
  },
});