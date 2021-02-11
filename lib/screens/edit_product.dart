import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products.dart';
import '../providers/product.dart';

enum OVERLAY_POSITION { TOP, BOTTOM }

class EditProductScreen extends StatefulWidget {
  static const routeNamee = '/product-management';
  EditProductScreen({Key key}) : super(key: key);

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descripFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var pageName = '';
  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };
  var _isInit = true;
  var _isLoading = false;

  var _editedProduct = Product(
    id: null,
    title: '',
    description: '',
    price: 0,
    imageUrl: '',
  );
  @override
  void initState() {
    // TODO: implement initState
    _imageUrlFocusNode.addListener(_updateImageUrl);

    super.initState();
  }

  Future<void> _errorAlert() {
    return showDialog<Null>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An error occurred!'),
        content: Text('Something went wrong.'),
        actions: [
          FlatButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text('Okay'))
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    pageName = 'Add product';
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        pageName = 'Edit product';

        _editedProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        _initValues = {
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': _editedProduct.price.toString(),
          //'imageUrl': _editedProduct.imageUrl,
          'imageUrl': '',
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _imageUrlController.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descripFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();

    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedProduct.id != null) {
      try {
        await Provider.of<Products>(context, listen: false)
            .updateProduct(_editedProduct.id, _editedProduct);
      } catch (e) {
        await _errorAlert();
      }
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (e) {
        await _errorAlert();
      } finally {
        /* setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop(); */
      }
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  void _setValues(
      String title, String description, double price, String imageUrl) {
    _editedProduct = Product(
      id: _editedProduct.id,
      isFavorite: _editedProduct.isFavorite,
      title: title.isNotEmpty ? title : _editedProduct.title,
      description:
          description.isNotEmpty ? description : _editedProduct.description,
      price: price.isNegative ? _editedProduct.price : price,
      imageUrl: imageUrl.isNotEmpty ? imageUrl : _editedProduct.imageUrl,
    );
  }

  String _imageValidator(value) {
    if (value.isEmpty) {
      return 'Image URL must be not null.';
    }
    if (!value.startsWith('http') && !value.startsWith('https')) {
      return 'Enter a valid URL.';
    }
    if (!value.endsWith('.jpg') &&
        !value.endsWith('png') &&
        !value.endsWith('jpeg')) {
      return 'Enter a valid image URL.';
    }
    return null;
  }

  TapDownDetails _tapDownDetails;
  OverlayEntry _overlayEntry;
  OVERLAY_POSITION _overlayPosition;

  double _statusBarHeight;
  double _toolBarHeight;

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject();

    var size = renderBox.size;

    var offset = renderBox.localToGlobal(Offset.zero);
    var globalOffset = renderBox.localToGlobal(_tapDownDetails.globalPosition);

    _statusBarHeight = MediaQuery.of(context).padding.top;

    // TODO: Calculate ToolBar Height Using MediaQuery
    _toolBarHeight = 50;
    var screenHeight = MediaQuery.of(context).size.height;

    var remainingScreenHeight =
        screenHeight - _statusBarHeight - _toolBarHeight;

    if (globalOffset.dy > remainingScreenHeight / 2) {
      _overlayPosition = OVERLAY_POSITION.TOP;
    } else {
      _overlayPosition = OVERLAY_POSITION.BOTTOM;
    }
    return OverlayEntry(builder: (context) {
      return Stack(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              _overlayEntry.remove();
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.blueGrey.withOpacity(0.1),
            ),
          ),
          Positioned(
            left: offset.dy + size.width - 110.0,
            //right: offset.dy + size.width + 100.0,
            /*      top: _overlayPosition == OVERLAY_POSITION.TOP
                ? _statusBarHeight + _toolBarHeight
                : offset.dy + size.height - 5.0, */
            bottom: offset.dx + size.height - 400.0,
            // top: offset.dx,

            width: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // ignore: sdk_version_ui_as_code
                if (_overlayPosition == OVERLAY_POSITION.BOTTOM) nip(),
                body(context, offset.dy),
                // ignore: sdk_version_ui_as_code
                if (_overlayPosition == OVERLAY_POSITION.TOP) nip(),
                // body(context, offset.dy),
              ],
            ),
          )
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (!_isLoading) {
          return Future.value(true);
        }
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          actions: [
            if (!_isLoading)
              IconButton(
                icon: Icon(Icons.save),
                onPressed: _saveForm,
              ),
          ],
          title: Text(pageName),
        ),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  strokeWidth: 10,
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                    autovalidateMode: AutovalidateMode.always,
                    key: _form,
                    onWillPop: () {
                      return Future.value(true);
                    },
                    child: ListView(
                      children: [
                        TextFormField(
                          initialValue: _initValues['title'],
                          decoration: InputDecoration(
                              labelText: 'Title', errorStyle: TextStyle()),
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_priceFocusNode);
                          },
                          onSaved: (value) {
                            _setValues(value, '', -1, '');
                          },
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Title must be not null.';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          initialValue: _initValues['price'],
                          decoration: InputDecoration(labelText: 'Price'),
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          focusNode: _priceFocusNode,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Price must be not null.';
                            }

                            if (double.tryParse(value) == null) {
                              return 'Price must be a number Only (not contains a string).';
                            }
                            if (double.parse(value).isNegative) {
                              return 'Price must be not Negative number.';
                            }
                            if (double.parse(value) == 0) {
                              return 'Price must be greater than zero.';
                            }
                            return null;
                          },
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_descripFocusNode);
                          },
                          onSaved: (value) {
                            _setValues('', '', double.parse(value), '');
                          },
                        ),
                        TextFormField(
                            initialValue: _initValues['description'],
                            decoration:
                                InputDecoration(labelText: 'Description'),
                            maxLines: 3,
                            maxLength: 240,
                            keyboardType: TextInputType.multiline,
                            focusNode: _descripFocusNode,
                            onSaved: (value) {
                              _setValues('', value, -1, '');
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Description must be not null.';
                              }
                              if (value.length < 10) {
                                return 'Should be at least 10 characters long.';
                              }
                              return null;
                            }),
                        Row(
                          children: [
                            Visibility(
                              //   maintainSemantics: true,
                              // maintainInteractivity: true,
                              /*  replacement: Container(
                      //  width: 1,
                      child: Text('Enter a URL'),
                    ) */
                              //maintainSize: true,
                              // maintainAnimation: true,
                              // maintainState: true,
                              visible:
                                  _imageValidator(_imageUrlController.text) ==
                                          null
                                      ? true
                                      : false,
                              // imageUrlController.text.isNotEmpty,
                              child: Container(
                                  width: 100,
                                  height: 100,
                                  margin: EdgeInsets.only(top: 8, right: 10),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                    color: Colors.grey,
                                    width: 1,
                                  )),
                                  child: FittedBox(
                                    child: Image.network(
                                        _imageUrlController.text,
                                        errorBuilder: (ctx, obj, stack) =>
                                            Text('Invalid Image url'),
                                        fit: BoxFit.contain),
                                  )),
                            ),
                            Expanded(
                                child: TextFormField(
                              //  initialValue: _initValues['imageUrl'],
                              decoration: InputDecoration(
                                  labelText: 'Image URL',
                                  suffixIcon: GestureDetector(
                                    child: Icon(Icons.remove_red_eye),
                                    onLongPress: () {
                                      print('long');
                                    },
                                    onTapDown: (d) {
                                      print('longe');
                                      print(d.globalPosition);

                                      setState(() {
                                        _tapDownDetails = d;
                                      });
                                      this._overlayEntry =
                                          this._createOverlayEntry();
                                      Overlay.of(context)
                                          .insert(this._overlayEntry);

                                      /*         final RenderBox overlay = Overlay.of(context)
                                    .context
                                    .findRenderObject();

                                showMenu(
                                  color: Colors.transparent,
                                  context: context,
                                  position: RelativeRect.fromRect(
                                      d.globalPosition &
                                          Size(40,
                                              40), // smaller rect, the touch area
                                      Offset.zero &
                                          overlay
                                              .size // Bigger rect, the entire screen
                                      ),
                                  items: [
                                    PopupMenuItem(
                                      child: Image.network(
                                        _imageUrlController.text,
                                        errorBuilder: (ctx, obj, stack) =>
                                            Text('Invalid Image url'),
                                        fit: BoxFit.contain,
                                        height: 100,
                                        width: 100,
                                      ),
                                    ),
                                  ],
                                  elevation: 8.0,
                                );
                         */
                                    },
                                    onLongPressEnd: (d) {
                                      print('longe');
                                      print(d.globalPosition);
                                    },
                                  )),
                              keyboardType: TextInputType.url,
                              textInputAction: TextInputAction.done,
                              controller: _imageUrlController,

                              /*   onChanged: (_) {
                        setState(() {});
                      }, */
                              onEditingComplete: () {
                                setState(() {});
                              },
                              onFieldSubmitted: (_) {
                                _saveForm();
                              },
                              focusNode: _imageUrlFocusNode,
                              onSaved: (value) {
                                _setValues('', '', -1, value);
                              },
                              validator: _imageValidator,
                              onChanged: (_) {
                                // _form.currentState.validate();
                                if (_imageValidator(_imageUrlController.text) ==
                                    null) {
                                  setState(() {});
                                }
                              },
                            ))
                          ],
                        ),
                      ],
                    )),
              ),
      ),
    );
  }

  Widget body(BuildContext context, double offset) {
    return Material(
      borderRadius: BorderRadius.all(
        Radius.circular(8.0),
      ),
      elevation: 4.0,
      child: Container(
          width: 100,
          //margin: EdgeInsets.only(),
          height: _overlayPosition == OVERLAY_POSITION.BOTTOM ? 100 : 100,
          padding: const EdgeInsets.symmetric(horizontal: 8.0),

          /* ListView(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          children: [
            "First",
            "Second",
            "Third",
            "First",
            "Second",
            "Third",
            "First",
            "Second",
            "Third"
          ]
              .map((String s) => ListTile(
                    subtitle: Text(s),
                  ))
              .toList(growable: false),
        ) */

          child: FittedBox(
            child: Image.network(_imageUrlController.text,
                errorBuilder: (ctx, obj, stack) {
              print(
                _tapDownDetails.globalPosition.dy -
                    _toolBarHeight -
                    _statusBarHeight -
                    15,
              );
              return Text('Invalid Image url');
            }, fit: BoxFit.contain),
          )),
    );
  }

  Widget nip() {
    return Container(
      height: 10.0,
      width: 10.0,
      margin: EdgeInsets.only(
          left: _tapDownDetails.globalPosition.dx,
          right: _tapDownDetails.globalPosition.dx),
      child: CustomPaint(
        painter: OpenPainter(_overlayPosition),
      ),
    );
  }
}

class OpenPainter extends CustomPainter {
  final OVERLAY_POSITION overlayPosition;

  OpenPainter(this.overlayPosition);

  @override
  void paint(Canvas canvas, Size size) {
    switch (overlayPosition) {
      case OVERLAY_POSITION.TOP:
        var paint = Paint()
          ..style = PaintingStyle.fill
          ..color = Colors.white
          ..isAntiAlias = true;

        _drawThreeShape(canvas,
            first: Offset(0, 0),
            second: Offset(20, 0),
            third: Offset(10, 15),
            size: size,
            paint: paint);

        break;
      case OVERLAY_POSITION.BOTTOM:
        var paint = Paint()
          ..style = PaintingStyle.fill
          ..color = Colors.white
          ..isAntiAlias = true;

        _drawThreeShape(canvas,
            first: Offset(15, 0),
            second: Offset(0, 20),
            third: Offset(30, 20),
            size: size,
            paint: paint);

        break;
    }

    canvas.save();
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;

  void _drawThreeShape(Canvas canvas,
      {Offset first, Offset second, Offset third, Size size, paint}) {
    var path1 = Path()
      ..moveTo(first.dx, first.dy)
      ..lineTo(second.dx, second.dy)
      ..lineTo(third.dx, third.dy);
    canvas.drawPath(path1, paint);
  }

  void _drawTwoShape(Canvas canvas,
      {Offset first, Offset second, Size size, paint}) {
    var path1 = Path()
      ..moveTo(first.dx, first.dy)
      ..lineTo(second.dx, second.dy);
    canvas.drawPath(path1, paint);
  }
}
