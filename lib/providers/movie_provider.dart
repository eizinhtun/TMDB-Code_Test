// @dart=2.9
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tmdb/apis/movie_api.dart';
import 'package:tmdb/constants/constants.dart';
import 'package:tmdb/datas/database_helper.dart';
import 'package:tmdb/models/movie.dart';
import 'package:tmdb/models/movie_detail_obj.dart';

class MovieProvider with ChangeNotifier, DiagnosticableTreeMixin {
  MovieApi _api;

  List<Movie> _popularList;
  List<Movie> get popularList => _popularList;

  bool _isPopularList = false;
  bool get isPopularList => _isPopularList;

  List<Movie> _upcommingList;
  List<Movie> get upcommingDList => _upcommingList;

  bool _isUpcommingList = false;
  bool get isUpcommingList => _isUpcommingList;

  MovieDetailObj _movieDetail;
  MovieDetailObj get movieDetail => _movieDetail;

  bool _isMovieDetail = true;
  bool get isMovieDetail => _isMovieDetail;

  Map<String, bool> _isFavoriteMap = {};
  Map<String, bool> get isFavoriteMap => _isFavoriteMap;

  Future<List<Movie>> getPopularList(BuildContext context) async {
    _isPopularList = true;
    // notifyListeners();

    var rawData = await DatabaseHelper.getData(popularKey);
    if (rawData != null && rawData != "") {
      _popularList = [];
      var obj = json.decode(rawData);
      for (var item in obj) {
        _popularList.add(Movie.fromJson(item));
      }
      _isPopularList = false;
      notifyListeners();
    }
    _api = MovieApi(context);
    _popularList = await _api.getPopularMovies();
    _isPopularList = false;
    notifyListeners();
    return _popularList;
  }

  Future<List<Movie>> getOfflinePopularList(BuildContext context) async {
    _isPopularList = true;
    // notifyListeners();

    var rawData = await DatabaseHelper.getData(popularKey);
    if (rawData != null && rawData != "") {
      _popularList = [];
      var obj = json.decode(rawData);
      for (var item in obj) {
        _popularList.add(Movie.fromJson(item));
      }
      _isPopularList = false;
      notifyListeners();
    }
    return _popularList;
  }

  Future<List<Movie>> getOfflineUpcommingList(BuildContext context) async {
    _isUpcommingList = true;
    // notifyListeners();

    var rawData = await DatabaseHelper.getData(upcommingKey);
    if (rawData != null && rawData != "") {
      _upcommingList = [];
      var obj = json.decode(rawData);
      for (var item in obj) {
        _upcommingList.add(Movie.fromJson(item));
      }
      _isUpcommingList = false;
      notifyListeners();
    }
    return _upcommingList;
  }

  Future<List<Movie>> getUpcommingList(BuildContext context) async {
    _isUpcommingList = true;
    // notifyListeners();

    var rawData = await DatabaseHelper.getData(upcommingKey);
    if (rawData != null && rawData != "") {
      _upcommingList = [];
      var obj = json.decode(rawData);
      for (var item in obj) {
        _upcommingList.add(Movie.fromJson(item));
      }
      _isUpcommingList = false;
      notifyListeners();
    }
    _api = MovieApi(context);
    _upcommingList = await _api.getUpcomingMovies();
    _isUpcommingList = false;
    notifyListeners();
    return _upcommingList;
  }

  Future<MovieDetailObj> getMovieDetail(String id, BuildContext context) async {
    _isMovieDetail = true;
    // notifyListeners();

    // var rawData = await DatabaseHelper.getData(moviedetailKey);

    // if (rawData != null && rawData != "") {
    //   _movieDetail = MovieDetailObj();
    //   var obj = json.decode(rawData);
    //   _movieDetail = MovieDetailObj.fromJson(obj);
    //   _isMovieDetail = false;
    //   notifyListeners();
    // }
    _api = MovieApi(context);
    _movieDetail = await _api.getMovieDetail(id, context);
    _isMovieDetail = false;
    notifyListeners();
    return _movieDetail;
  }

  Future<MovieDetailObj> getOfflineMovieDetail(
      String id, BuildContext context) async {
    _isMovieDetail = true;
    notifyListeners();

    var rawData = await DatabaseHelper.getData(moviedetailKey);
    if (rawData != null && rawData != "") {
      _movieDetail = MovieDetailObj();
      var obj = json.decode(rawData);
      _movieDetail = MovieDetailObj.fromJson(obj);
      _isMovieDetail = false;
      notifyListeners();
    }
    return _movieDetail;
  }

  Future<Map<String, bool>> getFavoriteMap(BuildContext context) async {
    String data = await DatabaseHelper.getData(favoriteKey);
    if (data != null) {
      Map<String, dynamic> obj = json.decode(data);
      obj.entries.forEach((e) {
        _isFavoriteMap[e.key] = e.value;
      });
      notifyListeners();
      return _isFavoriteMap;
    }
    return _isFavoriteMap;
  }
}
