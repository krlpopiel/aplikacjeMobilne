import { data } from "@/data/fruits";
import { useState } from "react";
import { Text, View, Button, StyleSheet, FlatList } from "react-native";

export default function Index() {

  return (
    <View style={styles.mainContainer}>
    <View
      style={styles.container}
    >
      <Text>Zadanie trzecie</Text>
      <Text>Nasze owoce</Text>
       </View>
    <View
      style={styles.listContainer}
    >
      <FlatList
        data = {data}
        keyExtractor={(item) => item.id.toString()}
        renderItem={({ item }) => (
          <View style={styles.listItem}>
            <Text>{item.name}</Text>
            <Text>Price: {item.price}</Text>
            <Text>Quantity: {item.quant}</Text>
          </View>
        )}
      />    
      
    </View>
    </View>
  );
}

const styles = StyleSheet.create({
  mainContainer: {
    flex: 1,
  },
  container: {
    flex: 1,
    backgroundColor: "#f5f5f5",
    alignItems: "center",
    justifyContent: "center",
    paddingTop: 20,
  },
  listContainer: {
    flex: 4,
    backgroundColor: "#f5f5f5",
    marginTop: 20,
  },
  listItem: {
    padding: 15,
    marginVertical: 8,
    marginHorizontal: 12,
    backgroundColor: "#fff",
    borderRadius: 8,
    borderBottomWidth: 1,
    borderBottomColor: "#e0e0e0",
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  }
});