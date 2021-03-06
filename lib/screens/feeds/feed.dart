import 'package:flutter/material.dart';
import 'package:game_explorer_flutter/models/feed.dart';
import 'package:game_explorer_flutter/services/igdb_service.dart';
import 'local_widgets/feed_item.dart';

class Feeds extends StatefulWidget {
  Feeds({Key key}) : super(key: key);

  @override
  _FeedsState createState() => _FeedsState();
}

class _FeedsState extends State<Feeds> {
  ScrollController _controller;
  List<Feed> _feeds = new List();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    this._updateFeeds();
    _controller = new ScrollController()..addListener(_scrollListener);
  }

  @override
  void dispose() {
    _controller.removeListener(_scrollListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: _feeds.isEmpty
          ? Align(child: CircularProgressIndicator(), alignment: Alignment.center)
          : RefreshIndicator(
              child: ListView.builder(
                controller: _controller,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.all(20.0),
                    child: FeedItem(feed: _feeds[index]),
                  );
                },
                itemCount: _feeds.length,
              ),
              onRefresh: _refresh,
            ),
    );
  }

  void _scrollListener() {
    if (_controller.offset >= _controller.position.maxScrollExtent && !_controller.position.outOfRange) {
      this._updateFeeds();
    }
  }

  void _updateFeeds() {
    IgdbService.fetchFeeds(_currentPage).then((response) {
      setState(() => _feeds.addAll(response));
      _currentPage++;
    });
  }

  Future<void> _refresh() async {
    setState(() {
      _feeds.clear();
    });
    _currentPage = 0;
    _updateFeeds();
  }
}
