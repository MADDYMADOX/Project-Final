/// Task types available in the app
enum TaskType {
  writing('Writing', 'assets/icons/writing.png'),
  coding('Coding', 'assets/icons/coding.png'),
  studying('Studying', 'assets/icons/studying.png'),
  reading('Reading', 'assets/icons/reading.png'),
  creative('Creative', 'assets/icons/creative.png'),
  other('Other', 'assets/icons/other.png');

  const TaskType(this.displayName, this.iconPath);

  final String displayName;
  final String iconPath;
}