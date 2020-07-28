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

  Future<void> _onTap(Word word) async {
    final isFaved = word.isFav;
    setState(() {
      word.setFav(!isFaved);
    });
    try {
      await wordsCollection.document(word.id).updateData({'isFav': !isFaved});
    } catch (e) {
      print(e);
      setState(() {
        _futureWords = loadWordList();
      });
    }
  }

  Widget _buildList() {
    return FutureBuilder(
      future: _futureWords,
      builder: (context, AsyncSnapshot<List<Word>> snapshot) {
        if (snapshot.hasData) {
          wordList = snapshot.data;
          return RefreshIndicator(
            child: Scrollbar(
              child: ListView(
                children: ListTile.divideTiles(
                  context: context,
                  tiles: snapshot.data.map((word) => _buildRow(context, word)),
                ).toList(),
              ),
            ),
            onRefresh: () async {
              setState(() {
                _futureWords = loadWordList();
              });
            },
          );
        } else if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }

        return Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildRow(BuildContext context, Word word) {
    return Dismissible(
      key: Key(word.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.fromLTRB(0, 0, 45, 0),
        color: Colors.red,
        child: Icon(
          Icons.delete_outline,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        setState(() {
          wordList.remove(word);
        });
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text('${word.value} dismissed'),
        ));
      },
      child: ListTile(
        title: Text(
          word.value,
          style: _biggerFont,
        ),
        trailing: Icon(
          word.isFav ? Icons.favorite : Icons.favorite_border,
          color: word.isFav ? Colors.red : null,
        ),
        onTap: () => _onTap(word),
      ),
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
