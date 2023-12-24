import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

void main() {
  runApp(MyRestaurantApp());
}

class Restaurant {
  String name;
  int rating;
  String review;
  Uint8List? imageBytes;
  int likes;
  String address; // 住所を追加
  String phoneNumber; // 電話番号を追加

  Restaurant({
    required this.name,
    required this.rating,
    required this.review,
    this.imageBytes,
    this.likes = 0,
    required this.address,
    required this.phoneNumber,
  });
}

class MyRestaurantApp extends StatelessWidget {
  final List<Restaurant> restaurants = [];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '식당 목록 앱',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: MainScreen(restaurants: restaurants),
    );
  }
}

class MainScreen extends StatefulWidget {
  final List<Restaurant> restaurants;

  MainScreen({required this.restaurants});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('식당 목록'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromRGBO(247, 179, 227, 1),
              ),
              child: Text(
                '메뉴',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('식당 목록'),
              selected: _selectedIndex == 0,
              onTap: () {
                setState(() {
                  _selectedIndex = 0;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('새로운 식당 추가'),
              selected: _selectedIndex == 1,
              onTap: () {
                setState(() {
                  _selectedIndex = 1;
                });
                Navigator.pop(context);
                _navigateToAddRestaurant(context);
              },
            ),
            ListTile(
              title: Text('랭킹'),
              selected: _selectedIndex == 2,
              onTap: () {
                setState(() {
                  _selectedIndex = 2;
                });
                Navigator.pop(context);
                // TODO: 설정 화면으로 이동
              },
            ),
            ListTile(
              title: Text('마이페이지'),
              selected: _selectedIndex == 3,
              onTap: () {
                setState(() {
                  _selectedIndex = 3;
                });
                Navigator.pop(context);
                // TODO: 도움말 화면으로 이동
              },
            ),
          ],
        ),
      ),
      body: _getBody(),
    );
  }

  Widget _getBody() {
    switch (_selectedIndex) {
      case 0:
        // 既存의 코드
        return RestaurantListScreen(
          restaurants: widget.restaurants,
          onLikeButtonPressed: _onLikeButtonPressed,
          onEditPressed: _onEditPressed,
        );
      case 1:
        // 既存의 코드
        return AddRestaurantScreen(onRestaurantAdded: _onRestaurantAdded);
      case 2:
        // ランキング의 코드
        List<Restaurant> rankedRestaurants = List.from(widget.restaurants);
        rankedRestaurants.sort((a, b) => b.rating.compareTo(a.rating));

        return Column(
          children: [
            // 랭킹을 표시하는 부분
            for (int i = 0; i < rankedRestaurants.length; i++)
              ListTile(
                title: Text('${i + 1}. ${rankedRestaurants[i].name}'),
                subtitle: Text('평점: ${rankedRestaurants[i].rating}'),
                // その他の情報も表示できれば追加
              ),
            // 랭킹 리스트
            Expanded(
              child: RestaurantListScreen(
                restaurants: rankedRestaurants,
                onLikeButtonPressed: _onLikeButtonPressed,
                onEditPressed: _onEditPressed,
              ),
            ),
          ],
        );
      default:
        return Center(
          child: Text('Not implemented'),
        );
    }
  }

  void _onRestaurantAdded(Restaurant newRestaurant) {
    setState(() {
      widget.restaurants.add(newRestaurant);
    });

    // Show a snackbar with an animation
    final snackBar = SnackBar(
      content: Text('식당이 추가되었습니다'),
      action: SnackBarAction(
        label: '확인',
        onPressed: () {},
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _navigateToAddRestaurant(BuildContext context) async {
    Restaurant? newRestaurant = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddRestaurantScreen(onRestaurantAdded: _onRestaurantAdded),
      ),
    );

    if (newRestaurant != null) {
      _onRestaurantAdded(newRestaurant);
    }
  }

  void _onLikeButtonPressed(int index) {
    setState(() {
      widget.restaurants[index].likes++;
    });
  }

  void _onEditPressed(int index) async {
    Restaurant? editedRestaurant = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditRestaurantScreen(
          restaurant: widget.restaurants[index],
        ),
      ),
    );

    if (editedRestaurant != null) {
      setState(() {
        widget.restaurants[index] = editedRestaurant;
      });
    }
  }
}

class RestaurantListScreen extends StatefulWidget {
  final List<Restaurant> restaurants;
  final Function(int) onLikeButtonPressed;
  final Function(int) onEditPressed;

  RestaurantListScreen({
    required this.restaurants,
    required this.onLikeButtonPressed,
    required this.onEditPressed,
  });

  @override
  _RestaurantListScreenState createState() => _RestaurantListScreenState();
}

class _RestaurantListScreenState extends State<RestaurantListScreen> {
  TextEditingController searchController =
      TextEditingController(); // 검색을 위한 컨트롤러
  List<Restaurant> filteredRestaurants = []; // 검색 결과를 저장하는 리스트

  @override
  void initState() {
    super.initState();
    filteredRestaurants = widget.restaurants;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              _showSearchDialog(context);
            },
          ),
        ],
      ),
      body: RestaurantListWidget(
        restaurants: filteredRestaurants,
        onLikeButtonPressed: widget.onLikeButtonPressed,
        onEditPressed: widget.onEditPressed,
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('검색'),
          content: TextField(
            controller: searchController,
            decoration: InputDecoration(labelText: '검색어를 입력하세요'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _performSearch();
              },
              child: Text('검색'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('취소'),
            ),
          ],
        );
      },
    );
  }

  void _performSearch() {
    String searchTerm = searchController.text.toLowerCase();
    setState(() {
      filteredRestaurants = widget.restaurants
          .where((restaurant) =>
              restaurant.name.toLowerCase().contains(searchTerm) ||
              restaurant.address.toLowerCase().contains(searchTerm) ||
              restaurant.phoneNumber.toLowerCase().contains(searchTerm))
          .toList();
    });
  }
}

class RestaurantListWidget extends StatelessWidget {
  final List<Restaurant> restaurants;
  final Function(int) onLikeButtonPressed;
  final Function(int) onEditPressed;

  RestaurantListWidget({
    required this.restaurants,
    required this.onLikeButtonPressed,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, // 4개의 열로 설정
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: restaurants.length,
      itemBuilder: (context, index) {
        return RestaurantListItem(
          restaurant: restaurants[index],
          onLikeButtonPressed: () {
            onLikeButtonPressed(index);
          },
          onEditPressed: () {
            onEditPressed(index);
          },
        );
      },
    );
  }
}

class RestaurantListItem extends StatelessWidget {
  final Restaurant restaurant;
  final VoidCallback onEditPressed;
  final VoidCallback onLikeButtonPressed;

  RestaurantListItem({
    required this.restaurant,
    required this.onEditPressed,
    required this.onLikeButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0), // 둥근 정도 조절
      ),
      elevation: 5.0, // 그림자 효과 강조
      color: Color.fromARGB(255, 255, 255, 255),
      // 가장자리에 색상 입히기
      child: Container(
        child: InkWell(
          onTap: () {
            _navigateToRestaurantDetail(context); // 상세 페이지로 이동
          },
          child: Container(
            width: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: restaurant.imageBytes != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.memory(
                              restaurant.imageBytes!,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(Icons.restaurant),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                restaurant.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  fontFamily: 'YourDesiredFont',
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: onEditPressed,
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.thumb_up),
                                onPressed: onLikeButtonPressed,
                              ),
                              Text('${restaurant.likes} 좋아요'),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 8), // 평점과 주소 사이 간격 추가
                      Row(
                        children: [
                          RatingBar.builder(
                            initialRating: restaurant.rating.toDouble(),
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemSize: 30,
                            itemBuilder: (context, _) => Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: (rating) {
                              // 여기서 평점 업데이트 로직을 수행할 수 있습니다.
                            },
                          ),
                          SizedBox(width: 5), // 아이콘과 숫자 사이에 간격 추가
                          Text(
                            '${restaurant.rating}', // 평점을 숫자로 표시
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8), // 주소와 다음 텍스트 사이 간격 추가
                      Text('주소: ${restaurant.address}'),
                      Text('전화번호: ${restaurant.phoneNumber}'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToRestaurantDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantDetailScreen(restaurant: restaurant),
      ),
    );
  }
}

class AddRestaurantScreen extends StatefulWidget {
  final Function(Restaurant) onRestaurantAdded;

  AddRestaurantScreen({required this.onRestaurantAdded});

  @override
  _AddRestaurantScreenState createState() => _AddRestaurantScreenState();
}

class _AddRestaurantScreenState extends State<AddRestaurantScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController reviewController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  int? _rating;
  Uint8List? _imageBytes;

  Future _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageBytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = imageBytes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('새로운 식당 추가'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_imageBytes != null) ...[
              Image.memory(
                _imageBytes!,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
            ],
            ElevatedButton(
              onPressed: () {
                _pickImage();
              },
              child: Text('사진 선택'),
            ),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: '식당 이름'),
            ),
            SizedBox(height: 16.0),
            Row(
              children: [
                Text('평점: '),
                for (int i = 1; i <= 5; i++)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _rating = i;
                      });
                    },
                    child: Text('$i'),
                    style: ElevatedButton.styleFrom(
                      primary: _rating == i ? Colors.green : null,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: reviewController,
              decoration: InputDecoration(labelText: '리뷰'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: addressController,
              decoration: InputDecoration(labelText: '주소'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: phoneNumberController,
              decoration: InputDecoration(labelText: '전화번호'),
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                String name = nameController.text;
                String review = reviewController.text;
                String address = addressController.text;
                String phoneNumber = phoneNumberController.text;

                if (_rating != null) {
                  Restaurant newRestaurant = Restaurant(
                    name: name,
                    rating: _rating!,
                    review: review,
                    imageBytes: _imageBytes,
                    address: address,
                    phoneNumber: phoneNumber,
                  );

                  widget.onRestaurantAdded(newRestaurant);

                  // 여기에서 상태를 갱신하여 화면이 업데이트되도록 합니다.
                  setState(() {
                    nameController.clear();
                    reviewController.clear();
                    addressController.clear();
                    phoneNumberController.clear();
                    _rating = null;
                    _imageBytes = null;
                  });
                }
              },
              child: Text('추가'),
            ),
          ],
        ),
      ),
    );
  }
}

class RestaurantDetailScreen extends StatelessWidget {
  final Restaurant restaurant;

  RestaurantDetailScreen({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('식당 상세 정보'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 200,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8.0),
                bottomRight: Radius.circular(8.0),
              ),
              child: restaurant.imageBytes != null
                  ? Image.memory(
                      restaurant.imageBytes!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : _buildDefaultImage(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '식당 이름: ${restaurant.name}',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          '평점: ',
                          style: TextStyle(fontSize: 18),
                        ),
                        RatingBar.builder(
                          initialRating: restaurant.rating.toDouble(),
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemSize: 30,
                          itemBuilder: (context, _) => Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          onRatingUpdate: (rating) {
                            // 평점 업데이트 로직을 수행할 수 있습니다.
                          },
                        ),
                        SizedBox(width: 5),
                        Text(
                          '${restaurant.rating}',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.thumb_up),
                          onPressed: () {
                            // 좋아요 버튼이 눌렸을 때 수행할 동작을 추가하세요.
                          },
                        ),
                        Text(
                          '${restaurant.likes} 좋아요',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                Text(
                  '주소: ${restaurant.address}',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 16.0),
                Text(
                  '전화번호: ${restaurant.phoneNumber}',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 16.0),
                Text(
                  '리뷰: ${restaurant.review}',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultImage() {
    return Container(
      color: Colors.grey, // 디폴트 이미지의 배경색 설정
      child: Center(
        child: Icon(
          Icons.restaurant,
          size: 100,
          color: Colors.white,
        ),
      ),
    );
  }
}

class EditRestaurantScreen extends StatefulWidget {
  final Restaurant restaurant;

  EditRestaurantScreen({required this.restaurant});

  @override
  _EditRestaurantScreenState createState() => _EditRestaurantScreenState();
}

class _EditRestaurantScreenState extends State<EditRestaurantScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController reviewController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  int? _rating;
  Uint8List? _imageBytes;

  // fetchCities 메소드 추가
  Future<List<String>> fetchCities(String pattern) async {
    // 여기에서 실제 도시 목록을 가져오거나 API 호출을 수행합니다.
    // pattern을 기반으로 검색 결과를 가져와서 반환합니다.
    // 이는 가상의 예시입니다.
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
    ];
  }

  @override
  void initState() {
    super.initState();

    nameController.text = widget.restaurant.name;
    reviewController.text = widget.restaurant.review;
    addressController.text = widget.restaurant.address;
    phoneNumberController.text = widget.restaurant.phoneNumber;
    _rating = widget.restaurant.rating;
    _imageBytes = widget.restaurant.imageBytes;
  }

  Future _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageBytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = imageBytes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('레스토랑 편집'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_imageBytes != null) ...[
              Image.memory(
                _imageBytes!,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
            ],
            ElevatedButton(
              onPressed: () {
                _pickImage();
              },
              child: Text('사진 선택'),
            ),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: '레스토랑 이름'),
            ),
            SizedBox(height: 16.0),
            Row(
              children: [
                Text('평점: '),
                for (int i = 1; i <= 5; i++)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _rating = i;
                      });
                    },
                    child: Text('$i'),
                    style: ElevatedButton.styleFrom(
                      primary: _rating == i ? Colors.green : null,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: reviewController,
              decoration: InputDecoration(labelText: '리뷰'),
            ),
            SizedBox(height: 16.0),

            // 주소 및 전화번호 필드 추가
            TextField(
              controller: addressController,
              decoration: InputDecoration(labelText: '주소'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: phoneNumberController,
              decoration: InputDecoration(labelText: '전화번호'),
            ),

            // FutureBuilder 추가
            FutureBuilder<List<String>>(
              // fetchCities 메소드를 호출하는 비동기 함수를 지정
              future: fetchCities("pattern"), // "pattern"을 실제 검색 패턴으로 교체하세요.
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // 데이터가 아직 사용 가능하지 않은 경우 로딩 표시
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  // 오류가 발생한 경우 오류 메시지 표시
                  return Text('Error: ${snapshot.error}');
                } else {
                  // 데이터가 정상적으로 가져와진 경우 가져온 데이터를 사용하여 표시
                  List<String> cities = snapshot.data ?? [];
                  return ListView.builder(
                    itemCount: cities.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(cities[index]),
                      );
                    },
                  );
                }
              },
            ),

            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                String name = nameController.text;
                String review = reviewController.text;

                if (_rating != null) {
                  Restaurant editedRestaurant = Restaurant(
                    name: name,
                    rating: _rating!,
                    review: review,
                    imageBytes: _imageBytes,
                    address: addressController.text,
                    phoneNumber: phoneNumberController.text,
                  );

                  Navigator.pop(context, editedRestaurant);
                }
              },
              child: Text('편집 완료'),
            ),
          ],
        ),
      ),
    );
  }
}