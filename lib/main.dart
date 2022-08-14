import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PixabayPage(),
    );
  }
}

class PixabayPage extends StatefulWidget {
  const PixabayPage({Key? key}) : super(key: key);

  @override
  State<PixabayPage> createState() => _PixabayPageState();
}

class _PixabayPageState extends State<PixabayPage> {
  List<PixabayImage> pixabayImages = [];

  ///画像をAPIを通して取得する
  Future<void> fetchImages(String text) async {
    final response =
        await Dio().get('https://pixabay.com/api/', queryParameters: {
      'key': '29261632-46d433d4c93a34434e822568f',
      'q': text,
      'image_type': 'photo',
      'per_page': 100
    });
    final List list = response.data['hits'];
    pixabayImages = list
        .map(
          (e) => PixabayImage.fromMap(e),
        )
        .toList();
    setState(() {});
  }

  ///画像をシェアする
  Future<void> shareImage(String url) async {
    final dir = await getTemporaryDirectory();
    final response = await Dio()
        .get(url, options: Options(responseType: ResponseType.bytes));
    final imageFile =
        await File('${dir.path}/image.png').writeAsBytes(response.data);
    await Share.shareFiles([imageFile.path]);
  }

  @override
  void initState() {
    super.initState();
    fetchImages('花');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          initialValue: '花',
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
          ),
          onFieldSubmitted: (text) {
            fetchImages(text);
          },
        ),
      ),
      body: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3),
          itemCount: pixabayImages.length,
          itemBuilder: (context, index) {
            final image = pixabayImages[index];
            return InkWell(
              onTap: (() {
                shareImage(image.webformatURL);
              }),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    image.previewURL,
                    fit: BoxFit.cover,
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                        color: Colors.white,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.thumb_up_alt_outlined,
                              size: 14,
                            ),
                            Text(image.likes.toString()),
                          ],
                        )),
                  )
                ],
              ),
            );
          }),
    );
  }
}

class PixabayImage {
  final String previewURL;
  final String webformatURL;
  final int likes;

  PixabayImage(
      {required this.previewURL,
      required this.webformatURL,
      required this.likes});

  factory PixabayImage.fromMap(Map<String, dynamic> map) {
    return PixabayImage(
        previewURL: map['previewURL'],
        webformatURL: map['webformatURL'],
        likes: map['likes']);
  }
}
