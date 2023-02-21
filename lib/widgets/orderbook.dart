import 'dart:math';

import 'package:flutter/material.dart';
import 'package:orderbook_replay_flutter/global_variables.dart';
import 'package:orderbook_replay_flutter/model/orderbook_model.dart';
import 'package:orderbook_replay_flutter/widgets/orderbook_bar.dart';

class OrderBook extends StatefulWidget {
  OrderbookModel orderbookModel;
  OrderBook({super.key, required this.orderbookModel});

  @override
  State<OrderBook> createState() => _OrderBookState();
}

class _OrderBookState extends State<OrderBook> {
  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];

    for (int i = 0; i < widget.orderbookModel.prices.length ~/ 2; i++) {
      children.add(OrderbookBar(
        price: widget.orderbookModel.prices[i],
        quantity: widget.orderbookModel.quantities[i],
        isSell: true,
        isBold: i == widget.orderbookModel.prices.length ~/ 2 - 1,
      ));
    }

    for (int i = widget.orderbookModel.prices.length ~/ 2;
        i < widget.orderbookModel.prices.length;
        i++) {
      children.add(OrderbookBar(
        price: widget.orderbookModel.prices[i],
        quantity: widget.orderbookModel.quantities[i],
        isSell: false,
        isBold: i == widget.orderbookModel.prices.length ~/ 2,
      ));
    }

    // children.add(
    //   Row(
    //     children:[
    //     Text(${}),
    //     SizedBox()],
    //   ),
    // );

    return Column(children: children);
  }
}
