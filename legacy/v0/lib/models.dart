enum LoanStatus {
  menunggu('Menunggu', 'menunggu'),
  disetujui('Disetujui', 'disetujui'),
  selesai('Selesai', 'selesai'),
  dibatalkan('Dibatalkan', 'dibatalkan');

  final String label;
  final String code;
  const LoanStatus(this.label, this.code);

  static LoanStatus fromCode(String code) {
    return LoanStatus.values.firstWhere(
      (e) => e.code == code,
      orElse: () => LoanStatus.menunggu,
    );
  }
}

class HobbyCategory {
  final String id;
  final String name;
  final String iconName;

  const HobbyCategory({
    required this.id,
    required this.name,
    this.iconName = 'category',
  });
}

class Item {
  final String id;
  final String name;
  final String categoryId;
  final String location;
  final String imagePath;
  final String description;
  final String ownerName;
  final bool isAvailable;
  final bool isMine;

  const Item({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.location,
    required this.imagePath,
    required this.description,
    required this.ownerName,
    this.isAvailable = true,
    this.isMine = false,
  });

  Item copyWith({
    String? id,
    String? name,
    String? categoryId,
    String? location,
    String? imagePath,
    String? description,
    String? ownerName,
    bool? isAvailable,
    bool? isMine,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      location: location ?? this.location,
      imagePath: imagePath ?? this.imagePath,
      description: description ?? this.description,
      ownerName: ownerName ?? this.ownerName,
      isAvailable: isAvailable ?? this.isAvailable,
      isMine: isMine ?? this.isMine,
    );
  }
}

class Loan {
  final String id;
  final String itemId;
  final String borrowerName;
  final String borrowerPhone;
  final DateTime startDate;
  final DateTime endDate;
  final String purpose;
  final LoanStatus status;
  final bool termsAccepted;

  const Loan({
    required this.id,
    required this.itemId,
    required this.borrowerName,
    required this.borrowerPhone,
    required this.startDate,
    required this.endDate,
    required this.purpose,
    this.status = LoanStatus.menunggu,
    this.termsAccepted = true,
  });

  Loan copyWith({
    String? id,
    String? itemId,
    String? borrowerName,
    String? borrowerPhone,
    DateTime? startDate,
    DateTime? endDate,
    String? purpose,
    LoanStatus? status,
    bool? termsAccepted,
  }) {
    return Loan(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      borrowerName: borrowerName ?? this.borrowerName,
      borrowerPhone: borrowerPhone ?? this.borrowerPhone,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      purpose: purpose ?? this.purpose,
      status: status ?? this.status,
      termsAccepted: termsAccepted ?? this.termsAccepted,
    );
  }
}

class UserProfile {
  final String name;
  final String email;
  final String phone;
  final String campus;
  final String bio;

  const UserProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.campus,
    required this.bio,
  });

  UserProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? campus,
    String? bio,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      campus: campus ?? this.campus,
      bio: bio ?? this.bio,
    );
  }
}
