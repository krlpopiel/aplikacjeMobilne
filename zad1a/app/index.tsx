import { useState } from "react";
import { Text, View, Button, StyleSheet } from "react-native";

export default function Index() {

  const [counter, setCounter] = useState(0);

  return (
    <div>
    <View
      style={styles.container}
    >
      <Text>Zadanie drugie</Text>
       </View>
    <View
      style={styles.btns}
    >
      <Button title="Zmniejsz" onPress={() => setCounter(counter - 1)} />
      <br></br>
      <Button title="Zwiększ" onPress={() => setCounter(counter + 1)} />
      <br></br>      
      
    </View>
    <View style={styles.container}>
      <Text>Counter: {counter}</Text>
    </View>
    </div>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#fff",
    alignItems: "center",
    justifyContent: "center",
  },
  btns:{
    flexDirection: "row",
    justifyContent: "center",
    width: "100%",
  }
});