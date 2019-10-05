import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/http_exception.dart';
import '../providers/auth.dart';

enum AuthMode {
  Signup,
  Login
}

class AuthPage extends StatelessWidget {
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(215, 117, 244, 1).withOpacity(0.5),
                  Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0, 1]
              )
            )
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 94
                      ),
                      transform: Matrix4.rotationZ(-8 * pi / 180)..translate(-10.0),
                      child: Text(
                        'Cat Shop',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 50,
                          fontFamily: 'Anton',
                          fontWeight: FontWeight.normal
                        )
                      )
                    )
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: AuthCard()
                  )
                ]
              )
            )
          )
        ]
      )
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({
    Key key
  }) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': ''
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An Error Occurred!'),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            child: Text('Ok'),
            onPressed: () => Navigator.of(ctx).pop()
          )
        ]
      )
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) return;

    _formKey.currentState.save();
    setState(() => _isLoading = true);

    try {
      if (_authMode == AuthMode.Login) {
        await Provider.of<Auth>(context, listen: false).login(
          _authData['email'],
          _authData['password']
        );
      } else {
        await Provider.of<Auth>(context, listen: false).signup(
          _authData['email'],
          _authData['password']
        );
      }
    } on HttpException catch (err) {
      var errorMessage = 'Authentication failed.';
      if (err.toString().contains('EMAIL_EXISTS')) errorMessage = 'This email is already in use.';
      else if (err.toString().contains('INVALID_EMAIL')) errorMessage = 'This is not a valid email';
      else if (err.toString().contains('WEAK_PASSWORD')) errorMessage = 'This password is too weak.';
      else if (err.toString().contains('EMAIL_NOT_FOUND')) errorMessage = 'Could not find a user with email provided.';
      else if (err.toString().contains('INVALID_PASSWORD')) errorMessage = 'Invalid password.';
      _showErrorDialog(errorMessage);
    } catch (err) {
      const errorMessage = 'Could not authenticate you. Please try again later.';
      _showErrorDialog(errorMessage);
    }

    setState(() => _isLoading = false);
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() => _authMode = AuthMode.Signup);
    } else {
      setState(() => _authMode = AuthMode.Login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10)
      ),
      elevation: 8,
      child: Container(
        height: _authMode == AuthMode.Signup ? 320 : 260,
        constraints: BoxConstraints(
          minHeight: _authMode == AuthMode.Signup ? 320 : 260
        ),
        width: deviceSize.width * 0.75,
        padding: EdgeInsets.all(16),
        child: Form (
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value.isEmpty || !value.contains('@')) return 'Invalid email!';
                  },
                  onSaved: (value) {
                    _authData['email'] = value;
                  }
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value.isEmpty || value.length < 5) return 'Password is too short!';
                  },
                  onSaved: (value) {
                    _authData['password'] = value;
                  }
                ),
                if (_authMode == AuthMode.Signup) TextFormField(
                  enabled: _authMode == AuthMode.Signup,
                  decoration: InputDecoration(labelText: 'Confirm Password'),
                  obscureText: true,
                  validator: _authMode == AuthMode.Signup ? (value) {
                    if (value != _passwordController.text) return 'Passwords do not match!';
                  } : null
                ),
                SizedBox(height: 20),
                _isLoading ? CircularProgressIndicator() : RaisedButton(
                  child: Text(_authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP'),
                  onPressed: _submit,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 8
                  ),
                  color: Theme.of(context).primaryColor,
                  textColor: Theme.of(context).primaryTextTheme.button.color
                ),
                FlatButton(
                  child: Text('${_authMode == AuthMode.Login ? 'SIGN UP' : 'LOGIN'} INSTEAD'),
                  onPressed: _switchAuthMode,
                  padding: EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 4
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textColor: Theme.of(context).primaryColor
                )
              ]
            )
          )
        )
      )
    );
  }
}