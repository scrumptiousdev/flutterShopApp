import 'package:flutter/material.dart';
import 'package:flutter_shop_app/widgets/app_drawer.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import '../widgets/user_product_item.dart';
import '../widgets/app_drawer.dart';

class UserProductsPage extends StatelessWidget {
  static const routeName = '/user-products';

  @override
  Widget build(BuildContext context) {
    final products = Provider.of<Products>(context).items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {}
          )
        ]
      ),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: ListView.builder(
          itemCount: products.length,
          itemBuilder: (_, i) => Column(
            children: <Widget>[
              UserProductItem(
                products[i].title,
                products[i].imageUrl
              ),
              if (i < products.length - 1) Divider()
            ]
          )
        )
      ),
      drawer: AppDrawer()
    );
  }
}