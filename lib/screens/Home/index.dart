import "package:flutter/material.dart";
import "package:firebase_database/firebase_database.dart";
import 'package:firebase_database/ui/firebase_animated_list.dart';
import "package:firebase_auth/firebase_auth.dart";
import "dart:async";

String weddingIdMaster;

class MenuScreen extends StatefulWidget {
  const MenuScreen({ Key key }) : super(key: key);

  @override
  MenuScreenState createState() => new MenuScreenState();
}

class MenuScreenState extends State<MenuScreen>{

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "WedfulyChat",
      home: new CardScreen(),
    );
  }
}

class CardScreen extends StatefulWidget {

  @override
  State createState() => new CardScreenState();
}


class CardScreenState extends State<CardScreen> {

  DataSnapshot snapshot;

  DatabaseReference messageRef = FirebaseDatabase.instance.reference().child('users').child(FirebaseAuth.instance.currentUser.uid).child('weddings');

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Wedfuly Chat"),
        backgroundColor: const Color.fromRGBO(52, 88, 99, 1.0),),
      body:
      new Column(
        children: <Widget>[
          new Flexible(
              child:
              new FirebaseAnimatedList(
                query: messageRef,                 //new
                padding: new EdgeInsets.all(8.0),
                itemBuilder: (_, DataSnapshot snapshot, Animation<double> animation) { //new
                  return new SingleCard(//new
                    snapshot: snapshot,                                 //new
                    animation: animation, //new
                  );                                                    //new
                },                                                      //new
              )

          ),
        ],                                                          //new
      ),                                                            //new
    );
  }

}


class SingleCard extends StatefulWidget{
  SingleCard({this.snapshot, this.animation});
  final DataSnapshot snapshot;
  final Animation animation;

  @override
  SingleCardState createState() => new SingleCardState(snapshot: this.snapshot, animation: this.animation);

}

class SingleCardState extends State<SingleCard> {
  SingleCardState({this.snapshot, this.animation});
  final DataSnapshot snapshot;
  final Animation animation;
  BuildContext context;
  String weddingName;
  DataSnapshot weddingRef;
  String firstLetter;
  String weddingId;


  String user = FirebaseAuth.instance.currentUser.uid;
  void getWeddings() async{

    weddingId = snapshot.key;
    print(weddingId);
    weddingIdMaster = weddingId;
    weddingRef = await FirebaseDatabase.instance.reference().child("weddings").child(weddingId).child('info').child('displayName').once();
    weddingName = weddingRef.value;
    print(weddingName);

    setState(() {

    });

  }

  @override
  initState(){
    super.initState();
    getWeddings();
  }



  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new Card(
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new Container(
              margin: const EdgeInsets.symmetric(vertical: 30.0),
              child: new Text(weddingName ==  null ? 'empty' : weddingName,
                style: new TextStyle(fontFamily: 'Archer', fontSize: 20.0, color: const Color.fromRGBO(46, 55, 89, 1.0)),
              ),
            ),
            new ButtonTheme.bar( // make buttons use the appropriate styles for cards
              child: new ButtonBar(
                children: <Widget>[
                  new FlatButton(
                    child: const Text('CHAT'),
                    onPressed: () {
                      //todo go to new page with weddingId passed through
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                          builder: (context) => new HomeScreen()));
                    },
                  ),

                ],
              ),
            ),

          ],
        ),
      ),
    );

  }
}

//_______________________________________________________________________
//_______________________________________________________________________
//_______________________________________________________________________

class HomeScreen extends StatefulWidget {
  const HomeScreen({ Key key }) : super(key: key);
  @override
  HomeScreenState createState() => new HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>{

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "WedfulyChat",
      home: new ChatScreen(),
    );
  }
}

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

class ChatScreen extends StatefulWidget {

  @override
  State createState() => new ChatScreenState();
}


class ChatScreenState extends State<ChatScreen> {

  final TextEditingController _textController = new TextEditingController();

  bool _isComposing = false;

  final userID = firebaseAuth.currentUser.uid;

  var data;
  DataSnapshot snapshot;
  var snapSources;

  String weddingId;
  DatabaseReference messageRef;
  bool staff= false;

  Future getData() async {
    //find out if staff or not
    DataSnapshot staffSnap = await FirebaseDatabase.instance.reference().child("planners").child(FirebaseAuth.instance.currentUser.uid).child('uid').once();

    if(staffSnap != null){
      staff = true;
    }

    weddingId = weddingIdMaster;
    print(weddingIdMaster);
    messageRef = FirebaseDatabase.instance.reference().child('weddingChatMessages').child(weddingId);
    this.setState(() {

    });
    return "Success!";
  }

  @override
  void initState() {
    super.initState();
    this.getData();

  }

  void _ensureLoggedIn() async {
    FirebaseUser user = firebaseAuth.currentUser;

    if (user == null){
      Navigator.of(context).pushNamed("/Login");
    }
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Wedfuly Chat"),
        backgroundColor: const Color.fromRGBO(52, 88, 99, 1.0),),
      body: new Column(children: <Widget>[
        new Flexible(
          child: weddingId == null
              ? const Center(child: const CircularProgressIndicator()) :
          messageRef != null ?
          new FirebaseAnimatedList(
            query: messageRef,                                       //new
            sort: (a, b) => b.key.compareTo(a.key),                 //new
            padding: new EdgeInsets.all(8.0),                       //new
            reverse: true,                                          //new
            itemBuilder: (_, DataSnapshot snapshot, Animation<double> animation) { //new
              return new ChatMessage(                               //new
                snapshot: snapshot,                                 //new
                animation: animation, //new
              );                                                    //new
            },                                                      //new
          )
              : new Center(
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                new Icon(Icons.chrome_reader_mode,
                    color: Colors.grey, size: 60.0),
                new Text(
                  "No articles saved",
                  style: new TextStyle(
                      fontSize: 24.0, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        new Divider(height: 1.0),
        new Container(
          decoration: new BoxDecoration(
              color: Theme.of(context).cardColor),                  //new
          child: _buildTextComposer(),                       //modified
        ),                                                        //new
      ],                                                          //new
      ),                                                            //new
    );
  }

  Widget _buildTextComposer() {
    return new IconTheme(
      data: new IconThemeData(color: Theme.of(context).accentColor),
      child: new Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: new Row(
          children: <Widget>[
            new Flexible(
              child: new TextField(
                controller: _textController,
                onChanged: (String text) {          //new
                  setState(() {                     //new
                    _isComposing = text.length > 0; //new
                  });                               //new
                },                                  //new
                onSubmitted: _handleSubmitted,
                decoration:
                new InputDecoration.collapsed(hintText: "Send a message"),
              ),
            ),
            new Container(
              margin: new EdgeInsets.symmetric(horizontal: 4.0),
              child: new IconButton(
                icon: new Icon(Icons.send),
                onPressed: _isComposing
                    ? () => _handleSubmitted(_textController.text)    //modified
                    : null,                                           //modified
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmitted(String text) async {         //modified
    _textController.clear();
    setState(() {
      _isComposing = false;
    });
    await _ensureLoggedIn();                                       //new
    _sendMessage(text: text);                                      //new
  }

  void _sendMessage({ String text }) {
    print("entered send message");
    String dateTime = new DateTime.now().toIso8601String().substring(0, 19);
    dateTime = dateTime + "Z";
    String user = userID.toString();
    messageRef.push().set({
      'text': text,
      'from': user,
      'sendTime': dateTime,
      'readByStaff': staff,
      'readBy': {
        user: dateTime
      }
    });

    print("got through to end of send message");
  }

}

class ChatMessage extends StatefulWidget{
  ChatMessage({this.snapshot, this.animation});
  final DataSnapshot snapshot;
  final Animation animation;

  @override
  ChatMessageState createState() => new ChatMessageState(snapshot: this.snapshot, animation: this.animation);

}

class ChatMessageState extends State<ChatMessage> {
  ChatMessageState({this.snapshot, this.animation});
  final DataSnapshot snapshot;
  final Animation animation;

  String fromName;
  DataSnapshot nameRef;
  String firstLetter;
  String color;
  bool staff;

  String user = firebaseAuth.currentUser.uid;
  void getUsers() async{

    //checks whether or not a planner in order to color the circle by the message
    DataSnapshot plannerSnap = await FirebaseDatabase.instance.reference().child("planners").child(snapshot.value['from']).child('uid').once();
    String plannerName = plannerSnap.value;
    if(plannerName != null){
      color = 'planner';
    }

    String from = snapshot.value['from'];
    nameRef = await FirebaseDatabase.instance.reference().child("users").child(from).child('info').child('displayName').once();
    fromName = nameRef.value;

    if(fromName != null){
      if(fromName.isEmpty)
        firstLetter = ':)';
      else
        firstLetter = fromName[0];
    }
    if (this.mounted){
      setState(() {

      });
    }

  }

  @override
  initState(){
    super.initState();
    getUsers();

  }

  @override
  Widget build(BuildContext context) {

    return new SizeTransition(
      sizeFactor: new CurvedAnimation(
          parent: animation, curve: Curves.easeOut),
      axisAlignment: 0.0,
      child: fromName == null
    ? const Center(child: const CircularProgressIndicator()) :
    fromName != null ? new Container(                                    //modified
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        child: new Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Container(
              margin: const EdgeInsets.only(right: 16.0),
              child: new CircleAvatar(
                child: new Text(fromName == null ? '?' : firstLetter),
                backgroundColor: color == 'planner' ? const Color.fromRGBO(52, 88, 99, 1.0) : const Color.fromRGBO(223, 97, 31, 1.0),
                foregroundColor: Colors.white,
              ),
            ),
            new Expanded(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Text(fromName, style: Theme.of(context).textTheme.subhead),
                  new Container(
                    margin: const EdgeInsets.only(top: 5.0),
                    child: new Text(snapshot.value['text']),
                  ),
                ],
              ),
            ),
          ],
        ),
      ): new Center(
    child: new Column(
    mainAxisAlignment: MainAxisAlignment.center,
      children: [
        new Icon(Icons.chrome_reader_mode,
            color: Colors.grey, size: 60.0),
        new Text(
          "No chat",
          style: new TextStyle(
              fontSize: 24.0, color: Colors.grey),
        ),
      ],
    ),
    ),
    );

      }


    }
