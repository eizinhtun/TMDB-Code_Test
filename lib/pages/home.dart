import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:tmdb/constants/constants.dart';
import 'package:tmdb/datas/database_helper.dart';
import 'package:tmdb/models/movie.dart';
import 'package:tmdb/pages/movie_detail.dart';
import 'dart:async';
import 'package:tmdb/providers/movie_provider.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Movie> popularMovies = [];
  List<Movie> upcomingMovies = [];

  final TextEditingController _searchController = TextEditingController();

  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    getFavoriteMap();
    getOfflineMovies();
    initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((ConnectivityResult result) async {
      if (result != ConnectivityResult.none) {
        getMovies();
      } else {
        getOfflineMovies();
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> initConnectivity() async {
    late ConnectivityResult result;

    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      return;
    }

    if (!mounted) {
      return Future.value(null);
    }
  }

  Map<String, bool> isFavoriteMap = {};

  getOfflineMovies() async {
    popularMovies =
        await context.read<MovieProvider>().getOfflinePopularList(context);
    upcomingMovies =
        await context.read<MovieProvider>().getOfflineUpcommingList(context);
  }

  getMovies() async {
    popularMovies = await context.read<MovieProvider>().getPopularList(context);

    upcomingMovies =
        await context.read<MovieProvider>().getUpcommingList(context);
  }

  getFavoriteMap() async {
    isFavoriteMap = await context.read<MovieProvider>().getFavoriteMap(context);
  }

  @override
  Widget build(BuildContext context) {
    isFavoriteMap = context.watch<MovieProvider>().isFavoriteMap;
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            padding: const EdgeInsets.only(
              left: 16,
              top: 30,
              right: 16,
              bottom: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  "What are you looking for ?",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[50],
                    prefixIcon: const Icon(
                      Icons.search,
                    ),
                    hintText: "Search for movies, events & more...",
                    border: InputBorder.none,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Movies",
                          style: TextStyle(
                            color: Colors.grey[850],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          width: 30,
                          height: 3,
                          color: Colors.blue,
                        )
                      ],
                    ),
                    Text(
                      "Events",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Plays",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Sports",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Activities",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  "Recommended",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                (context.watch<MovieProvider>().isPopularList)
                    ? SizedBox(
                        height: MediaQuery.of(context).size.height,
                        child: const Center(
                          child: SpinKitChasingDots(
                            color: Colors.blue,
                            size: 50.0,
                          ),
                        ),
                      )
                    : (popularMovies.isNotEmpty)
                        ? SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: popularMovies.map((movie) {
                                double vote = movie.voteAverage! * 10;
                                String voteStr = vote.floor().toString() + " %";

                                return InkWell(
                                  onTap: () async {
                                    await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              MovieDetail(
                                            id: movie.id.toString(),
                                          ),
                                        ));
                                  },
                                  child: SizedBox(
                                    width: 120,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Card(
                                          elevation: 2,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          child: OptimizedCacheImage(
                                            height: 150,
                                            width: 120,
                                            imageUrl: imgPath +
                                                movie.posterPath.toString(),
                                            progressIndicatorBuilder: (context,
                                                    url, downloadProgress) =>
                                                CircularProgressIndicator(
                                                    value: downloadProgress
                                                        .progress),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(Icons.error),
                                          ),
                                        ),
                                        Text(movie.title.toString()),
                                        Row(
                                          children: [
                                            IconButton(
                                              onPressed: () async {
                                                bool value = false;
                                                if (isFavoriteMap[
                                                        movie.id.toString()] ==
                                                    null) {
                                                  value = true;
                                                } else {
                                                  bool tempValue =
                                                      isFavoriteMap[
                                                          movie.id.toString()]!;
                                                  value = !tempValue;
                                                }
                                                Map<String, bool> tempMap =
                                                    isFavoriteMap;
                                                tempMap[movie.id.toString()] =
                                                    value;

                                                isFavoriteMap = tempMap;

                                                DatabaseHelper.setData(
                                                    favoriteKey,
                                                    jsonEncode(isFavoriteMap));
                                                isFavoriteMap = await context
                                                    .read<MovieProvider>()
                                                    .getFavoriteMap(context);
                                              },
                                              icon: (isFavoriteMap[movie.id
                                                          .toString()] ==
                                                      true)
                                                  ? const Icon(
                                                      Icons.favorite,
                                                      color: Colors.red,
                                                    )
                                                  : const Icon(
                                                      Icons
                                                          .favorite_border_outlined,
                                                      color: Colors.red,
                                                    ),
                                            ),
                                            Text(voteStr),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          )
                        : SizedBox(
                            height: MediaQuery.of(context).size.height,
                            child: const Center(
                              child: Text(
                                "There is no popular movies.",
                              ),
                            )),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  "Upcomming Movies",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                (context.watch<MovieProvider>().isUpcommingList)
                    ? SizedBox(
                        height: MediaQuery.of(context).size.height,
                        child: const Center(
                          child: SpinKitChasingDots(
                            color: Colors.blue,
                            size: 50.0,
                          ),
                        ),
                      )
                    : (upcomingMovies.isNotEmpty)
                        ? SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Column(
                              children: upcomingMovies.map((movie) {
                                double vote = movie.voteAverage! * 10;
                                String voteStr = vote.floor().toString() + " %";
                                return InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              MovieDetail(
                                                  id: movie.id.toString()),
                                        ));
                                  },
                                  child: Row(
                                    children: [
                                      Card(
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        child: OptimizedCacheImage(
                                          height: 150,
                                          width: 120,
                                          imageUrl: imgPath +
                                              movie.posterPath.toString(),
                                          progressIndicatorBuilder: (context,
                                                  url, downloadProgress) =>
                                              CircularProgressIndicator(
                                                  value: downloadProgress
                                                      .progress),
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.error),
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              movie.title.toString(),
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 8,
                                            ),
                                            Text(
                                              movie.overview.toString(),
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 11,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 8,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                IconButton(
                                                  onPressed: () async {
                                                    bool value = false;
                                                    if (isFavoriteMap[movie.id
                                                            .toString()] ==
                                                        null) {
                                                      value = true;
                                                    } else {
                                                      bool tempValue =
                                                          isFavoriteMap[movie.id
                                                              .toString()]!;
                                                      value = !tempValue;
                                                    }
                                                    Map<String, bool> tempMap =
                                                        isFavoriteMap;
                                                    tempMap[movie.id
                                                        .toString()] = value;

                                                    isFavoriteMap = tempMap;

                                                    DatabaseHelper.setData(
                                                        favoriteKey,
                                                        jsonEncode(
                                                            isFavoriteMap));
                                                    isFavoriteMap =
                                                        await context
                                                            .read<
                                                                MovieProvider>()
                                                            .getFavoriteMap(
                                                                context);
                                                  },
                                                  icon: (isFavoriteMap[movie.id
                                                              .toString()] ==
                                                          true)
                                                      ? const Icon(
                                                          Icons.favorite,
                                                          color: Colors.red,
                                                        )
                                                      : const Icon(
                                                          Icons
                                                              .favorite_border_outlined,
                                                          color: Colors.red,
                                                        ),
                                                ),
                                                Text(voteStr),
                                                const SizedBox(
                                                  width: 16,
                                                ),
                                                Icon(
                                                  Icons.message_outlined,
                                                  color: Colors.amber[200],
                                                ),
                                                const SizedBox(
                                                  width: 2,
                                                ),
                                                const Text("9K"),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          )
                        : SizedBox(
                            height: MediaQuery.of(context).size.height,
                            child: const Center(
                              child: Text(
                                "There is no upcoming movies.",
                              ),
                            )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
