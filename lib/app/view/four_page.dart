import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class Creator {
  final String name;
  final String imageUrl;
  final String videoUrl;
  final int followers;
  final int following;

  Creator({
    required this.name,
    required this.imageUrl,
    required this.videoUrl,
    required this.followers,
    required this.following,
  });
}

class FollowingPage extends StatelessWidget {
  final List<Creator> creators;

  FollowingPage({required this.creators});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Following'),
      ),
      body: Center(
        child: CarouselSlider.builder(
          itemCount: creators.length,
          itemBuilder: (BuildContext context, int index, int realIndex) {
            Creator creator = creators[index];
            return Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.network(
                    creator.videoUrl,
                    fit: BoxFit.cover,
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.height * 0.6,
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        creator.name,
                        style: TextStyle(fontSize: 24, color: Colors.white),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Followers: ${creator.followers}',
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        'Following: ${creator.following}',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
          options: CarouselOptions(
            autoPlay: false,
            enlargeCenterPage: true,
            aspectRatio: 1,
            viewportFraction: 0.9,
          ),
        ),
      ),
    );
  }
}