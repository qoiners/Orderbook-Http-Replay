import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:orderbook_replay_flutter/functions.dart';
import 'package:orderbook_replay_flutter/global_variables.dart';
import 'package:orderbook_replay_flutter/model/orderbook_model.dart';
import 'package:orderbook_replay_flutter/widgets/orderbook.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final TextEditingController tickerController;
  late final TextEditingController timestampController;
  late final ScrollController scrollController;
  late Timer timer;
  // late OrderBook orderBook;

  String currentLoadedState = "Not fetched yet";
  int bidSum = 0;
  int askSum = 0;
  OrderbookModel defaultOrderbook =
      OrderbookModel(prices: [0], quantities: [0]);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await fetchTimestamps();
      await fetchOrderbook();
      updateSums();
      // orderBook = OrderBook();
    });

    List<int> quantities = [];

    for (int i = 0; i < 20; i++) {
      quantities.add(Random().nextInt(21000) + 1000);
    }

    timer = Timer(const Duration(milliseconds: 100), () {});

    // kOrderbookModel =
    //     OrderbookModel(prices: [0].reversed.toList(), quantities: quantities);
    kTimestamps = [kFromTimestamp, kToTimestamp];
    kOrderbookModel = defaultOrderbook;

    tickerController = TextEditingController(text: kTicker);
    timestampController =
        TextEditingController(text: kTimestamps[kCurrentIndex].toString());

    scrollController = ScrollController();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  updateSums() {
    int length = kOrderbookModel.prices.length;
    if (length > 1) {
      askSum = kOrderbookModel.quantities
          .sublist(0, length ~/ 2 - 1)
          .reduce((a, b) => a + b);
      bidSum = kOrderbookModel.quantities
          .sublist(length ~/ 2, length - 1)
          .reduce((a, b) => a + b);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTextStyle(
        style: const TextStyle(color: Colors.black, fontSize: 15),
        child: Center(
          child: Scrollbar(
            controller: scrollController,
            child: SingleChildScrollView(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      '현재 시간: ${DateTime.fromMillisecondsSinceEpoch(kTimestamps[kCurrentIndex])} / ${kTimestamps[kCurrentIndex]}',
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        SizedBox(
                          width: 120,
                          child: Text("매도 총량: $askSum"),
                        ),
                        SizedBox(
                          width: 120,
                          child: Text("매수 총량: $bidSum"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    OrderBook(
                      orderbookModel: kOrderbookModel,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 24.0, bottom: 18.0),
                      child: SizedBox(
                        width: 800,
                        child: Divider(
                          thickness: 2.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: 720,
                      child: Slider(
                        value: kCurrentIndex.toDouble(),
                        min: 0,
                        max: (kTimestamps.length - 1),
                        divisions: kTimestamps.length - 1,
                        label: getTimeFromDateTime(
                            DateTime.fromMillisecondsSinceEpoch(
                                kTimestamps[kCurrentIndex])),
                        onChanged: (value) {
                          if (currentLoadedState == "Not fetched yet" ||
                              currentLoadedState ==
                                  "Fetching timestamps failed / Check parameters") {
                            return;
                          }
                          if (kCurrentIndex != value.toInt()) {
                            setState(() {
                              kCurrentIndex = value.toInt();
                            });
                          }
                        },
                        onChangeEnd: (value) async {
                          if (currentLoadedState == "Not fetched yet" ||
                              currentLoadedState ==
                                  "Fetching timestamps failed / Check parameters") {
                            return;
                          }
                          kCurrentIndex = value.toInt();
                          await fetchOrderbook();
                          updateSums();
                          setState(() {});
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.replay_10_rounded, size: 48),
                          onPressed: () async {
                            if (currentLoadedState == "Not fetched yet" ||
                                currentLoadedState ==
                                    "Fetching timestamps failed / Check parameters") {
                              return;
                            }
                            kCurrentIndex =
                                kCurrentIndex - 10 > 0 ? kCurrentIndex - 10 : 0;

                            kIsPlaying = false;
                            timer.cancel();

                            kTicker = tickerController.text;
                            await fetchOrderbook();
                            updateSums();
                            setState(() {});
                          },
                        ),
                        IconButton(
                          icon:
                              const Icon(Icons.skip_previous_rounded, size: 48),
                          onPressed: () async {
                            if (currentLoadedState == "Not fetched yet" ||
                                currentLoadedState ==
                                    "Fetching timestamps failed / Check parameters") {
                              return;
                            }
                            kCurrentIndex =
                                kCurrentIndex - 1 > 0 ? kCurrentIndex - 1 : 0;

                            kIsPlaying = false;
                            timer.cancel();

                            kTicker = tickerController.text;
                            print(kTicker);
                            await fetchOrderbook();
                            updateSums();
                            setState(() {});
                          },
                        ),
                        IconButton(
                            icon: Icon(
                                kIsPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                size: 48),
                            onPressed: () async {
                              if (currentLoadedState == "Not fetched yet" ||
                                  currentLoadedState ==
                                      "Fetching timestamps failed / Check parameters") {
                                return;
                              }
                              kIsPlaying = !kIsPlaying;
                              if (!kIsPlaying) {
                                timer.cancel();
                                setState(() {});
                              } else {
                                timer = Timer.periodic(
                                    Duration(milliseconds: kDuration),
                                    (_) async {
                                  kCurrentIndex =
                                      (kCurrentIndex + 1) % kTimestamps.length;
                                  await fetchOrderbook();
                                  updateSums();

                                  setState(() {});
                                });
                              }
                            }),
                        IconButton(
                          icon: const Icon(Icons.skip_next_rounded, size: 48),
                          onPressed: () async {
                            if (currentLoadedState == "Not fetched yet" ||
                                currentLoadedState ==
                                    "Fetching timestamps failed / Check parameters") {
                              return;
                            }
                            int length = kTimestamps.length;

                            kCurrentIndex = kCurrentIndex + 1 < length - 1
                                ? kCurrentIndex + 1
                                : length - 1;

                            kIsPlaying = false;
                            timer.cancel();

                            kTicker = tickerController.text;
                            print(kTicker);
                            await fetchOrderbook();
                            updateSums();
                            setState(() {});
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.forward_10_rounded, size: 48),
                          onPressed: () async {
                            if (currentLoadedState == "Not fetched yet" ||
                                currentLoadedState ==
                                    "Fetching timestamps failed / Check parameters") {
                              return;
                            }
                            int length = kTimestamps.length;

                            kCurrentIndex = kCurrentIndex + 10 < length - 1
                                ? kCurrentIndex + 10
                                : length - 1;

                            kIsPlaying = false;
                            timer.cancel();

                            kTicker = tickerController.text;
                            print(kTicker);
                            await fetchOrderbook();
                            updateSums();
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(width: 120, child: Text("시작시간: ")),
                        TextButton(
                          onPressed: () {
                            DateTime dateTime =
                                DateTime.fromMillisecondsSinceEpoch(
                                    kFromTimestamp);
                            Future<DateTime?> selectedDate = showDatePicker(
                              context: context,
                              initialDate: dateTime,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );

                            selectedDate.then((date) async {
                              kFromTimestamp = DateTime(
                                date != null ? date.year : dateTime.year,
                                date != null ? date.month : dateTime.month,
                                date != null ? date.day : dateTime.day,
                                9,
                                0,
                                0,
                              ).millisecondsSinceEpoch;
                              setState(() {});
                            });
                          },
                          child: Text(
                            getDateFromDateTime(
                                DateTime.fromMillisecondsSinceEpoch(
                                    kFromTimestamp)),
                            style: const TextStyle(
                                color: Colors.blue, fontSize: 18),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            DateTime dateTime =
                                DateTime.fromMillisecondsSinceEpoch(
                                    kFromTimestamp);
                            Future<TimeOfDay?> selectedTime = showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.fromDateTime(dateTime));

                            selectedTime.then((timeOfDay) async {
                              kFromTimestamp = DateTime(
                                dateTime.year,
                                dateTime.month,
                                dateTime.day,
                                timeOfDay != null
                                    ? timeOfDay.hour
                                    : dateTime.hour,
                                timeOfDay != null
                                    ? timeOfDay.minute
                                    : dateTime.minute,
                              ).millisecondsSinceEpoch;
                              setState(() {});
                            });
                          },
                          child: Text(
                            getTimeFromDateTime(
                                DateTime.fromMillisecondsSinceEpoch(
                                    kFromTimestamp)),
                            style: const TextStyle(
                                color: Colors.blue, fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(width: 120, child: Text("종료시간: ")),
                        TextButton(
                          onPressed: () {
                            DateTime dateTime =
                                DateTime.fromMillisecondsSinceEpoch(
                                    kToTimestamp);
                            Future<DateTime?> selectedDate = showDatePicker(
                              context: context,
                              initialDate: dateTime,
                              firstDate: DateTime.fromMillisecondsSinceEpoch(
                                  kFromTimestamp),
                              lastDate: DateTime.now(),
                            );

                            selectedDate.then((date) async {
                              kToTimestamp = DateTime(
                                date != null ? date.year : dateTime.year,
                                date != null ? date.month : dateTime.month,
                                date != null ? date.day : dateTime.day,
                                9,
                                0,
                                0,
                              ).millisecondsSinceEpoch;
                              setState(() {});
                            });
                          },
                          child: Text(
                            getDateFromDateTime(
                                DateTime.fromMillisecondsSinceEpoch(
                                    kToTimestamp)),
                            style: const TextStyle(
                                color: Colors.blue, fontSize: 18),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            DateTime dateTime =
                                DateTime.fromMillisecondsSinceEpoch(
                                    kToTimestamp);
                            Future<TimeOfDay?> selectedTime = showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.fromDateTime(dateTime));

                            selectedTime.then((timeOfDay) async {
                              kToTimestamp = DateTime(
                                dateTime.year,
                                dateTime.month,
                                dateTime.day,
                                timeOfDay != null
                                    ? timeOfDay.hour
                                    : dateTime.hour,
                                timeOfDay != null
                                    ? timeOfDay.minute
                                    : dateTime.minute,
                              ).millisecondsSinceEpoch;
                              setState(() {});
                            });
                          },
                          child: Text(
                            getTimeFromDateTime(
                                DateTime.fromMillisecondsSinceEpoch(
                                    kToTimestamp)),
                            style: const TextStyle(
                                color: Colors.blue, fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(currentLoadedState),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: 240,
                      child: TextField(
                        controller: tickerController,
                        style:
                            const TextStyle(color: Colors.black, fontSize: 18),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          label: const Text("종목 번호"),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: () async {
                              kIsPlaying = false;
                              timer.cancel();
                              // if (kFromTimestamp > kToTimestamp) {
                              //   currentLoadedState =
                              //       "From TS is larger than To TS!";
                              //   setState(() {});
                              //   return;
                              // }
                              // String oldTicker = kTicker;
                              // List<int> oldTimestamps = kTimestamps;
                              currentLoadedState = "Fetching...";
                              kTicker = tickerController.text;
                              await fetchTimestamps();
                              if (kTimestamps.isEmpty) {
                                currentLoadedState =
                                    "Fetching timestamps failed / Check parameters";
                                // kTicker = oldTicker;
                                // kTimestamps = oldTimestamps;
                                // // TextSelection oldSelection =
                                // //     tickerController.selection;
                                // // tickerController.value =
                                // //     tickerController.value.copyWith(
                                // //   selection: oldSelection,
                                // //   text: oldTicker,
                                // // );
                                kCurrentIndex = 0;
                                kTimestamps = [kFromTimestamp, kToTimestamp];
                                kOrderbookModel = defaultOrderbook;
                              } else {
                                kCurrentIndex = 0;
                                await fetchOrderbook();
                                currentLoadedState = "Load success!";
                              }
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
