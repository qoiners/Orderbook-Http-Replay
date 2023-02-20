import 'package:orderbook_replay_flutter/model/orderbook_model.dart';

String kTicker = '277810';

int kCurrentIndex = 0;
int kFromTimestamp = 1674691200000;
int kToTimestamp = 1674694800000;

List<int> kTimestamps = [
  kFromTimestamp,
  kFromTimestamp,
  kFromTimestamp,
  kFromTimestamp,
  kFromTimestamp,
  kFromTimestamp,
  kFromTimestamp,
  kFromTimestamp,
  kFromTimestamp,
  kFromTimestamp,
  kFromTimestamp,
  kFromTimestamp,
  kFromTimestamp,
  kFromTimestamp,
  kFromTimestamp,
  kFromTimestamp,
  kFromTimestamp,
  kToTimestamp,
  kToTimestamp,
  kToTimestamp,
  kToTimestamp,
  kToTimestamp,
  kToTimestamp,
  kToTimestamp,
  kToTimestamp,
  kToTimestamp,
  kToTimestamp,
  kToTimestamp,
  kToTimestamp,
  kToTimestamp,
  kToTimestamp,
  kToTimestamp,
  kToTimestamp,
  kToTimestamp,
  kToTimestamp,
];

String kUrl = 'http://localhost:30001';

int kMaxQuantity = 20000;
double kBarMaxWidth = 480.0;
double kBarHeight = 32.0;

bool kIsPlaying = false;
bool kIsComputing = false;

late OrderbookModel kOrderbookModel;

// update duration in ms (milliseconds)
int kDuration = 100;
