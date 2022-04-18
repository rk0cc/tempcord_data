import 'package:tempcord_data_parser/handlers.dart';
import 'package:tempcord_data_parser/src/typedef.dart';

class MockProfile extends ProfileJson {
  final String name;
  final Animal animal;
  final DateTime dob;

  MockProfile(this.name, this.animal, DateTime dob) : this.dob = dob.toUtc();

  factory MockProfile.fromJson(Json json) => MockProfile(
      json["name"], Animal.values[json["animal"]], DateTime.parse(json["dob"]));

  @override
  MockProfile updateAnimal(Animal animal) =>
      MockProfile(this.name, animal, this.dob);

  @override
  MockProfile updateName(String name) =>
      MockProfile(name, this.animal, this.dob);

  MockProfile updateDob(DateTime dateTime) =>
      MockProfile(this.name, this.animal, dob);

  @override
  Json toJson() =>
      {"name": name, "animal": animal.index, "dob": dob.toIso8601String()};
}
