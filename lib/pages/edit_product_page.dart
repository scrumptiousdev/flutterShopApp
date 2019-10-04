import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products.dart';

class EditProductPage extends StatefulWidget {
  static const routeName = '/edit-product';

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _priceFocusNode = FocusNode();
  final _descFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _form = GlobalKey<FormState>();
  var _formOnceSubmitted = false;
  var _editedProduct = Product(
    id: null,
    title: '',
    price: 0,
    description: '',
    imageUrl: ''
  );
  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': ''
  };
  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        _editedProduct = Provider.of<Products>(context, listen: false).findById(productId);
        _initValues = {
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': _editedProduct.price.toString(),
          'imageUrl': ''
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descFocusNode.dispose();
    _imageUrlFocusNode.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if (!_imageUrlController.text.startsWith('http') || !_imageUrlController.text.startsWith('https')) return;
      if (!_imageUrlController.text.endsWith('.png') && !_imageUrlController.text.endsWith('.jpg') && !_imageUrlController.text.endsWith('.jpeg')) return;
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState.validate();

    if (!isValid) {
      setState(() => _formOnceSubmitted = true);
      return;
    }

    _form.currentState.save();
    setState(() => _isLoading = true);

    if (_editedProduct.id != null) {
      Provider.of<Products>(context, listen: false).updateProduct(_editedProduct.id, _editedProduct);
      setState(() => _isLoading = false);
      Navigator.of(context).pop();
    } else {
      try {
        await Provider.of<Products>(context, listen: false).addProduct(_editedProduct);
      } catch (err) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('An error occurred!'),
            content: Text('Something went wrong.'),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () =>Navigator.of(ctx).pop()
              )
            ]
          )
        );
      } finally {
        setState(() => _isLoading = false);
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm
          )
        ]
      ),
      body: _isLoading ? Center(
        child: CircularProgressIndicator()
      ) : Padding(
        padding: const EdgeInsets.all(15),
        child: Form(
          key: _form,
          autovalidate: _formOnceSubmitted,
          child: ListView(
            children: <Widget>[
              TextFormField(
                initialValue: _initValues['title'],
                decoration: InputDecoration(
                  labelText: 'Title'
                ),
                validator: (value) {
                  if (value.isEmpty) return 'Please provide a title.';
                  return null;
                },
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_priceFocusNode),
                onSaved: (value) => _editedProduct = Product(
                  title: value,
                  price: _editedProduct.price,
                  description: _editedProduct.description,
                  imageUrl: _editedProduct.imageUrl,
                  id: _editedProduct.id,
                  isFavorite: _editedProduct.isFavorite
                )
              ),
              TextFormField(
                initialValue: _initValues['price'],
                decoration: InputDecoration(
                  labelText: 'Price'
                ),
                validator: (value) {
                  if (value.isEmpty) return 'Please provide a price.';
                  if (double.tryParse(value) == null) return 'Please provide a valid price.';
                  if (double.parse(value) < 0) return 'Please provide a valid price';
                  return null;
                },
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                focusNode: _priceFocusNode,
                onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_descFocusNode),
                onSaved: (value) => _editedProduct = Product(
                  title: _editedProduct.title,
                  price: double.parse(value),
                  description: _editedProduct.description,
                  imageUrl: _editedProduct.imageUrl,
                  id: _editedProduct.id,
                  isFavorite: _editedProduct.isFavorite
                )
              ),
              TextFormField(
                initialValue: _initValues['description'],
                decoration: InputDecoration(
                  labelText: 'Description'
                ),
                validator: (value) {
                  if (value.isEmpty) return 'Please provide a description.';
                  if (value.length < 10) return 'Please provide at least 10 characters long description.';
                  return null;
                },
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                focusNode: _descFocusNode,
                onSaved: (value) => _editedProduct = Product(
                  title: _editedProduct.title,
                  price: _editedProduct.price,
                  description: value,
                  imageUrl: _editedProduct.imageUrl,
                  id: _editedProduct.id,
                  isFavorite: _editedProduct.isFavorite
                )
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                    width: 100,
                    height: 100,
                    margin: EdgeInsets.only(
                      top: 8,
                      right: 10
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: Colors.grey
                      )
                    ),
                    child: _imageUrlController.text.isEmpty ? Text('Enter a URL') : FittedBox(
                      child: Image.network(_imageUrlController.text),
                      fit: BoxFit.cover
                    )
                  ),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Image URL'
                      ),
                      validator: (value) {
                        if (value.isEmpty) return 'Please provide a image URL.';
                        if (!value.startsWith('http') || !value.startsWith('https')) return 'Please provide a valid URL.';
                        if (!value.endsWith('.png') && !value.endsWith('.jpg') && !value.endsWith('.jpeg')) return 'Please provide a valid URL.';
                        return null;
                      },
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.done,
                      controller: _imageUrlController,
                      focusNode: _imageUrlFocusNode,
                      onFieldSubmitted: (_) => _saveForm(),
                      onSaved: (value) => _editedProduct = Product(
                        title: _editedProduct.title,
                        price: _editedProduct.price,
                        description: _editedProduct.description,
                        imageUrl: value,
                        id: _editedProduct.id,
                        isFavorite: _editedProduct.isFavorite
                      )
                    )
                  )
                ]
              )
            ]
          )
        )
      )
    );
  }
}