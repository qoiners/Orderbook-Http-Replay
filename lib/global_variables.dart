import 'package:orderbook_replay_flutter/model/orderbook_model.dart';

String kTicker = '048550';

int kCurrentIndex = 0;
int kFromTimestamp = 1676246400000;
int kToTimestamp = 1676250000000;

List<int> kTimestamps = [
  kFromTimestamp,
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
