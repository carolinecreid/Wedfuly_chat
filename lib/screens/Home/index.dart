import "package:flutter/material.dart";
import "package:firebase_database/firebase_database.dart";
import 'package:firebase_database/ui/firebase_animated_list.dart';
import "package:firebase_auth/firebase_auth.dart";
import "dart:async";

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

  DataSnapshot weddingId;
  DatabaseReference messageRef;


  Future getData() async {
    weddingId = await FirebaseDatabase.instance.reference().child('users').child(userID).child('currentWedding').once();
    print(weddingId.value);
    messageRef = FirebaseDatabase.instance.reference().child('weddingChatMessages').child(weddingId.value);
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
    print("entered login checker");
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
    print(dateTime);
    messageRef.push().set({
      'text': text,
      'from': user,
      'sendTime': dateTime,
      //TODO fix this to actually pull in if staff or not
      'readByStaff': false,
      'readBy': {
        user: dateTime
      }
    });

    print("got through to end of send message)");

  }

}

class ChatMessage extends StatefulWidget{
  ChatMessage({this.snapshot, this.animation});
  final DataSnapshot snapshot;
  final Animation animation;

  DataSnapshot getSnapshot(){
    return this.snapshot;
  }
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

  List<String> planners = [
    '1IKpfKWzKSbMQzsm7caYHElGkAF3',
    'eVc7I7fyOWPEfZFCfKMoluXsttv1',
    'gOIew51tyHdCKcQxwzAMI9RmXem2',
    'iartVIOZcXYLr4KkCtl2tUFYTjf2',
    'pvsKSmBrIjUh5v8OhDD9sJIiLNl1',
    'RcjtySXVLqOpMtaRv03sbFgSsbp1',
    'UpyBJhK76EWaqqHdFNmjSZGNZKE2'
  ];
  String user = firebaseAuth.currentUser.uid;
  void getUsers() async{
    String from = snapshot.value['from'];
    nameRef = await FirebaseDatabase.instance.reference().child("users").child(from).child('info').child('displayName').once();
    fromName = nameRef.value;
    for(int i =0; i < planners.length; i ++){
      if (snapshot.value['from'] == planners[i]) {
        color = 'planner';
      }
    }
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
          "No articles saved",
          style: new TextStyle(
              fontSize: 24.0, color: Colors.grey),
        ),
      ],
    ),
    ),
    );

      }


    }
  //}
