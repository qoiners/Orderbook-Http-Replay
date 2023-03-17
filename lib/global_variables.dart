import 'package:orderbook_replay_flutter/model/orderbook_model.dart';

String kTicker = '006110';

int kCurrentIndex = 0;
int kFromTimestamp = 1678842000000;
int kToTimestamp = 1678845600000;

List<int> kTimestamps = [
  kFromTimestamp,
  kToTimestamp,
];

String kUrl = 'http://server1.jinhoko.com:30002';

int kMaxQuantity = 20000;
double kBarMaxWidth = 480.0;
double kBarHeight = 32.0;

bool kIsPlaying = false;
bool kIsComputing = false;

late OrderbookModel kOrderbookModel;

// update duration in ms (milliseconds)
int kDuration = 100;
