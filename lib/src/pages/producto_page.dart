import 'dart:io';

import 'package:flutter/material.dart';
import 'package:formularios_bloc/src/models/producto_model.dart';
import 'package:formularios_bloc/src/providers/producto_provider.dart';
import 'package:formularios_bloc/src/utils/utils.dart' as utils;
import 'package:image_picker/image_picker.dart';

class ProductoPage extends StatefulWidget {
  ProductoPage({Key key}) : super(key: key);

  _ProductoPageState createState() => _ProductoPageState();
}

class _ProductoPageState extends State<ProductoPage> {

  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final productoProvider = new ProductoProvider();
  bool _guardando = false;
  File foto;

  ProductoModel producto = new ProductoModel();

  @override
  Widget build(BuildContext context) {

    final ProductoModel prodData = ModalRoute.of(context).settings.arguments;

    if(prodData!=null){
      producto = prodData;
    }


    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('Producto'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.photo_size_select_actual),
            onPressed: _seleccionarFoto,
          ),
          IconButton(
            icon: Icon(Icons.camera_alt),
            onPressed: _tomarFoto,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(15.0),
          child: Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                _mostrarFoto(),
                _crearNombre(),
                _crearPrecio(),
                _crearDisponible(),
                _crearBoton()
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _crearNombre(){
    return TextFormField(
      initialValue: producto.titulo,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: 'Producto'
      ),
      validator: (value){
        if(value.length<3){
          return 'Ingrese el nombre del producto';
        }else {
          return null;
        }
      },
      onSaved: (value)=>producto.titulo = value,
    );
  }

  Widget _crearPrecio(){
    return TextFormField(
      initialValue: producto.valor.toString(),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: 'Precio'
      ),
      validator: (value){
        if (utils.isNumeric(value)){
          return null;
        } else {
          return 'Solo se aceptan numeros';
        }
      },
      onSaved: (value)=>producto.valor = double.parse(value)
    );
  }

  Widget _crearDisponible(){
    return SwitchListTile(
      value: producto.disponible,
      title: Text('Disponible'),
      onChanged: (value)=>setState((){
        producto.disponible=value;
      }),
      activeColor: Colors.deepPurple,
    );
  }

  Widget _crearBoton(){
    return RaisedButton.icon(
      label: Text('Guardar'),
      icon: Icon(Icons.save),
      onPressed: (_guardando) ? null : _submit,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0)
      ),
      color: Colors.deepPurple,
      textColor: Colors.white,
    );
  }

  void _submit() async{
    if(!formKey.currentState.validate()) return;

    formKey.currentState.save();
    setState(() {_guardando=true;});

    if(foto!=null){
      producto.fotoUrl= await productoProvider.subirImagen(foto);
    }

    if(producto.id ==null){
      productoProvider.crearProducto(producto);
    }else {
      productoProvider.actualizarProducto(producto);
    }   
    // setState(() {
    //   _guardando=false;
    // });
    mostrarSnackbar('Registro guardado'); 
    Navigator.pop(context);
  }

  void mostrarSnackbar(String mensaje){
    final snackBar = SnackBar(
      content:Text(mensaje),
      duration: Duration(milliseconds: 1500),
    );
    scaffoldKey.currentState.showSnackBar(snackBar);
  }

  _mostrarFoto(){
    if(producto.fotoUrl != null){      
      return FadeInImage(
                image: NetworkImage(producto.fotoUrl),
                placeholder: AssetImage('assets/jar-loading.gif'),
                height: 300.0,
                width: double.infinity,
                fit: BoxFit.cover
      );
    } else {
      return Image(
        image: AssetImage(foto?.path ??  'assets/no-image.png'),
        height: 300.0,
        fit: BoxFit.cover,
      );
    }
  }

  void _seleccionarFoto() {
    _procesarImagen(ImageSource.gallery);   
  }

  void _tomarFoto() {
    _procesarImagen(ImageSource.camera);
  }

  void _procesarImagen(ImageSource source) async{
    foto =  await ImagePicker.pickImage(
      source: source
    );
    if(foto != null){
      producto.fotoUrl = null;
    }

    setState(() {}); 
  }
}