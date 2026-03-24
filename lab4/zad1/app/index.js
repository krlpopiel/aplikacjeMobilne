import React from 'react';
import { View, Button, StyleSheet } from 'react-native';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withTiming,
} from 'react-native-reanimated';

export default function Page() {
  const offset = useSharedValue(0); 

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ translateX: withTiming(offset.value, { duration: 500 }) }],
  }));

  const handlePress = () => {
    offset.value = offset.value === 0 ? 150 : 0; 
  };

  return (
    <View style={styles.container}>
      <Animated.View style={[styles.box, animatedStyle]} />
      <Button title="Przesuń" onPress={handlePress} />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#f5f5f5',
  },
  box: {
    width: 100,
    height: 100,
    backgroundColor: 'dodgerblue',
    marginBottom: 20,
    borderRadius: 8,
  },
});
