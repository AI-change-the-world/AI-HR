import 'package:isar_community/isar.dart';

part 'years.g.dart';

@collection
class ActivatedYear {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late int year;
}
