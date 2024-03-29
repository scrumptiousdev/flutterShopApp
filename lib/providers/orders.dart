import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String authToken;
  final String userId;

  Orders(this.authToken, this.userId, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final response = await http.get('https://flutter-shop-app-8017a.firebaseio.com/orders/$userId.json?auth=$authToken');
    final List<OrderItem> loadedOrders = [];
    final data = json.decode(response.body) as Map<String, dynamic>;
    if (data == null) return;
    data.forEach((orderId, orderData) {
      loadedOrders.add(OrderItem(
        id: orderId,
        amount: orderData['amount'],
        dateTime: DateTime.parse(orderData['dateTime']),
        products: (orderData['products'] as List<dynamic>).map((prod) => CartItem(
          id: prod['id'],
          price: prod['price'],
          quantity: prod['quantity'],
          title: prod['title']
        )).toList()
      ));
      _orders = loadedOrders.reversed.toList();
      notifyListeners();
    });
  }
  
  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final timestamp = DateTime.now();
    final response = await http.post('https://flutter-shop-app-8017a.firebaseio.com/orders/$userId.json?auth=$authToken',
      body: json.encode({
        'amount': total,
        'dateTime': timestamp.toIso8601String(),
        'products': cartProducts.map((cp) => {
          'id': cp.id,
          'title': cp.title,
          'quantity': cp.quantity,
          'price': cp.price
        }).toList()
      })
    );
    _orders.insert(0, OrderItem(
      id: json.decode(response.body)['name'],
      amount: total,
      products: cartProducts,
      dateTime: timestamp
    ));
    notifyListeners();
  }
}