import 'dart:io';

// Reusable mixin: adds a creation timestamp to classes that use it.
mixin Timestamped {
  final DateTime createdAt = DateTime.now();

  String get timestampDetails => createdAt.toLocal().toString();
}

// Parent class shared by all records in the learning center.
abstract class CenterRecord {
  final String id;
  String _name;

  CenterRecord({required this.id, required String name}) : _name = name;

  String get name => _name;

  set name(String value) {
    final cleaned = value.trim();
    if (cleaned.isNotEmpty) {
      _name = cleaned;
    }
  }

  // Each child class must provide its own version.
  String describe();
}

// Child class 1: LearningResource.
class LearningResource extends CenterRecord with Timestamped {
  String _category;
  bool _isBorrowed;

  LearningResource({
    required super.id,
    required String title,
    required String category,
  })  : _category = category,
        _isBorrowed = false,
        super(name: title);

  String get title => name;
  String get category => _category;
  bool get isBorrowed => _isBorrowed;

  set category(String value) {
    final cleaned = value.trim();
    if (cleaned.isNotEmpty) {
      _category = cleaned;
    }
  }

  bool borrow() {
    if (_isBorrowed) return false;
    _isBorrowed = true;
    return true;
  }

  bool returnResource() {
    if (!_isBorrowed) return false;
    _isBorrowed = false;
    return true;
  }

  @override
  String describe() {
    final status = _isBorrowed ? 'Borrowed' : 'Available';
    return '[$id] $title | Category: $_category | Status: $status';
  }
}

// Child class 2: Participant.
class Participant extends CenterRecord with Timestamped {
  String _email;
  final List<String> _borrowedResourceIds = [];

  Participant({
    required super.id,
    required String fullName,
    required String email,
  })  : _email = email,
        super(name: fullName);

  String get fullName => name;
  String get email => _email;

  // Return a read-only view so outside code cannot directly edit the list.
  List<String> get borrowedResourceIds =>
      List.unmodifiable(_borrowedResourceIds);

  set email(String value) {
    final cleaned = value.trim();
    if (cleaned.contains('@') && cleaned.contains('.')) {
      _email = cleaned;
    }
  }

  void addBorrowedResource(String resourceId) {
    if (!_borrowedResourceIds.contains(resourceId)) {
      _borrowedResourceIds.add(resourceId);
    }
  }

  void removeBorrowedResource(String resourceId) {
    _borrowedResourceIds.remove(resourceId);
  }

  @override
  String describe() {
    return '[$id] $fullName | Email: $_email | '
        'Borrowed resources: ${_borrowedResourceIds.length}';
  }
}

// Simple transaction record for borrowing and returning resources.
class CenterTransaction with Timestamped {
  final String action;
  final String participantName;
  final String resourceTitle;

  CenterTransaction({
    required this.action,
    required this.participantName,
    required this.resourceTitle,
  });

  String describe() {
    return '$action | $participantName | $resourceTitle | $timestampDetails';
  }
}

class CommunityLearningCenter {
  final List<LearningResource> _resources = [];
  final Map<String, Participant> _participants = {};
  final List<CenterTransaction> _transactions = [];

  int _nextResourceNumber = 1;
  int _nextParticipantNumber = 1;

  // Add a resource to the List.
  LearningResource addResource(String title, String category) {
    final resource = LearningResource(
      id: 'R${_nextResourceNumber.toString().padLeft(3, '0')}',
      title: title,
      category: category,
    );
    _nextResourceNumber++;
    _resources.add(resource);
    return resource;
  }

  // Add a participant to the Map.
  Participant registerParticipant(String fullName, String email) {
    final participant = Participant(
      id: 'P${_nextParticipantNumber.toString().padLeft(3, '0')}',
      fullName: fullName,
      email: email,
    );
    _nextParticipantNumber++;
    _participants[participant.id] = participant;
    return participant;
  }

  // Process a borrowing transaction.
  String borrowResource(String participantId, String resourceId) {
    final participant = _participants[participantId];
    final resource = _findResource(resourceId);

    if (participant == null) {
      return 'Participant ID not found.';
    }
    if (resource == null) {
      return 'Resource ID not found.';
    }
    if (!resource.borrow()) {
      return 'That resource is already borrowed.';
    }

    participant.addBorrowedResource(resource.id);
    _transactions.add(CenterTransaction(
      action: 'BORROW',
      participantName: participant.fullName,
      resourceTitle: resource.title,
    ));
    return '${resource.title} was successfully borrowed by ${participant.fullName}.';
  }

  // Process a return transaction.
  String returnResource(String participantId, String resourceId) {
    final participant = _participants[participantId];
    final resource = _findResource(resourceId);

    if (participant == null) {
      return 'Participant ID not found.';
    }
    if (resource == null) {
      return 'Resource ID not found.';
    }
    if (!participant.borrowedResourceIds.contains(resourceId)) {
      return 'This participant did not borrow that resource.';
    }
    if (!resource.returnResource()) {
      return 'That resource is already marked as available.';
    }

    participant.removeBorrowedResource(resourceId);
    _transactions.add(CenterTransaction(
      action: 'RETURN',
      participantName: participant.fullName,
      resourceTitle: resource.title,
    ));
    return '${resource.title} was successfully returned by ${participant.fullName}.';
  }

  LearningResource? _findResource(String id) {
    for (final resource in _resources) {
      if (resource.id.toLowerCase() == id.trim().toLowerCase()) {
        return resource;
      }
    }
    return null;
  }

  Participant? findParticipant(String id) {
    return _participants[id.trim().toUpperCase()];
  }

  // Polymorphism: both subclasses are handled through their shared parent type.
  void displayAllRecords() {
    final List<CenterRecord> records = [
      ..._resources,
      ..._participants.values,
    ];

    if (records.isEmpty) {
      print('No records found.');
      return;
    }

    print('\n========== ALL CENTER RECORDS ==========');
    for (final record in records) {
      print(record.describe());
    }
  }

  void displayResources() {
    if (_resources.isEmpty) {
      print('No learning resources registered.');
      return;
    }

    print('\n========== LEARNING RESOURCES ==========');
    for (final resource in _resources) {
      // Calls the subclass implementation of describe().
      print('${resource.describe()} | Added: ${resource.timestampDetails}');
    }
  }

  void displayParticipants() {
    if (_participants.isEmpty) {
      print('No participants registered.');
      return;
    }

    print('\n========== PARTICIPANTS ==========');
    for (final participant in _participants.values) {
      print('${participant.describe()} | Registered: ${participant.timestampDetails}');
    }
  }

  void displayTransactions() {
    if (_transactions.isEmpty) {
      print('No transactions have been processed.');
      return;
    }

    print('\n========== TRANSACTION HISTORY ==========');
    for (final transaction in _transactions) {
      print(transaction.describe());
    }
  }
}

// User-defined function with parameters and a return value.
String readRequiredText(String prompt) {
  while (true) {
    stdout.write(prompt);
    final value = stdin.readLineSync()?.trim() ?? '';

    if (value.isNotEmpty) {
      return value;
    }
    print('Input cannot be empty. Please try again.');
  }
}

// User-defined function with parameters and a return value.
// It safely handles non-numeric and out-of-range menu input.
int readMenuChoice() {
  stdout.write('Enter your choice: ');
  final input = stdin.readLineSync()?.trim() ?? '';
  final choice = int.tryParse(input);

  if (choice == null) {
    print('Invalid input. Please enter a number.');
    return -1;
  }
  return choice;
}

void showMenu() {
  print('\n==============================================');
  print('   COMMUNITY LEARNING CENTER MANAGEMENT');
  print('==============================================');
  print('1. Add learning resource');
  print('2. Register participant');
  print('3. Borrow a resource');
  print('4. Return a resource');
  print('5. View learning resources');
  print('6. View participants');
  print('7. View transaction history');
  print('8. View all records');
  print('0. Exit');
  print('----------------------------------------------');
}

void main() {
  final center = CommunityLearningCenter();
  var isRunning = true;

  print('Welcome to the Community Learning Center Management System!');

  // Loop continues until the user chooses 0.
  while (isRunning) {
    showMenu();
    final choice = readMenuChoice();

    // Conditional statements process the user's menu selection.
    switch (choice) {
      case 1:
        print('\n--- ADD LEARNING RESOURCE ---');
        final title = readRequiredText('Enter resource title: ');
        final category = readRequiredText('Enter resource category: ');
        final resource = center.addResource(title, category);
        print('Resource added successfully. ID: ${resource.id}');
        break;

      case 2:
        print('\n--- REGISTER PARTICIPANT ---');
        final fullName = readRequiredText('Enter participant full name: ');
        String email;

        while (true) {
          email = readRequiredText('Enter email address: ');
          if (email.contains('@') && email.contains('.')) {
            break;
          }
          print('Invalid email format. Please try again.');
        }

        final participant = center.registerParticipant(fullName, email);
        print('Participant registered successfully. ID: ${participant.id}');
        break;

      case 3:
        print('\n--- BORROW A RESOURCE ---');
        center.displayParticipants();
        final participantId =
            readRequiredText('Enter participant ID (example: P001): ');
        center.displayResources();
        final resourceId =
            readRequiredText('Enter resource ID (example: R001): ');
        print(center.borrowResource(participantId, resourceId));
        break;

      case 4:
        print('\n--- RETURN A RESOURCE ---');
        final participantId =
            readRequiredText('Enter participant ID (example: P001): ');
        final resourceId =
            readRequiredText('Enter resource ID (example: R001): ');
        print(center.returnResource(participantId, resourceId));
        break;

      case 5:
        center.displayResources();
        break;

      case 6:
        center.displayParticipants();
        break;

      case 7:
        center.displayTransactions();
        break;

      case 8:
        center.displayAllRecords();
        break;

      case 0:
        isRunning = false;
        print('Thank you for using the Community Learning Center System!');
        break;

      default:
        print('Invalid menu choice. Please select a number from 0 to 8.');
    }
  }
}
