import 'dart:io';

/// Clears the terminal screen
void clearScreen() {
  if (Platform.isWindows) {
    print(Process.runSync("cls", [], runInShell: true).stdout);
  } else {
    print(Process.runSync("clear", [], runInShell: true).stdout);
  }
}

/// Prompts user to press Enter to continue and clears screen after
void pressEnterToContinue() {
  print('\n--- Press Enter to continue ---');
  stdin.readLineSync();
  clearScreen();
}
