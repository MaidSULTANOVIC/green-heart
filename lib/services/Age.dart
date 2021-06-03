int getAge(int year, int month, int day) {
  DateTime now = DateTime.now();
  int age = now.year - year;

  if (month > now.month) {
    age--;
  } else if (month == now.month) {
    if (day > now.day) {
      age--;
    }
  }

  return age;
}
