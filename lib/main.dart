import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Google Books Encyclopedia',
      theme: new ThemeData(
        primaryColor: Color(0xFF232323),
      ),
      home: new MyHomePage(title: 'Google Books Encyclopedia'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class BookListItem extends StatefulWidget {
  const BookListItem({
    this.thumbnail,
    this.title,
    this.releaseDate,
    this.author,
  });

  final Widget thumbnail;
  final String title;
  final String releaseDate;
  final String author;

  @override
  _BookListItemState createState() => _BookListItemState();
}

class _BookListItemState extends State<BookListItem> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 18.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: widget.thumbnail,
          ),
          Expanded(
            flex: 3,
            child: _BookDescription(
              title: widget.title,
              releaseDate: widget.releaseDate,
              bookAuthor: widget.author,
            ),
          ),
          const Icon(
            Icons.more_vert,
            size: 16.0,
          ),
        ],
      ),
    );
  }
}

class _BookDescription extends StatelessWidget {
  const _BookDescription({
    Key key,
    this.title,
    this.releaseDate,
    this.bookAuthor,
  }) : super(key: key);

  final String title;
  final String releaseDate;
  final String bookAuthor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18.0, 0.0, 0.0, 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '$title.',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 16.0,
            ),
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 8.0)),
          Text(
            'Author: $bookAuthor \n',
            style: const TextStyle(
              fontSize: 12.0,
              color: Colors.green,
            ),
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 1.0)),
          Text(
            'Release date: $releaseDate',
            style: const TextStyle(
              fontSize: 12.0,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController controller = new TextEditingController();
  String googleAPIURL = "https://www.googleapis.com/books/v1/volumes?q=Programming";
  String userSearch = "";

  Future<List<Book>> _getUsers() async {
    var data = await http.get(googleAPIURL + userSearch);
    print(googleAPIURL + userSearch);

    var jsonData = json.decode(data.body);
    List<Book> books = [];
    print(jsonData["items"]);
    for (var b in jsonData["items"]) {
      Book book = new Book(
          b["volumeInfo"]["authors"][0],
          b["volumeInfo"]["title"],
          b["volumeInfo"]["publisher"],
          b["volumeInfo"]["publishedDate"],
          b["volumeInfo"]["imageLinks"]["thumbnail"]);

      print(book);
      books.add(book);
    }

    //print(books);
    return books;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          widget.title,
          style: TextStyle(color: Colors.green),
        ),
        leading: Container(
          child: new Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 5.0, 0.0, 0.0),
            child: Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: NetworkImage(
                            "https://aace-site-static.s3.amazonaws.com/wp-content/uploads/2018/04/Book-Icon.png")))),
          ),
        ),
        elevation: 0.0,
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            new Container(
              color: Theme.of(context).primaryColor,
              child: new Padding(
                padding: const EdgeInsets.all(6.0),
                child: new Card(
                    color: Color(0xFF333333),
                  child: new ListTile(
                    leading: new Icon(Icons.search, color: Colors.green),
                    title: new TextField(
                      style: TextStyle(color: Colors.white70),
                      controller: controller,
                      decoration: new InputDecoration(
                          fillColor: Colors.blue,
                          hintText: 'Search for a book title',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none),
                      onSubmitted: (String userInput) {
                        setState(() {
                          googleAPIURL =
                              "https://www.googleapis.com/books/v1/volumes?q=";
                          userSearch = userInput.replaceAll(' ', '+');
                        });
                      },
                    ),
                    trailing: new IconButton(
                      icon: new Icon(Icons.cancel, color: Colors.red),
                      onPressed: () {
                        controller.clear();
                      },
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.black87,
                child: FutureBuilder(
                  future: _getUsers(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    print(snapshot.data);

                    if (snapshot.data == null && snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: Container(
                            width: 160,
                            height: 150,
                            child: Column(
                              children: <Widget>[
                                SizedBox(
                                  child: CircularProgressIndicator(valueColor:  new AlwaysStoppedAnimation<Color>(Colors.green),),
                                  width: 80,
                                  height: 80,
                                ),

                                const Padding(
                                  padding: EdgeInsets.only(top: 20),
                                  child: Text('Fetching Book List...', style: TextStyle(color: Colors.white),),
                                )

                              ],
                            )),
                      );
                    }
                    else if(snapshot.data == null){
                      return Center(
                        child: Container(
                            width: 280,
                            height: 250,
                            child: Column(
                              children: <Widget>[
                                Container(
                                  height: 120,
                                  width: 100,
                                  child: Image.network(
                                              "https://icon-library.com/images/white-magnifying-glass-icon-png/white-magnifying-glass-icon-png-0.jpg"),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(top: 20),
                                  child: Text('Sorry we do not have books for that title. Please try a different search.', style: TextStyle(color: Colors.white), textAlign: TextAlign.center,),
                                )

                              ],
                            )),
                      );
                    }
                    else {
                      return ListView.builder(
                        itemExtent: 173.0,
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index) {
                          return Card(
                            color: Color(0xFF111112),
                            elevation: 10,
                            child: BookListItem(
                              releaseDate: snapshot.data[index].publishedDate,
                              author: snapshot.data[index].index,
                              thumbnail: Container(
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        fit: BoxFit.fill,
                                        image: NetworkImage(
                                            snapshot.data[index].picture)),
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(8.0))),
                              ),
                              title: snapshot.data[index].title,
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Book {
  final String index;
  final String title;
  final String author;
  final String publishedDate;
  final String picture;

  Book(this.index, this.title, this.author, this.publishedDate, this.picture);
}
