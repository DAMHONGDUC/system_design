extension StringExt on String? {
  bool get isNotNullAndNotEmpty => this != null && this!.isNotEmpty;

  bool get isNullOrEmpty => this == null || this!.isEmpty;
}
