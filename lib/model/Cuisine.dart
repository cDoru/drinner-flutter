import 'dart:ui';

import 'package:flutter/material.dart';

class Cuisine {
  const Cuisine._(this.group, this.image);

  final CuisineType group;
  final String image;
  Color get color => group.color;

  static const VEGAN = Cuisine._(CuisineType.HEALTHY, 'brocooli');
  static const VEGETARIAN = Cuisine._(CuisineType.HEALTHY, 'groceries');
  static const SUSHI = Cuisine._(CuisineType.ASIAN, 'sushi-1');
  static const REGIONAL = Cuisine._(CuisineType.OTHER, 'kitchen');
  static const POLISH = Cuisine._(CuisineType.EUROPEAN, 'sausage');
  static const JAPANESE = Cuisine._(CuisineType.ASIAN, 'sushi-1');
  static const KOREAN = Cuisine._(CuisineType.ASIAN, 'rice');
  static const ITALIAN = Cuisine._(CuisineType.EUROPEAN, 'pasta-1');
  static const PANCAKES = Cuisine._(CuisineType.OTHER, 'pancakes');
  static const ASIAN = Cuisine._(CuisineType.ASIAN, 'rice');
  static const UNKNOWN = Cuisine._(CuisineType.OTHER, 'cutlery');
}

class CuisineType {
  const CuisineType._(this.color);

  final Color color;

  static const HEALTHY = CuisineType._(Colors.green);
  static const EUROPEAN = CuisineType._(Colors.blue);
  static const ASIAN = CuisineType._(Colors.orange);
  static const OTHER = CuisineType._(Colors.lime);
}
