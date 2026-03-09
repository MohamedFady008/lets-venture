import 'package:flutter/material.dart';

class Animal {
  final String name;
  final List<String> facts;
  final List<String> videoUrls;
  final String lifespan;
  final String speed;
  final String imageAsset;
  final Color color;

  Animal({
    required this.name,
    required this.facts,
    required this.videoUrls,
    required this.lifespan,
    required this.speed,
    required this.imageAsset,
    required this.color,
  });
}

final List<Animal> animals = [
  Animal(
    name: 'Lion',
    facts: [
      'The lion is a muscular, deep-chested cat.',
      'Lions live in groups called prides.',
      'A lion’s roar can be heard up to 8km away.',
    ],
    videoUrls: [
      'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    ],
    lifespan: '10–14 years',
    speed: 'Up to 80 km/h',
    imageAsset: 'assets/lion.png',
    color: Colors.orange.shade400,
  ),
  Animal(
    name: 'Hippo',
    facts: [
      'The hippopotamus is large and herbivorous.',
      'Hippos spend most of their time in water.',
    ],
    videoUrls: [
      'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    ],
    lifespan: '40–50 years',
    speed: 'Up to 30 km/h',
    imageAsset: 'assets/hippo.png',
    color: Colors.deepPurple.shade400,
  ),
  Animal(
    name: 'Rabbit',
    facts: [
      'Rabbits are small mammals in the family Leporidae.',
      'They use their large ears to regulate body temperature.',
    ],
    videoUrls: [
      'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    ],
    lifespan: '8–12 years',
    speed: 'Up to 40 km/h',
    imageAsset: 'assets/rabbit.png',
    color: Colors.teal.shade400,
  ),
];
