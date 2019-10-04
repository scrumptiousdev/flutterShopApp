import 'package:flutter/material.dart';

class EditProductPage extends StatefulWidget {
  static const routeName = '/edit-product';

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _priceFocusNode = FocusNode();
  final _descFocusNode = FocusNode();

  @override
  void dispose() {
    _priceFocusNode.dispose();
    _descFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product')
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Form(
          child: ListView(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Title'
                ),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_priceFocusNode)
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Price'
                ),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                focusNode: _priceFocusNode,
                onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_descFocusNode)
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Description'
                ),
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                focusNode: _descFocusNode
              )
            ]
          )
        ),
      )
    );
  }
}