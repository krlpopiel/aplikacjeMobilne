import React, { useState } from 'react';
import { View, Button, StyleSheet } from 'react-native';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
} from 'react-native-reanimated';

export default function App() {
  const [active, setActive] = useState(false);
  const rotation = useSharedValue(0);
  const translateY = useSharedValue(0);

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [
      { rotateY: withSpring(`${rotation.value}deg`) },
      { translateY: withSpring(translateY.value) },
    ],
  }));

  const handlePress = () => {
    setActive(!active);
    rotation.value = active ? 0 : 180;
    translateY.value = active ? 0 : -100;
  };

  return (
    <View style={styles.container}>
      <Animated.View style={[styles.box, animatedStyle]} />
      <Button title="Obróć i Przesuń" onPress={handlePress} />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#eef2f3',
  },
  box: {
    width: 100,
    height: 100,
    backgroundColor: 'tomato',
    marginBottom: 50,
    borderRadius: 10,
    elevation: 5,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.25,
    shadowRadius: 3.84,
  },
});
