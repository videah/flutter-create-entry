import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:state_persistence/state_persistence.dart';

void main() => runApp(App());

_appBar(text, call) {
  return AppBar(
    title: Text("$text"),
    elevation: 0.0,
    actions: [IconButton(icon: Icon(Icons.add), onPressed: call)],
  );
}

class App extends StatelessWidget {
  build(_) {
    return PersistedAppState(
      storage: JsonFileStorage(),
      child: MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.teal,
          scaffoldBackgroundColor: Colors.teal,
        ),
        home: Home(),
      ),
    );
  }
}

class Home extends StatefulWidget {
  createState() => HomeS();
}

class HomeS extends State<Home> {
  _newDeck() async {
    var result = await showDialog(
      context: context,
      builder: (_) => NewAlert("Deck Title", "Deck Description"),
    );
    var store = PersistedAppState.of(context);
    if (store["decks"] == null) store["decks"] = [];
    store["decks"].add({"name": result[0], "desc": result[1], "cards": []});
    setState(() => store.persist());
  }

  _openDeck(i) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => Review(i)),
    );
  }

  _buildBody(ctx) {
    return PersistedStateBuilder(
      builder: (ctx, snap) {
        if (!snap.hasData) return Container();
        if (snap.data["decks"] == null)
          snap.data["decks"] = [
            {"name": "Example Deck", "desc": "Empty Starter Deck", "cards": []}
          ];
        var decks = snap.data["decks"];
        return ListView.builder(
          itemCount: decks?.length ?? 0,
          padding: EdgeInsets.all(4.0),
          itemBuilder: (c, i) {
            return Hero(
              tag: "$i",
              child: Card(
                child: ListTile(
                  title: Text(decks[i]["name"]),
                  subtitle: Text(decks[i]["desc"]),
                  onTap: () => _openDeck(i),
                ),
              ),
            );
          },
        );
      },
    );
  }

  build(ctx) {
    return Scaffold(
      appBar: _appBar("Decks", () => _newDeck()),
      body: _buildBody(ctx),
    );
  }
}

class Review extends StatelessWidget {
  var swipe = SwiperController();
  var tag;
  Review(this.tag);

  _newCard(ctx, i) async {
    var result = await showDialog(
      context: ctx,
      builder: (_) => NewAlert("Card Front", "Card Back"),
    );
    var store = PersistedAppState.of(ctx);
    store["decks"][i]["cards"].add({"front": result[0], "back": result[1]});
    store.persist();
  }

  _buildContent(ctx, text) {
    var store = PersistedAppState.of(ctx);
    return Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      ListTile(
        title: Text("${store["decks"][tag]["name"]}"),
        subtitle: Text("${store["decks"][tag]["desc"]}"),
      ),
      Padding(
        padding: EdgeInsets.all(64.0),
        child: AutoSizeText(
          "$text",
          style: TextStyle(fontSize: 50.0),
          textAlign: TextAlign.center,
          maxLines: 2,
        ),
      ),
      Padding(
        padding: EdgeInsets.all(16.0),
        child: Text("Tap to flip card"),
      )
    ]);
  }

  _buildCard(ctx, front, back, tag) {
    return Padding(
      padding: EdgeInsets.all(48.0),
      child: Hero(
        tag: "$tag",
        child: FlipCard(
          direction: FlipDirection.HORIZONTAL,
          front: Card(child: _buildContent(ctx, "$front")),
          back: Card(child: _buildContent(ctx, "$back")),
        ),
      ),
    );
  }

  build(ctx) {
    return PersistedStateBuilder(
      builder: (ctx, snap) {
        var cards = snap.data["decks"][tag]["cards"];
        return Scaffold(
          appBar: _appBar("Cards", () => _newCard(ctx, tag)),
          body: Swiper(
            itemCount: cards.length,
            loop: false,
            control: SwiperControl(color: Colors.white),
            controller: swipe,
            itemBuilder: (c, i) {
              return _buildCard(ctx, cards[i]["front"], cards[i]["back"], tag);
            },
          ),
        );
      },
    );
  }
}

class NewAlert extends StatelessWidget {
  var one;
  var two;
  NewAlert(this.one, this.two);

  var _one = TextEditingController();
  var _two = TextEditingController();
  _buildInput(text, controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: "$text"),
    );
  }

  build(ctx) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildInput(one, _one),
          _buildInput(two, _two),
        ],
      ),
      actions: [
        FlatButton(
          child: Text("CANCEL"),
          onPressed: () => Navigator.of(ctx).pop(),
        ),
        FlatButton(
          child: Text("CREATE"),
          onPressed: () {
            Navigator.of(ctx).pop([_one.value.text, _two.value.text]);
          },
        ),
      ],
    );
  }
}
