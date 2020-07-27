import 'package:uuid/uuid.dart';

class Word {
  String id = Uuid().v4();
  final String value;
  bool isFav = false;

  Word(this.value, {this.isFav, this.id});

  void setFav([bool fav = true]) {
    isFav = fav;
  }
}
