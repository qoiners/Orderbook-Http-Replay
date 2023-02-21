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

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await fetchTimestamps();
      await fetchOrderbook();
      // orderBook = OrderBook();
    });

    List<int> quantities = [];
    int sellSum = 0;
    int buySum = 0;

    for (int i = 0; i < 20; i++) {
      quantities.add(Random().nextInt(21000) + 1000);
    }

    kOrderbookModel = OrderbookModel(
        prices: [
          500,
          600,
          700,
          800,
          900,
          1000,
          1100,
          1200,
          1300,
          1400,
          1500,
          1600,
          1700,
          1800,
          1900,
          2000,
          2100,
          2200,
          2300,
          2400,
        ].reversed.toList(),
        quantities: quantities);

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

  // setTimer() {
  //   kIsPlaying = !kIsPlaying;
  //   print("on timer: $kIsPlaying");

  //   if (kIsPlaying) {
  //     // setState(() {
  //     //   // kCurrentIndex = 0;
  //     // });

  //     timer = Timer.periodic(Duration(milliseconds: kDuration), (_) async {
  //       kCurrentIndex = (kCurrentIndex + 1) % kTimestamps.length;
  //       await fetchOrderbook();
  //       setState(() {});
  //       // setState(() {
  //       //   kCurrentIndex = (kCurrentIndex + 1) % kTimestamps.length;
  //       //   fetchOrderbook();
  //       // });
  //     });
  //   } else {
  //     timer.cancel();

  //     // setState(() {});
  //   }
  // }

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
                    const SizedBox(height: 32),
                    Text(
                      '현재 시간: ${DateTime.fromMillisecondsSinceEpoch(kTimestamps[kCurrentIndex])} / ${kTimestamps[kCurrentIndex]}',
                      textAlign: TextAlign.start,
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
                          // print(value.toInt());
                          if (kCurrentIndex != value.toInt()) {
                            setState(() {
                              kCurrentIndex = value.toInt();
                            });
                          }
                          // print(kCurrentTimestamp);
                        },
                        onChangeEnd: (value) async {
                          kCurrentIndex = value.toInt();

                          await fetchOrderbook();

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
                            kCurrentIndex =
                                kCurrentIndex - 10 > 0 ? kCurrentIndex - 10 : 0;

                            kIsPlaying = false;

                            await fetchOrderbook();
                            setState(() {});
                          },
                        ),
                        IconButton(
                          icon:
                              const Icon(Icons.skip_previous_rounded, size: 48),
                          onPressed: () async {
                            kCurrentIndex =
                                kCurrentIndex - 1 > 0 ? kCurrentIndex - 1 : 0;

                            kIsPlaying = false;

                            await fetchOrderbook();
                            setState(() {});
                          },
                        ),
                        IconButton(
                            icon: Icon(
                                kIsPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                size: 48),
                            // onPressed: () async {
                            //   if (!kIsPlaying) {
                            //     kIsPlaying = true;

                            //     if (kCurrentIndex == kTimestamps.length - 1) {
                            //       kCurrentIndex = 0;
                            //     }
                            //     timer = Timer.periodic(
                            //         Duration(milliseconds: kDuration),
                            //         (timer) async {
                            //       if (kCurrentIndex == kTimestamps.length - 1) {
                            //         kCurrentIndex = 0;
                            //         timer.cancel();
                            //       } else {
                            //         kCurrentIndex++;
                            //         await fetchOrderbook();
                            //         setState(() {});
                            //       }
                            //     });
                            //   } else {
                            //     kIsPlaying = false;
                            //     timer.cancel();
                            //   }

                            //   setState(() {});
                            // },
                            onPressed: () async {
                              kIsPlaying = !kIsPlaying;
                              if (!kIsPlaying) {
                                print("STATE 1");
                                timer.cancel();

                                setState(() {});
                              } else {
                                print("STATE 2");
                                timer = Timer.periodic(
                                    Duration(milliseconds: kDuration),
                                    (_) async {
                                  kCurrentIndex =
                                      (kCurrentIndex + 1) % kTimestamps.length;

                                  await fetchOrderbook();

                                  setState(() {});
                                });
                              }
                            }),
                        IconButton(
                          icon: const Icon(Icons.skip_next_rounded, size: 48),
                          onPressed: () async {
                            int length = kTimestamps.length;

                            kCurrentIndex = kCurrentIndex + 1 < length - 1
                                ? kCurrentIndex + 1
                                : length - 1;

                            kIsPlaying = false;

                            await fetchOrderbook();
                            setState(() {});
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.forward_10_rounded, size: 48),
                          onPressed: () async {
                            int length = kTimestamps.length;

                            kCurrentIndex = kCurrentIndex + 10 < length - 1
                                ? kCurrentIndex + 10
                                : length - 1;

                            kIsPlaying = false;

                            await fetchOrderbook();
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
                              await fetchTimestamps();
                              setState(() {
                                kFromTimestamp = DateTime(
                                        date != null
                                            ? date.year
                                            : dateTime.year,
                                        date != null
                                            ? date.month
                                            : dateTime.month,
                                        date != null ? date.day : dateTime.day,
                                        9,
                                        0,
                                        0)
                                    .millisecondsSinceEpoch;
                              });
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
                              await fetchTimestamps();
                              setState(() {
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
                              });
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
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );

                            selectedDate.then((date) async {
                              await fetchTimestamps();
                              setState(() {
                                kToTimestamp = DateTime(
                                        date != null
                                            ? date.year
                                            : dateTime.year,
                                        date != null
                                            ? date.month
                                            : dateTime.month,
                                        date != null ? date.day : dateTime.day,
                                        9,
                                        0,
                                        0)
                                    .millisecondsSinceEpoch;
                              });
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
                              await fetchTimestamps();
                              setState(() {
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
                              });
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
                            onPressed: () {},
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
