import React, { useState } from 'react';
import { StyleSheet, View, Text, ScrollView, TouchableOpacity, Dimensions } from 'react-native';
import Animated, { 
  useSharedValue, 
  useAnimatedStyle, 
  withTiming, 
  withSpring, 
  withRepeat, 
  interpolate, 
  interpolateColor,
  Extrapolation
} from 'react-native-reanimated';
import { PanGestureHandler } from 'react-native-gesture-handler';

const { height: SCREEN_HEIGHT, width: SCREEN_WIDTH } = Dimensions.get('window');

// 1. Modified Flip Card: Scale down during flip
const FlipCard = () => {
  const isFlipped = useSharedValue(false);
  
  const animatedStyle = useAnimatedStyle(() => {
    const rotation = withTiming(isFlipped.value ? 180 : 0, { duration: 600 });
    const scale = withTiming(isFlipped.value ? 0.8 : 1, { duration: 300 });
    
    return {
      transform: [
        { perspective: 1000 },
        { rotateY: `${rotation}deg` },
        { scale }
      ],
    };
  });

  return (
    <View style={styles.exampleContainer}>
      <Text style={styles.title}>1. Flip Card (+ Scale)</Text>
      <TouchableOpacity onPress={() => (isFlipped.value = !isFlipped.value)}>
        <Animated.View style={[styles.card, animatedStyle, styles.cardFront]}>
          <Text style={styles.cardText}>{isFlipped.value ? "TYŁ" : "PRZÓD"}</Text>
        </Animated.View>
      </TouchableOpacity>
    </View>
  );
};

// 2. Modified Slider: Color change from blue to red
const ColorSlider = () => {
  const translateX = useSharedValue(0);
  const SLIDER_WIDTH = SCREEN_WIDTH - 80;

  const onGestureEvent = (event) => {
    let newX = event.nativeEvent.translationX;
    if (newX < 0) newX = 0;
    if (newX > SLIDER_WIDTH) newX = SLIDER_WIDTH;
    translateX.value = newX;
  };

  const animatedHandleStyle = useAnimatedStyle(() => ({
    transform: [{ translateX: translateX.value }],
    backgroundColor: interpolateColor(
      translateX.value,
      [0, SLIDER_WIDTH],
      ['#3498db', '#e74c3c']
    ),
  }));

  const animatedProgressStyle = useAnimatedStyle(() => ({
    width: translateX.value,
    backgroundColor: interpolateColor(
      translateX.value,
      [0, SLIDER_WIDTH],
      ['#3498db', '#e74c3c']
    ),
  }));

  return (
    <View style={styles.exampleContainer}>
      <Text style={styles.title}>2. Slider (+ Color Change)</Text>
      <View style={styles.sliderTrack}>
        <Animated.View style={[styles.sliderProgress, animatedProgressStyle]} />
        <PanGestureHandler onGestureEvent={onGestureEvent}>
          <Animated.View style={[styles.sliderHandle, animatedHandleStyle]} />
        </PanGestureHandler>
      </View>
    </View>
  );
};

// 3. Modified Marquee: Text with vertical bounce effect
const BouncingMarquee = () => {
  const offset = useSharedValue(0);
  const bounce = useSharedValue(0);

  React.useEffect(() => {
    offset.value = withRepeat(withTiming(-200, { duration: 3000 }), -1, true);
    bounce.value = withRepeat(withSpring(20, { damping: 2 }), -1, true);
  }, []);

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [
      { translateX: offset.value },
      { translateY: bounce.value }
    ],
  }));

  return (
    <View style={styles.exampleContainer}>
      <Text style={styles.title}>3. Marquee (+ Bounce)</Text>
      <View style={styles.marqueeContainer}>
        <Animated.Text style={[styles.marqueeText, animatedStyle]}>
          Oto przewijający się i skaczący tekst! 🚀🚀🚀
        </Animated.Text>
      </View>
    </View>
  );
};

// 4. Modified Bottom Sheet: Background overlay dims
const BottomSheet = () => {
  const translateY = useSharedValue(0);
  const MAX_UP = -200;

  const onGestureEvent = (event) => {
    let newY = event.nativeEvent.translationY;
    if (newY > 0) newY = 0;
    if (newY < MAX_UP) newY = MAX_UP;
    translateY.value = newY;
  };

  const sheetStyle = useAnimatedStyle(() => ({
    transform: [{ translateY: withSpring(translateY.value) }],
  }));

  const overlayStyle = useAnimatedStyle(() => ({
    opacity: interpolate(
      translateY.value,
      [0, MAX_UP],
      [0, 0.6],
      Extrapolation.CLAMP
    ),
  }));

  return (
    <View style={styles.exampleContainer}>
      <Text style={styles.title}>4. Bottom Sheet (+ Overlay Dim)</Text>
      <View style={styles.sheetBoundary}>
        <Animated.View style={[styles.overlay, overlayStyle]} />
        <PanGestureHandler onGestureEvent={onGestureEvent}>
          <Animated.View style={[styles.sheet, sheetStyle]}>
            <View style={styles.sheetHandle} />
            <Text style={styles.sheetText}>Przesuń mnie w górę!</Text>
          </Animated.View>
        </PanGestureHandler>
      </View>
    </View>
  );
};

export default function App() {
  return (
    <GestureHandlerRootView style={{ flex: 1 }}>
      <ScrollView style={styles.container}>
        <Text style={styles.header}>Lab 4: Wyzwania (Zad 4)</Text>
        <FlipCard />
        <ColorSlider />
        <BouncingMarquee />
        <BottomSheet />
        <View style={{ height: 50 }} />
      </ScrollView>
    </GestureHandlerRootView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f0f0f0',
    paddingTop: 50,
  },
  header: {
    fontSize: 24,
    fontWeight: 'bold',
    textAlign: 'center',
    marginBottom: 20,
  },
  exampleContainer: {
    backgroundColor: 'white',
    margin: 10,
    padding: 20,
    borderRadius: 15,
    alignItems: 'center',
    minHeight: 200,
    overflow: 'hidden'
  },
  title: {
    fontSize: 18,
    fontWeight: '600',
    marginBottom: 20,
    color: '#333',
  },
  // Flip Card
  card: {
    width: 150,
    height: 100,
    borderRadius: 10,
    justifyContent: 'center',
    alignItems: 'center',
    backfaceVisibility: 'hidden',
  },
  cardFront: {
    backgroundColor: '#3498db',
  },
  cardText: {
    color: 'white',
    fontSize: 18,
    fontWeight: 'bold',
  },
  // Slider
  sliderTrack: {
    width: SCREEN_WIDTH - 80,
    height: 10,
    backgroundColor: '#ddd',
    borderRadius: 5,
    justifyContent: 'center',
  },
  sliderProgress: {
    height: 10,
    borderRadius: 5,
    position: 'absolute',
  },
  sliderHandle: {
    width: 30,
    height: 30,
    borderRadius: 15,
    backgroundColor: '#3498db',
    position: 'absolute',
    borderWidth: 2,
    borderColor: 'white',
  },
  // Marquee
  marqueeContainer: {
    width: '100%',
    height: 60,
    backgroundColor: '#2c3e50',
    justifyContent: 'center',
    borderRadius: 10,
    overflow: 'hidden'
  },
  marqueeText: {
    color: '#ecf0f1',
    fontSize: 18,
    width: 400,
  },
  // Bottom Sheet
  sheetBoundary: {
    width: '100%',
    height: 250,
    backgroundColor: '#eee',
    borderRadius: 10,
    overflow: 'hidden',
    justifyContent: 'flex-end'
  },
  overlay: {
    ...StyleSheet.absoluteFillObject,
    backgroundColor: 'black',
  },
  sheet: {
    height: 300,
    width: '100%',
    backgroundColor: 'white',
    borderTopLeftRadius: 20,
    borderTopRightRadius: 20,
    padding: 20,
    alignItems: 'center',
    position: 'absolute',
    bottom: -240,
  },
  sheetHandle: {
    width: 40,
    height: 5,
    backgroundColor: '#ccc',
    borderRadius: 3,
    marginBottom: 10,
  },
  sheetText: {
    fontSize: 16,
    color: '#666'
  }
});
