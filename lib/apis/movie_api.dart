// @dart=2.9
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tmdb/constants/constants.dart';
import 'package:tmdb/datas/database_helper.dart';
import 'package:tmdb/models/movie.dart';
import 'package:http/http.dart' as http;
import 'package:tmdb/models/movie_detail_obj.dart';

class MovieApi {
  BuildContext context;
  MovieApi(context);

  Future<List<Movie>> getPopularMovies() async {
    List<Movie> list = [];

    String url = api + "popular?api_key=" + apiKey;

    http.Response response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      if (response.body != null && response.body != "") {
        Map<String, dynamic> map = json.decode(response.body);
        var obj = map['results'];
        for (var item in obj) {
          list.add(Movie.fromJson(item));
        }
        var data = jsonEncode(list.map((e) => e.toJson()).toList());
        DatabaseHelper.setData(popularKey, data);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Getting popular Movie Failed",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }

    return list;
  }

  Future<List<Movie>> getUpcomingMovies() async {
    List<Movie> list = [];

    String url = api + "upcoming?api_key=" + apiKey;

    http.Response response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      if (response.body != null && response.body != "") {
        Map<String, dynamic> map = json.decode(response.body);
        var obj = map['results'];
        for (var item in obj) {
          list.add(Movie.fromJson(item));
        }
        var data = jsonEncode(list.map((e) => e.toJson()).toList());
        DatabaseHelper.setData(popularKey, data);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Getting upcomming Movie Failed",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }

    return list;
  }

  Future<MovieDetailObj> getMovieDetail(String id, BuildContext context) async {
    MovieDetailObj movie = MovieDetailObj();
    String url = api + "$id?api_key=" + apiKey;

    http.Response response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      if (response.body != null && response.body != "") {
        Map<String, dynamic> map = json.decode(response.body);
        movie = MovieDetailObj.fromJson(map);
        var data = jsonEncode(movie);
        DatabaseHelper.setData(moviedetailKey, data);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Getting Movie Detail Failed",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
    return movie;
  }

  static changeFavorite(String key, String data) {
    DatabaseHelper.setData(key, data);
  }
}


  // static getOfflinePopularMovies() async {
  //   List<Movie> list = [];
  //   bool cacheExist = await APICacheManager().isAPICacheKeyExist("popular");
  //   if (cacheExist) {
  //     var cacheData = await APICacheManager().getCacheData("popular");
  //     if (cacheData.syncData != null && cacheData.syncData != "") {
  //       Map<String, dynamic> map = json.decode(cacheData.syncData);
  //       var obj = map['results'];
  //       for (var item in obj) {
  //         list.add(Movie.fromJson(item));
  //       }
  //     }
  //   }
  //   return list;
  // }

  // static getOfflineUpcomingMovies() async {
  //   List<Movie> list = [];

  //   return list;
  // }

  //       APICacheDBModel cacheDBModel =
  //           APICacheDBModel(key: "upcoming", syncData: response.body);
  //       APICacheManager().addCacheData(cacheDBModel);
