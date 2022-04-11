import 'package:meta/meta.dart';
import 'package:tempcord_data_interface/interface.dart';
import 'package:tempcord_data_interface/type.dart';
import 'package:test/test.dart';

@immutable
class MockProfile implements Profile {
  @override
  final String name;

  @override
  final Animal animal;

  MockProfile(this.name, this.animal);

  @override
  MockProfile updateAnimal(Animal animal) => MockProfile(this.name, animal);

  @override
  MockProfile updateName(String name) => MockProfile(name, this.animal);
}

void main() {
  test("Updated profile is immutable", () {
    MockProfile origin = MockProfile("Foo", Animal.human);

    expect(identical(origin, origin), isTrue);
    expect(identical(origin, origin.updateName("Bar")), isFalse);
    expect(identical(origin, origin.updateAnimal(Animal.human)), isFalse);
  });
}
