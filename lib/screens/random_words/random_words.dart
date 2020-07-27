import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:first_flutter/models/word.dart';

class RandomWords extends StatefulWidget {
  @override
  State<RandomWords> createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final wordsCollection = Firestore.instance.collection('Words');
  List<Word> wordList = <Word>[];
  Future<List<Word>> _futureWords;
  final _biggerFont = const TextStyle(fontSize: 18);

  @override
  void initState() {
    super.initState();
    // wordList
    //     .addAll(generateWordPairs().take(30).map((e) => Word(e.asPascalCase)));
    // wordList.forEach((word) async {
    //   await wordsCollection.document(word.id).setData({
    //     'value': word.value,
    //     'isFav': word.isFav,
    //   });
    // });
    _futureWords = loadWordList();
  }

  Future<List<Word>> loadWordList() async {
    try {
      final query = await wordsCollection.getDocuments();
      return query.documents
          .map((document) => Word(document.data['value'],
              isFav: document.data['isFav'], id: document.documentID))
          .toList();
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Favorited Words'),
            ),
            body: ListView(
              children: ListTile.divideTiles(
                context: context,
                tiles: wordList.where((word) => word.isFav).map((word) {
                  return ListTile(
                    title: Text(
                      word.value,
                      style: _biggerFont,
                    ),
                  );
                }),
              ).toList(),
            ),
          );
        },
      ),
    );
  }

  void _onTap(Word word) {
    final alreadySaved = word.isFav;
    if (alreadySaved) {
      wordsCollection.document(word.id).updateData({'isFav': false});
      setState(() {
        word.setFav(false);
      });
    } else {
      wordsCollection.document(word.id).updateData({'isFav': true});
      setState(() {
        word.setFav(true);
      });
    }
  }

  Widget _buildList() {
    return FutureBuilder(
      future: _futureWords,
      builder: (context, AsyncSnapshot<List<Word>> snapshot) {
        if (snapshot.hasData) {
          wordList = snapshot.data;
          return ListView.separated(
              itemCount: wordList.length,
              itemBuilder: (context, index) => _buildRow(wordList[index]),
              separatorBuilder: (context, index) {
                return Divider();
              });
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }

        return Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildRow(Word word) {
    final alreadySaved = word.isFav;
    return ListTile(
      title: Text(
        word.value,
        style: _biggerFont,
      ),
      trailing: Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
      ),
      onTap: () => _onTap(word),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Word List'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.list),
            onPressed: _pushSaved,
          )
        ],
      ),
      body: _buildList(),
    );
  }
}
