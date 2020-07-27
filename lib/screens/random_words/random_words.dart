import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:first_flutter/models/word.dart';

class RandomWords extends StatefulWidget {
  @override
  State<RandomWords> createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final wordsCollection = Firestore.instance.collection('Words');
  final wordList = <Word>[];
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
    loadWordList();
  }

  Future<void> loadWordList() async {
    var query = await wordsCollection.getDocuments();
    setState(() {
      wordList.addAll(query.documents.map((document) => Word(
          document.data['value'],
          isFav: document.data['isFav'],
          id: document.documentID)));
    });
  }

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Saved Suggestions'),
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

  void _onTap(Word word) async {
    final alreadySaved = word.isFav;
    if (alreadySaved) {
      setState(() {
        word.setFav(false);
      });
      try {
        await wordsCollection.document(word.id).updateData({'isFav': false});
      } catch (e) {
        print(e);
      }
    } else {
      setState(() {
        word.setFav(true);
      });
      try {
        await wordsCollection.document(word.id).updateData({'isFav': true});
      } catch (e) {
        print(e);
      }
    }
  }

  Widget _buildList() {
    return ListView.separated(
        itemCount: wordList.length,
        itemBuilder: (context, index) => _buildRow(wordList[index]),
        separatorBuilder: (context, index) {
          return Divider();
        });
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
        title: Text('Startup Name Generator'),
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
