import 'package:flutter/material.dart';
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

    for (int i = widget.orderbookModel.prices.length ~/ 2 - 1; i >= 0; i--) {
      children.add(OrderbookBar(
        price: widget.orderbookModel.prices[i],
        quantity: widget.orderbookModel.quantities[i],
        isSell: true,
        isBold: i == 0,
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

    return Column(children: children);
  }
}
