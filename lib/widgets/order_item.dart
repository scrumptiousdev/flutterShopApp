import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../providers/orders.dart' as o;

class OrderItem extends StatelessWidget {
  final o.OrderItem order;

  OrderItem(this.order);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text('\$${order.amount}'),
            subtitle: Text(DateFormat('yyyy/MM/dd hh:mm').format(order.dateTime)),
            trailing: IconButton(
              icon: Icon(Icons.expand_more),
              onPressed: () {}
            )
          )
        ]
      )
    );
  }
}