import 'dart:convert';
import 'package:tmdb/providers/movie_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:tmdb/constants/constants.dart';
import 'package:tmdb/datas/database_helper.dart';
import 'package:tmdb/models/movie_detail_obj.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'dart:async';

class MovieDetail extends StatefulWidget {
  const MovieDetail({
    Key? key,
    required this.id,
  }) : super(key: key);
  final String id;

  @override
  _MovieDetailState createState() => _MovieDetailState();
}

class _MovieDetailState extends State<MovieDetail> {
  MovieDetailObj movie = MovieDetailObj();
  Map<String, bool> isFavoriteMap = {};

  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();

  @override
  void initState() {
    super.initState();
    // getOfflineMovieDetail();
    getFavoriteMap();
    checkInternet();
  }

  Future<void> checkInternet() async {
    var result = await _connectivity.checkConnectivity();
    if (result != ConnectivityResult.none) {
      getMovieDetail();
    } else {
      // getOfflineMovieDetail();
    }
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

    return null;
  }

  getFavoriteMap() async {
    isFavoriteMap = await context.read<MovieProvider>().getFavoriteMap(context);
  }

  String voteStr = "";

  getOfflineMovieDetail() async {
    movie = await context
        .read<MovieProvider>()
        .getOfflineMovieDetail(widget.id, context);
    double vote = movie.voteAverage! * 10;
    voteStr = vote.floor().toString() + " %";
  }

  getMovieDetail() async {
    movie =
        await context.read<MovieProvider>().getMovieDetail(widget.id, context);
    double vote = movie.voteAverage! * 10;
    voteStr = vote.floor().toString() + " %";
  }

  @override
  Widget build(BuildContext context) {
    isFavoriteMap = context.watch<MovieProvider>().isFavoriteMap;

    String? genres = movie.genres?.map((g) => g.name).toList().join(", ");
    String? langs =
        movie.spokenLanguages?.map((e) => e.name).toList().join(",");

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: (context.watch<MovieProvider>().isMovieDetail)
              ? SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: const Center(
                    child: SpinKitChasingDots(
                      color: Colors.blue,
                      size: 50.0,
                    ),
                  ),
                )
              : (movie.id != null)
                  ? Container(
                      margin: EdgeInsets.zero,
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(35.0),
                                ),
                                child: Container(
                                  height: 400,
                                  width: 400,
                                  decoration: BoxDecoration(
                                    border: Border.all(),
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(20),
                                    ),
                                    image: DecorationImage(
                                      image: OptimizedCacheImageProvider(
                                        movie.posterPath == null
                                            ? "http://via.placeholder.com/350x150"
                                            : imgPath +
                                                movie.posterPath.toString(),
                                        maxHeight: 400,
                                        maxWidth: 400,
                                      ),
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 16,
                                left: 8,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.arrow_back_ios,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              const SizedBox(
                                height: 16,
                              ),
                              Container(
                                margin: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            movie.title.toString(),
                                            style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
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
                                            const SizedBox(
                                              width: 2,
                                            ),
                                            Text(voteStr)
                                          ],
                                        )
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          movie.releaseDate.toString(),
                                          style: const TextStyle(
                                              color: Colors.black54,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text("${movie.voteCount} votes")
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            "${movie.runtime} min | $genres",
                                            style: const TextStyle(
                                                color: Colors.blue,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Text("$langs"),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    const Text(
                                      "Movie description",
                                      style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            movie.overview.toString(),
                                            style: const TextStyle(
                                              color: Colors.black87,
                                              wordSpacing: 1,
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    )
                  : SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: Scaffold(
                        appBar: AppBar(
                          backgroundColor: Colors.orange,
                        ),
                        body: const Center(
                          child: Text(
                            "There is no movie detail.",
                          ),
                        ),
                      )),
        ),
      ),
    );
  }
}
