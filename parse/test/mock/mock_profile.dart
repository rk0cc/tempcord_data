import 'package:tempcord_data_parser/handlers.dart';

class _MockProfile implements Profile {
  final String name;
  final Animal animal;
  final DateTime dob;

  _MockProfile(this.name, this.animal, this.dob);

  @override
  _MockProfile updateAnimal(Animal animal) =>
      MockProfile(this.name, animal, this.dob);

  @override
  _MockProfile updateName(String name) =>
      MockProfile(name, this.animal, this.dob);

  _MockProfile updateDob(DateTime dateTime) =>
      MockProfile(this.name, this.animal, dob);
}

class MockProfile extends _MockProfile with ProfileJsonMixin {
  MockProfile(String name, Animal animal, DateTime dob)
      : super(name, animal, dob);

  factory MockProfile.fromJson(Json json) => MockProfile(
      json["name"], Animal.values[json["animal"]], DateTime.parse(json["dob"]));

  @override
  Json toJson() =>
      {"name": name, "animal": animal.index, "dob": dob.toIso8601String()};
}
