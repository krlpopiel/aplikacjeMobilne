import React from 'react';
import { View, Button, StyleSheet } from 'react-native';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withTiming,
} from 'react-native-reanimated';

export default function Page() {
  const visible = useSharedValue(false);
  const scale = useSharedValue(0);
  const opacity = useSharedValue(0);

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: withTiming(scale.value, { duration: 500 }) }],
    opacity: withTiming(opacity.value, { duration: 500 }),
  }));

  const toggle = () => {
    visible.value = !visible.value;
    scale.value = visible.value ? 1 : 0;
    opacity.value = visible.value ? 1 : 0;
  };

  return (
    <View style={styles.container}>
      <Animated.View style={[styles.box, animatedStyle]} />
      <Button title={visible.value ? "Ukryj" : "Pokaż"} onPress={toggle} />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#fff',
  },
  box: {
    width: 120,
    height: 120,
    backgroundColor: 'purple',
    marginBottom: 20,
    borderRadius: 15,
  },
});
