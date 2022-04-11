import 'dart:typed_data';

import 'package:meta/meta.dart';

import 'animal.dart';

@immutable
abstract class Profile {
  String get name;
  Animal get animal;

  Profile updateName(String name);

  Profile updateAnimal(Animal animal);
}

@immutable
abstract class ProfileWithImage extends Profile {
  UnmodifiableUint8ListView? get image;

  @override
  ProfileWithImage updateName(String name);

  @override
  ProfileWithImage updateAnimal(Animal animal);

  ProfileWithImage updateImage(Uint8List? image);
}

@immutable
abstract class ProfileWithId<T extends Comparable> extends Profile {
  T get id;

  ProfileWithId<T> updateName(String name);

  ProfileWithId<T> updateAnimal(Animal animal);
}
