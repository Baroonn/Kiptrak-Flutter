enum AssignmentStatus{
  pending, completed, notApplicable, closed
}

class Assignment {
  String title;
  String desc;
  String course;
  String lecturer;
  DateTime dateDue;
  String? notes;
  String createdBy;
  DateTime createdAt;
  String? imagePath;
  AssignmentStatus status;

  Assignment({
    required this.title,
    required this.desc,
    required this.course,
    required this.lecturer,
    required this.dateDue,
    this.notes,
    required this.createdBy,
    required this.createdAt,
    this.imagePath,
    required this.status
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'desc': desc,
      'course': course,
      'lecturer': lecturer,
      'dateDue': dateDue.toString(),
      'notes': notes,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'imagePath': imagePath,
      'status': status.name,
    };
  }
}

class AssignmentCreateDto{
  int? id;
  String title;
  String desc;
  String course;
  String lecturer;
  DateTime dateDue;
  String? notes;
  String? imagePath;
  AssignmentStatus status;

  AssignmentCreateDto({
    this.id,
    required this.title,
    required this.desc,
    required this.course,
    required this.lecturer,
    required this.dateDue,
    this.notes,
    required this.status,
    this.imagePath
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'desc': desc,
      'course': course,
      'lecturer': lecturer,
      'dateDue': dateDue.toString(),
      'notes': notes,
      'status': status.name,
      'imagePath': imagePath
    };
  }
}

class AssignmentReadDto{
  int id;
  String title;
  String desc;
  String course;
  String lecturer;
  DateTime dateDue;
  String? notes;
  String? imagePath;
  AssignmentStatus status;

  AssignmentReadDto({
    required this.id,
    required this.title,
    required this.desc,
    required this.course,
    required this.lecturer,
    required this.dateDue,
    this.notes,
    required this.status,
    this.imagePath
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'desc': desc,
      'course': course,
      'lecturer': lecturer,
      'dateDue': dateDue.toString(),
      'notes': notes,
      'status': status.name,
      'imagePath': imagePath
    };
  }
}