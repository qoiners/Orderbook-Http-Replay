import 'package:flutter/material.dart';
import 'package:orderbook_replay_flutter/global_variables.dart';

class OrderbookBar extends StatelessWidget {
  final int price, quantity;
  final bool isSell, isBold;

  const OrderbookBar({
    super.key,
    required this.price,
    required this.quantity,
    required this.isSell,
    required this.isBold,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: isSell
              ? [
                  SizedBox(
                    width: kBarMaxWidth,
                    child: Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        Container(
                          width: quantity < kMaxQuantity
                              ? kBarMaxWidth * (quantity / kMaxQuantity)
                              : kBarMaxWidth,
                          height: kBarHeight,
                          color: Colors.blue,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            "$quantity",
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 96,
                    child: Text(
                      '$price',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight:
                            isBold ? FontWeight.bold : FontWeight.normal,
                        fontSize: isBold ? 18 : 16,
                      ),
                    ),
                  ),
                  SizedBox(width: kBarMaxWidth),
                ]
              : [
                  SizedBox(
                    width: kBarMaxWidth,
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        Container(
                          width: quantity < kMaxQuantity
                              ? kBarMaxWidth * (quantity / kMaxQuantity)
                              : kBarMaxWidth,
                          height: kBarHeight,
                          color: Colors.red,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            "$quantity",
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 96,
                    child: Text(
                      '$price',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight:
                            isBold ? FontWeight.bold : FontWeight.normal,
                        fontSize: isBold ? 18 : 16,
                      ),
                    ),
                  ),
                  SizedBox(width: kBarMaxWidth),
                ].reversed.toList(),
        ),
      ),
    );
  }
}
