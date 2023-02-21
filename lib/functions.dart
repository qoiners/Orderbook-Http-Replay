import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:orderbook_replay_flutter/global_variables.dart';
import 'package:orderbook_replay_flutter/model/orderbook_model.dart';

String getDateFromDateTime(DateTime dateTime) {
  String year = dateTime.year.toString();
  String month = dateTime.month.toString().padLeft(2, "0");
  String day = dateTime.day.toString().padLeft(2, "0");

  return ("$year-$month-$day");
}

String getTimeFromDateTime(DateTime dateTime) {
  String hour = dateTime.hour.toString().padLeft(2, "0");
  String minute = dateTime.minute.toString().padLeft(2, "0");
  String second = dateTime.second.toString().padLeft(2, "0");

  return ("$hour:$minute:$second");
}

fetchHttpPost(String type, var reqBody) async {
  http.Response response = await http.post(
    Uri.parse('$kUrl/$type'),
    // headers: {'Content-Type': 'application/json'},
    body: jsonEncode(reqBody),
  );

  if (response.statusCode != 200) {
    return jsonDecode(utf8.decode(response.bodyBytes));
    // return false;
  } else {
    return jsonDecode(utf8.decode(response.bodyBytes));
  }
}

fetchTimestamps() async {
  var resBody = await fetchHttpPost('timestamps', {
    'ticker': kTicker,
    'from_timestamp': kFromTimestamp,
    'to_timestamp': kToTimestamp,
  });

  kTimestamps = resBody['timestamps'].cast<int>();

  kCurrentIndex = 0;
  kIsPlaying = false;
}

fetchOrderbook() async {
  var resBody = await fetchHttpPost('orderbook', {
    'ticker': kTicker,
    'timestamp': kTimestamps[kCurrentIndex],
  });

  List<int> prices = [];
  List<int> quantities = [];

  for (List<dynamic> item in resBody['orderbook']) {
    List<int> intItem = item.cast<int>();
    prices.add(intItem[0]);
    quantities.add(intItem[1]);
  }

  kOrderbookModel = OrderbookModel(prices: prices, quantities: quantities);

  // kIsPlaying = false;
}

// https://stackoverflow.com/questions/53767950/how-to-periodically-set-state