import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  _newDeck(context) {
    showDialog(
      context: context,
      builder: (context) {
        return NewAlert([
          TextField(
            autofocus: true,
            decoration: InputDecoration(labelText: "Deck Name"),
          ),
        ]);
      },
    );
  }

  _openDeck(context, i) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => Review("$i")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flashcards"),
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _newDeck(context),
          )
        ],
      ),
      backgroundColor: Theme.of(context).accentColor,
      body: ListView.builder(
        padding: EdgeInsets.all(4.0),
        itemBuilder: (c, i) {
          return Hero(
            tag: "$i",
            child: Card(
              child: ListTile(
                title: Text("Japanese"),
                subtitle: Text("Deck for RTK"),
                onTap: () => _openDeck(context, i),
              ),
            ),
          );
        },
      ),
    );
  }
}

class DeckCard extends StatelessWidget {
  final String tag;
  DeckCard(this.tag);

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      child: FlipCard(
        direction: FlipDirection.HORIZONTAL,
        front: Card(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              ListTile(
                title: Text("Japanese"),
                subtitle: Text("Deck for RTK"),
              ),
              Text("Example Prompt"),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("Tap card to flip"),
              )
            ],
          ),
        ),
        back: Card(
          child: Center(
            child: Text(
              "漢字",
              style: TextStyle(fontSize: 100),
            ),
          ),
        ),
      ),
    );
  }
}

class Review extends StatefulWidget {
  final tag;
  Review(this.tag);

  @override
  ReviewState createState() => ReviewState();
}

class ReviewState extends State<Review> {
  var _swipe = SwiperController();
  var count = 1;

  _newCard() {
    showDialog(
      context: context,
      builder: (context) {
        return NewAlert([
          TextField(
            autofocus: true,
            decoration: InputDecoration(labelText: "Card Description"),
          ),
          TextField(
            decoration: InputDecoration(labelText: "Card Answer"),
          ),
        ]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).accentColor,
      appBar: AppBar(
        title: Text("Review"),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _newCard(),
          )
        ],
      ),
      body: Swiper(
        itemCount: 50,
        loop: false,
        controller: _swipe,
        onIndexChanged: (i) => setState(() => count = i + 1),
        itemBuilder: (c, i) => DeckCard(widget.tag),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () => _swipe.previous(),
            ),
            Text("$count/50"),
            IconButton(
              icon: Icon(Icons.arrow_forward_ios),
              onPressed: () => _swipe.next(),
            )
          ],
        ),
      ),
    );
  }
}

class NewAlert extends StatelessWidget {
  final List<Widget> inputs;
  NewAlert(this.inputs);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: inputs,
      ),
      actions: <Widget>[
        FlatButton(
          child: Text("CANCEL"),
          onPressed: () => Navigator.of(context).pop(),
        ),
        FlatButton(
          child: Text("CREATE"),
          onPressed: () {},
        )
      ],
    );
  }
}
