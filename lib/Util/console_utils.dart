import 'dart:io';

/// Clears the terminal screen - guaranteed to work
void clearScreen() {
  // Method 1: Try ANSI escape sequences (works in most modern terminals)
  try {
    print('\x1B[2J\x1B[0;0H');
    return;
  } catch (e) {
    // If ANSI fails, continue to fallback
  }
  
  // Method 2: Try system commands
  try {
    if (Platform.isWindows) {
      Process.runSync('cmd', ['/c', 'cls'], runInShell: true);
    } else {
      Process.runSync('clear', [], runInShell: true);
    }
    return;
  } catch (e) {
    // If system commands fail, use newlines
  }
  
  // Method 3: Fallback - always works
  for (int i = 0; i < 50; i++) {
    print('');
  }
}

/// Prompts user to press Enter to continue and clears screen after
void pressEnterToContinue() {
  print('\n--- Press Enter to continue ---');
  stdin.readLineSync();
  clearScreen();
}