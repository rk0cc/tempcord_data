import 'package:tempcord_data_interface/interface.dart';
import 'package:tempcord_data_interface/type.dart';

// Example implementation of profile
class ExampleProfile implements Profile {
  @override
  final String name;

  @override
  final Animal animal;

  // Additional field depending what you needed
  final int age;

  ExampleProfile(this.name, this.animal, this.age);

  @override
  ExampleProfile updateAnimal(Animal animal) =>
      ExampleProfile(this.name, animal, this.age);

  @override
  ExampleProfile updateName(String name) =>
      ExampleProfile(name, this.animal, this.age);

  // Also provide update method for each additional field

  ExampleProfile updateAge(int age) =>
      ExampleProfile(this.name, this.animal, age);
}

class ExampleBodyTemperatureRecordNode implements BodyTemperatureRecordNode {
  @override
  final DateTime recordedAt;

  @override
  final Temperature temperature;

  // Additional field here

  ExampleBodyTemperatureRecordNode(this.temperature, this.recordedAt);
}
