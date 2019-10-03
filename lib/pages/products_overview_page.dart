import 'package:flutter/material.dart';

import '../widgets/products_grid.dart';

enum FilterOptions {
  Favorites,
  All
}

class ProductsOverviewPage extends StatefulWidget {
  @override
  _ProductsOverviewPageState createState() => _ProductsOverviewPageState();
}

class _ProductsOverviewPageState extends State<ProductsOverviewPage> {
  var _showOnlyFavorites = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
        actions: <Widget>[
          PopupMenuButton(
            icon: Icon(Icons.more_vert),
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('Only Favorites'),
                value: FilterOptions.Favorites
              ),
              PopupMenuItem(
                child: Text('Show All'),
                value: FilterOptions.All
              )
            ],
            onSelected: (FilterOptions selectedValue) {
              setState(() {
                _showOnlyFavorites = selectedValue == FilterOptions.Favorites ? true : false;
              });
            }
          )
        ]
      ),
      body: ProductsGrid(_showOnlyFavorites)
    );
  }
}