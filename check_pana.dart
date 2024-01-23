#!/usr/bin/env dart
// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  // Run 'pana' and capture the output
  var process = await Process.start('dart', [
    'run',
    'pana',
    '--no-warning',
    '--json',
  ]);
  var output = await utf8.decoder.bind(process.stdout).join();
  await process.exitCode;

  try {
    // Parse the JSON output to get the score
    final jsonOutput = jsonDecode(output) as Map<String, dynamic>;
    final grantedPoints = jsonOutput['scores']['grantedPoints'];
    final maxPoints = jsonOutput['scores']['maxPoints'];
    final complete = grantedPoints == maxPoints;
    final result = '$grantedPoints/$maxPoints';

    // Check if the score is less than 140
    if (!complete) {
      print('❌ Not all pub points achieved: $result');
      print('run "dart run pana" for more details');
      exit(1);
    } else {
      print('✅ All pub points achieved: $result');
    }
  } catch (e) {
    print('Error parsing pana output: $e');
    exit(1);
  }
}
