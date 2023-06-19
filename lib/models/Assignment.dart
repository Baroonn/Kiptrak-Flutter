enum AssignmentStatus { pending, completed, notApplicable, closed, deleted }

class Assignment {
  String title;
  String desc;
  String course;
  String lecturer;
  int dateDue;
  String? notes;
  String userId;
  DateTime createdAt;
  String? imagePath;
  AssignmentStatus status;

  Assignment(
      {required this.title,
      required this.desc,
      required this.course,
      required this.lecturer,
      required this.dateDue,
      this.notes,
      required this.userId,
      required this.createdAt,
      this.imagePath,
      required this.status});

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'desc': desc,
      'course': course,
      'lecturer': lecturer,
      'dateDue': DateTime.fromMillisecondsSinceEpoch(dateDue).toString(),
      'notes': notes,
      'createdBy': userId,
      'createdAt': createdAt,
      'imagePath': imagePath,
      'status': status.name,
    };
  }
}

class AssignmentCreateDto {
  String title;
  String desc;
  String course;
  String lecturer;
  int dateDue;
  String? notes;
  String? imagePath;
  AssignmentStatus status;

  AssignmentCreateDto(
      {required this.title,
      required this.desc,
      required this.course,
      required this.lecturer,
      required this.dateDue,
      this.notes,
      required this.status,
      this.imagePath});

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'desc': desc,
      'course': course,
      'lecturer': lecturer,
      'dateDue': dateDue,
      'notes': notes,
      'status': status.name,
      'imagePath': imagePath
    };
  }
}

class AssignmentOnlineCreateDto {
  String title;
  String desc;
  String course;
  String lecturer;
  DateTime dateDue;
  String? notes;

  AssignmentOnlineCreateDto({
    required this.title,
    required this.desc,
    required this.course,
    required this.lecturer,
    required this.dateDue,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': desc,
      'course': course,
      'lecturer': lecturer,
      'dateDue': dateDue.toString(),
      'notes': notes,
    };
  }
}

class AssignmentReadDto {
  String id;
  String title;
  String desc;
  String course;
  String lecturer;
  DateTime dateDue;
  String? notes;
  String? imagePath;
  AssignmentStatus status;

  AssignmentReadDto(
      {required this.id,
      required this.title,
      required this.desc,
      required this.course,
      required this.lecturer,
      required this.dateDue,
      this.notes,
      required this.status,
      this.imagePath});

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

  factory AssignmentReadDto.fromJson(Map<String, dynamic> json) {
    return AssignmentReadDto(
      id: json['id'],
      title: json['title'],
      desc: json['description'],
      course: json['course'],
      lecturer: json['lecturer'],
      dateDue: DateTime.parse(json['dateDue']),
      status: AssignmentStatus.pending,
      notes: json['notes'],
      imagePath: json['images'],
    );
  }
}

class AssignmentOnlineReadDto {
  String id;
  String title;
  String description;
  String course;
  String lecturer;
  int dateDue;
  String? notes;
  String? images;
  DateTime created;
  String userId;
  AssignmentStatus status;

  AssignmentOnlineReadDto(
      {required this.id,
      required this.title,
      required this.description,
      required this.course,
      required this.lecturer,
      required this.dateDue,
      this.notes,
      this.images,
      required this.created,
      required this.userId})
      : status = AssignmentStatus.pending;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'course': course,
      'lecturer': lecturer,
      'dateDue': dateDue,
      'notes': notes,
      'status': status.name,
      'images': images,
      'created': created.toString(),
      'userId': userId
    };
  }

  factory AssignmentOnlineReadDto.fromJson(Map<String, dynamic> json) {
    return AssignmentOnlineReadDto(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        course: json['course'],
        lecturer: json['lecturer'],
        dateDue: DateTime.parse(json['dateDue']).millisecondsSinceEpoch,
        notes: json['notes'],
        images: json['images'],
        created: DateTime.parse(json['created']),
        userId: json['userId']);
  }
}

class AssignmentGlobalReadDto {
  String id;
  String title;
  String description;
  String course;
  String lecturer;
  DateTime dateDue;
  String? notes;
  String? images;
  DateTime created;
  String userId;
  AssignmentStatus status;

  AssignmentGlobalReadDto(
      {required this.id,
        required this.title,
        required this.description,
        required this.course,
        required this.lecturer,
        required this.dateDue,
        this.notes,
        this.images,
        required this.status,
        required this.created,
        required this.userId});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'course': course,
      'lecturer': lecturer,
      'datedue': dateDue,
      'notes': notes,
      'status': status.name,
      'images': images,
      'created': created.toString(),
      'userId': userId
    };
  }

  factory AssignmentGlobalReadDto.fromJson(Map<String, dynamic> json) {
    return AssignmentGlobalReadDto(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        course: json['course'],
        lecturer: json['lecturer'],
        dateDue: DateTime.fromMillisecondsSinceEpoch(json['dateDue']),
        notes: json['notes'],
        status: json['status'] == 'completed'?AssignmentStatus.completed: AssignmentStatus.pending,
        images: json['images'],
        created: DateTime.parse(json['created']),
        userId: json['userId']);
  }
}