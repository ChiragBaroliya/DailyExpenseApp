/// Simple rule-based parser for voice expense input
/// No AI/ML - only keyword-based logic
class VoiceExpenseParser {
  // Number words mapping
  static const Map<String, double> _numberWords = {
    'zero': 0,
    'one': 1,
    'two': 2,
    'three': 3,
    'four': 4,
    'five': 5,
    'six': 6,
    'seven': 7,
    'eight': 8,
    'nine': 9,
    'ten': 10,
    'eleven': 11,
    'twelve': 12,
    'thirteen': 13,
    'fourteen': 14,
    'fifteen': 15,
    'sixteen': 16,
    'seventeen': 17,
    'eighteen': 18,
    'nineteen': 19,
    'twenty': 20,
    'thirty': 30,
    'forty': 40,
    'fifty': 50,
    'sixty': 60,
    'seventy': 70,
    'eighty': 80,
    'ninety': 90,
    'hundred': 100,
    'thousand': 1000,
  };

  // Payment mode keywords
  static const Map<String, String> _paymentModeKeywords = {
    'cash': 'Cash',
    'card': 'Card',
    'upi': 'UPI',
    'bank': 'Bank Transfer',
    'transfer': 'Bank Transfer',
    'wallet': 'Wallet',
  };

  // Category keywords
  static const Map<String, String> _categoryKeywords = {
    // Food
    'tea': 'Food',
    'coffee': 'Food',
    'food': 'Food',
    'lunch': 'Food',
    'dinner': 'Food',
    'breakfast': 'Food',
    'snacks': 'Food',
    'pizza': 'Food',
    'burger': 'Food',
    'restaurant': 'Food',
    'cafe': 'Food',

    // Transport
    'travel': 'Transport',
    'bus': 'Transport',
    'taxi': 'Transport',
    'auto': 'Transport',
    'train': 'Transport',
    'flight': 'Transport',
    'petrol': 'Transport',
    'gas': 'Transport',
    'uber': 'Transport',
    'ride': 'Transport',

    // Shopping
    'shopping': 'Shopping',
    'clothes': 'Shopping',
    'shirt': 'Shopping',
    'dress': 'Shopping',
    'shoes': 'Shopping',
    'book': 'Shopping',
    'mobile': 'Shopping',
    'phone': 'Shopping',
    'gadget': 'Shopping',

    // Utilities
    'electric': 'Utilities',
    'electricity': 'Utilities',
    'water': 'Utilities',
    'bill': 'Utilities',
    'internet': 'Utilities',
    'wifi': 'Utilities',

    // Entertainment
    'movie': 'Entertainment',
    'cinema': 'Entertainment',
    'game': 'Entertainment',
    'music': 'Entertainment',
    'concert': 'Entertainment',
    'ticket': 'Entertainment',

    // Groceries
    'groceries': 'Groceries',
    'milk': 'Groceries',
    'bread': 'Groceries',
    'veggie': 'Groceries',
    'vegetable': 'Groceries',
    'fruits': 'Groceries',
    'meat': 'Groceries',

    // Health
    'medicine': 'Health',
    'doctor': 'Health',
    'hospital': 'Health',
    'pharmacy': 'Health',
    'medical': 'Health',
    'health': 'Health',

    // Subscription
    'subscription': 'Subscription',
    'netflix': 'Subscription',
    'spotify': 'Subscription',
    'premium': 'Subscription',
  };

  /// Parse voice input text into structured expense data
  /// Example: "Spent two hundred rupees on tea cash"
  /// Returns: {amount: 200, category: 'Food', paymentMode: 'Cash', notes: 'tea rupees'}
  static Map<String, dynamic> parseVoiceExpense(String text) {
    if (text.isEmpty) {
      return {
        'amount': null,
        'category': 'Other',
        'paymentMode': 'Cash',
        'notes': '',
      };
    }

    final lowerText = text.toLowerCase();
    final words = lowerText.split(RegExp(r'\s+'));

    double? amount = _extractAmount(words);
    String paymentMode = _detectPaymentMode(words);
    String category = _detectCategory(words);
    String notes = _extractNotes(words, amount, paymentMode, category);

    return {
      'amount': amount,
      'category': category,
      'paymentMode': paymentMode,
      'notes': notes.trim(),
    };
  }

  /// Extract amount from words (both numeric and word-based)
  /// Examples: "200", "two hundred", "5k"
  static double? _extractAmount(List<String> words) {
    double? amount;

    for (int i = 0; i < words.length; i++) {
      final word = words[i];

      // Check for direct numbers
      if (RegExp(r'^\d+(\.\d+)?$').hasMatch(word)) {
        amount = double.tryParse(word);
        if (amount != null) return amount;
      }

      // Check for numbers with k/m suffix (5k, 2m)
      if (RegExp(r'^(\d+\.?\d*)([km])$').hasMatch(word)) {
        final match = RegExp(r'^(\d+\.?\d*)([km])$').firstMatch(word);
        if (match != null) {
          final num = double.tryParse(match.group(1)!);
          final suffix = match.group(2);
          if (num != null) {
            amount = suffix == 'k' ? num * 1000 : num * 1000000;
            return amount;
          }
        }
      }

      // Check for word numbers
      if (_numberWords.containsKey(word)) {
        amount = _numberWords[word];

        // Handle compound numbers like "two hundred"
        if (i + 1 < words.length && _numberWords.containsKey(words[i + 1])) {
          final nextValue = _numberWords[words[i + 1]]!;
          if (nextValue >= 100) {
            amount = amount! * nextValue;
          } else if (amount! < 100) {
            amount = amount + nextValue;
          }
        }

        if (amount != null && amount > 0) return amount;
      }
    }

    return amount;
  }

  /// Detect payment mode from keywords
  static String _detectPaymentMode(List<String> words) {
    for (final word in words) {
      if (_paymentModeKeywords.containsKey(word)) {
        return _paymentModeKeywords[word]!;
      }
    }
    return 'Cash'; // Default
  }

  /// Detect category from keywords
  static String _detectCategory(List<String> words) {
    for (final word in words) {
      if (_categoryKeywords.containsKey(word)) {
        return _categoryKeywords[word]!;
      }
    }
    return 'Other'; // Default
  }

  /// Extract notes (remaining words not used for amount/mode/category)
  static String _extractNotes(
    List<String> words,
    double? amount,
    String paymentMode,
    String category,
  ) {
    final notes = <String>[];
    final usedWords = <String>{};

    // Mark words used for amount detection
    for (int i = 0; i < words.length; i++) {
      final word = words[i];
      if (RegExp(r'^\d+(\.\d+)?$').hasMatch(word) ||
          RegExp(r'^(\d+\.?\d*)([km])$').hasMatch(word) ||
          _numberWords.containsKey(word)) {
        usedWords.add(word);
        // Also mark multiplier if it exists
        if (i + 1 < words.length && _numberWords.containsKey(words[i + 1])) {
          usedWords.add(words[i + 1]);
        }
      }
    }

    // Mark words used for payment mode
    for (final word in words) {
      if (_paymentModeKeywords.containsKey(word)) {
        usedWords.add(word);
      }
    }

    // Mark words used for category
    for (final word in words) {
      if (_categoryKeywords.containsKey(word)) {
        usedWords.add(word);
      }
    }

    // Mark common filler words
    final fillerWords = {
      'spent', 'on', 'in', 'at', 'for', 'rupees', 'rs', 'bucks',
      'dollars', 'usd', 'inr', 'the', 'a', 'an', 'and', 'or',
    };
    for (final word in fillerWords) {
      usedWords.add(word);
    }

    // Collect remaining words
    for (final word in words) {
      if (!usedWords.contains(word) && word.isNotEmpty) {
        notes.add(word);
      }
    }

    return notes.join(' ');
  }
}
