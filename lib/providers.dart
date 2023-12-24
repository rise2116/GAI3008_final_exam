import 'dart:typed_data';
import 'package:riverpod/riverpod.dart';

final restaurantsProvider =
    StateNotifierProvider<RestaurantNotifier, List<Restaurant>>((ref) {
  return RestaurantNotifier();
});
// 기존의 filteredRestaurantsProvider를 아래와 같이 수정합니다.
final filteredRestaurantsProvider = NotifierProvider.autoDispose<FilteredRestaurantsNotifier, List<Restaurant>>((ref) {
  return FilteredRestaurantsNotifier();
});


final searchTermProvider = Provider<String>((ref) => '');

final selectedCityProvider = Provider<String>((ref) => '');

List<Restaurant> _filterRestaurants(
    String searchTerm, List<Restaurant> restaurants) {
  return restaurants
      .where((restaurant) =>
          restaurant.name.toLowerCase().contains(searchTerm.toLowerCase()) ||
          restaurant.address.toLowerCase().contains(searchTerm.toLowerCase()) ||
          restaurant.phoneNumber
              .toLowerCase()
              .contains(searchTerm.toLowerCase()))
      .toList();
}

class FilteredRestaurantsNotifier extends Notifier<List<Restaurant>> {
  FilteredRestaurantsNotifier() : super([]);

  void updateFilteredRestaurants(List<Restaurant> filteredRestaurants) {
    state = filteredRestaurants;
  }
}

class RestaurantNotifier extends StateNotifier<List<Restaurant>> {
  RestaurantNotifier() : super([]);

  void addRestaurant(Restaurant restaurant) {
    state = [...state, restaurant];
  }

  void updateRestaurant(int index, Restaurant updatedRestaurant) {
    state = state
        .asMap()
        .map((i, r) =>
            i == index ? MapEntry(i, updatedRestaurant) : MapEntry(i, r))
        .values
        .toList();
  }

  void updateLikes(int index, int likes) {
    state = state
        .asMap()
        .map((i, r) =>
            i == index ? MapEntry(i, r.copyWith(likes: likes)) : MapEntry(i, r))
        .values
        .toList();
  }

  void setRestaurants(List<Restaurant> restaurants) {
    state = restaurants;
  }
}

class Restaurant {
  String name;
  int rating;
  String review;
  Uint8List? imageBytes;
  int likes;
  String address;
  String phoneNumber;

  Restaurant({
    required this.name,
    required this.rating,
    required this.review,
    this.imageBytes,
    this.likes = 0,
    required this.address,
    required this.phoneNumber,
  });

  Restaurant copyWith({
    String? name,
    int? rating,
    String? review,
    Uint8List? imageBytes,
    int? likes,
    String? address,
    String? phoneNumber,
  }) {
    return Restaurant(
      name: name ?? this.name,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      imageBytes: imageBytes ?? this.imageBytes,
      likes: likes ?? this.likes,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}

Future<List<String>> fetchCities(String pattern) async {
  await Future.delayed(Duration(milliseconds: 300));
  return [
    "서울",
    "부산",
    "대구",
    "인천",
    "광주",
    "대전",
    "울산",
    "세종",
    "경기",
    "강원",
    "충북",
    "충남",
    "전북",
    "전남",
    "경북",
    "경남",
    "제주"
  ]
      .where((city) => city.toLowerCase().contains(pattern.toLowerCase()))
      .toList();
}
