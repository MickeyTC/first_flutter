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
  final _biggerFont = const TextStyle(fontSize: 18);

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

  Future<void> _onTap(Word word) async {
    final isFaved = word.isFav;
    try {
      await wordsCollection.document(word.id).updateData({'isFav': !isFaved});
    } catch (e) {
      print(e);
    }
  }

  Widget _buildList(BuildContext context) {
    return StreamBuilder(
      stream: wordsCollection.snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          wordList = snapshot.data.documents
              .map((document) => Word(document.data['value'],
                  isFav: document.data['isFav'], id: document.documentID))
              .toList();
          return Scrollbar(
            child: ListView(
              children:
                  wordList.map((word) => _buildRow(context, word)).toList(),
            ),
          );
        }

        return Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildRow(BuildContext context, Word word) {
    return ListTile(
      title: Text(
        word.value,
        style: _biggerFont,
      ),
      trailing: Icon(
        word.isFav ? Icons.favorite : Icons.favorite_border,
        color: word.isFav ? Colors.red : null,
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
      body: _buildList(context),
    );
  }
}
