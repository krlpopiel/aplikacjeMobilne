import { useState } from 'react';
import { StyleSheet, Text, View, TextInput, TouchableOpacity } from 'react-native';

export default function HomeScreen() {
  const [billAmount, setBillAmount] = useState<string>('');
  const [tipPercentage, setTipPercentage] = useState<number>(15);

  const calculateTip = () => {
    const bill = parseFloat(billAmount);
    if (isNaN(bill) || bill <= 0) return { tip: 0, total: 0 };
    
    const tip = bill * (tipPercentage / 100);
    const total = bill + tip;
    
    return { tip, total };
  };

  const { tip, total } = calculateTip();

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Kalkulator Napiwków</Text>
      
      <View style={styles.inputContainer}>
        <Text style={styles.label}>Kwota rachunku (zł):</Text>
        <TextInput
          style={styles.input}
          keyboardType="numeric"
          value={billAmount}
          onChangeText={setBillAmount}
          placeholder="np. 120.50"
        />
      </View>

      <Text style={styles.label}>Napiwek (%):</Text>
      <View style={styles.tipButtonsContainer}>
        {[10, 15, 20].map((percentage) => (
          <TouchableOpacity
            key={percentage}
            style={[
              styles.tipButton,
              tipPercentage === percentage && styles.tipButtonSelected
            ]}
            onPress={() => setTipPercentage(percentage)}
          >
            <Text style={[
              styles.tipButtonText,
              tipPercentage === percentage && styles.tipButtonTextSelected
            ]}>
              {percentage}%
            </Text>
          </TouchableOpacity>
        ))}
      </View>

      <View style={styles.resultContainer}>
        <View style={styles.resultRow}>
          <Text style={styles.resultLabel}>Kwota napiwku:</Text>
          <Text style={styles.resultValue}>{tip.toFixed(2)} zł</Text>
        </View>
        <View style={styles.resultRow}>
          <Text style={[styles.resultLabel, styles.totalLabel]}>Suma do zapłaty:</Text>
          <Text style={[styles.resultValue, styles.totalValue]}>{total.toFixed(2)} zł</Text>
        </View>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
    padding: 20,
    justifyContent: 'center',
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    marginBottom: 40,
    textAlign: 'center',
    color: '#333'
  },
  inputContainer: {
    marginBottom: 30,
  },
  label: {
    fontSize: 16,
    color: '#666',
    marginBottom: 8,
    fontWeight: '600'
  },
  input: {
    borderWidth: 1,
    borderColor: '#ddd',
    padding: 15,
    borderRadius: 10,
    fontSize: 18,
    backgroundColor: '#f9f9f9',
  },
  tipButtonsContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 40,
  },
  tipButton: {
    flex: 1,
    backgroundColor: '#f0f0f0',
    padding: 15,
    borderRadius: 10,
    marginHorizontal: 5,
    alignItems: 'center',
  },
  tipButtonSelected: {
    backgroundColor: '#007AFF',
  },
  tipButtonText: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
  },
  tipButtonTextSelected: {
    color: '#fff',
  },
  resultContainer: {
    backgroundColor: '#f8f9fa',
    padding: 20,
    borderRadius: 15,
    borderWidth: 1,
    borderColor: '#eee',
  },
  resultRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 15,
  },
  resultLabel: {
    fontSize: 16,
    color: '#555',
  },
  resultValue: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
  },
  totalLabel: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#000',
  },
  totalValue: {
    fontSize: 24,
    color: '#007AFF',
  }
});
