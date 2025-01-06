import 'package:flutter/material.dart';

extension RadiusExt on Radius {
  Radius get extraSmall => const Radius.circular(2);

  Radius get small => const Radius.circular(4);

  Radius get medium => const Radius.circular(8);

  Radius get large => const Radius.circular(12);

  Radius get extraLarge => const Radius.circular(16);

  Radius get full => const Radius.circular(64);
}

extension BorderRadiusExt on BorderRadius {
  BorderRadius get extraSmall => BorderRadius.circular(2);

  BorderRadius get small => BorderRadius.circular(4);

  BorderRadius get medium => BorderRadius.circular(8);

  BorderRadius get large => BorderRadius.circular(12);

  BorderRadius get extraLarge => BorderRadius.circular(16);

  BorderRadius get full => BorderRadius.circular(64);
}
