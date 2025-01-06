import 'package:flutter/material.dart';
import 'package:flutter_arch/app/app_config.dart';

extension DecreationExt on BoxDecoration {

  BoxDecoration get circle => copyWith(shape: BoxShape.circle);

  BoxDecoration get rectangle => copyWith(shape: BoxShape.rectangle);

  BoxDecoration get primary => copyWith(color: AppConfig().colorScheme.primary);

  BoxDecoration get secondary => copyWith(color: AppConfig().colorScheme.secondary);

  BoxDecoration get tertiary => copyWith(color: AppConfig().colorScheme.tertiary);

  BoxDecoration get error => copyWith(color: AppConfig().colorScheme.error);

  BoxDecoration get primaryContainer => copyWith(color: AppConfig().colorScheme.primaryContainer);

  BoxDecoration get secondaryContainer => copyWith(color: AppConfig().colorScheme.secondaryContainer);

  BoxDecoration get tertiaryContainer => copyWith(color: AppConfig().colorScheme.tertiaryContainer);

  BoxDecoration get errorContainer => copyWith(color: AppConfig().colorScheme.errorContainer);

  BoxDecoration get surface => copyWith(color: AppConfig().colorScheme.surface);

  BoxDecoration get surfaceVariant => copyWith(color: AppConfig().colorScheme.surfaceVariant);

  BoxDecoration get background => copyWith(color: AppConfig().colorScheme.background);

  BoxDecoration get r2 => copyWith(borderRadius: BorderRadius.circular(2));

  BoxDecoration get r4 => copyWith(borderRadius: BorderRadius.circular(4));

  BoxDecoration get r8 => copyWith(borderRadius: BorderRadius.circular(8));

  BoxDecoration get r16 => copyWith(borderRadius: BorderRadius.circular(16));

}