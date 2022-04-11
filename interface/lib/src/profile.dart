import 'dart:typed_data';

import 'package:meta/meta.dart';

import 'animal.dart';

/// The most basic object to identify user of Tempcord.
@immutable
abstract class Profile {
  /// User [name] of this [Profile].
  String get name;

  /// [Animal] type of this [Profile].
  Animal get animal;

  /// Construct [Profile] with given [name] and [animal].
  external Profile(String name, Animal animal);

  /// Return a [Profile] with updated [name].
  Profile updateName(String name);

  /// Return a [Profile] with updated [animal].
  Profile updateAnimal(Animal animal);
}

/// A [Profile] that allow to store [image].
@immutable
abstract class ProfileWithImage extends Profile {
  /// [image] which encoded as [Uint8List] that repersenting [Profile] picture.
  ///
  /// It allows to be nulled if not applied.
  UnmodifiableUint8ListView? get image;

  external ProfileWithImage(String name, Animal animal, Uint8List? image);

  @override
  ProfileWithImage updateName(String name);

  @override
  ProfileWithImage updateAnimal(Animal animal);

  /// Return [ProfileWithImage] that contains new [image].
  ProfileWithImage updateImage(Uint8List? image);
}

/// A [Profile] that support [id] field for fetch data from API.
///
/// The [id] type ([T]) must be [Comparable].
@immutable
abstract class ProfileWithId<T extends Comparable> extends Profile {
  /// Identify [Profile] from API.
  ///
  /// This field **should not be updated**.
  T get id;

  external ProfileWithId(T id, String name, Animal animal);

  @override
  ProfileWithId<T> updateName(String name);

  @override
  ProfileWithId<T> updateAnimal(Animal animal);
}
