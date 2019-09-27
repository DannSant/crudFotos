import 'package:flutter/material.dart';
import 'package:formularios_bloc/src/bloc/provider.dart';
import 'package:formularios_bloc/src/models/producto_model.dart';
import 'package:formularios_bloc/src/providers/producto_provider.dart';

class HomePage extends StatelessWidget {
 
  final productosProvider = new ProductoProvider();
  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('HomePage'),
      ),
      body: _crearListado(),
      floatingActionButton: _crearBoton(context),
    );
  }

  Widget _crearBoton(BuildContext context){
    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: ()=>Navigator.pushNamed(context, 'producto'),
      backgroundColor: Colors.deepPurple,
    );
  }

  Widget _crearListado(){
    return FutureBuilder(
      future: productosProvider.cargarProductos(),
      builder: (BuildContext c, AsyncSnapshot<List<ProductoModel>> snapshot){
        if(snapshot.hasData){
          final productos = snapshot.data;
          return ListView.builder(
            itemCount: productos.length,
            itemBuilder: (BuildContext c2,i) => _crearItem(c2,productos[i]),
          );
        }else {
          return Center(child: CircularProgressIndicator(),);
        }
      },
    );
  }

  Widget _crearItem(BuildContext c,ProductoModel producto){
    return Dismissible(
      key: UniqueKey(),
      background: Container(
        color: Colors.redAccent,
      ),
      onDismissed: (direccion){
        productosProvider.borrarProducto(producto.id);
      },
      child: Card(
        child: Column(
          children: <Widget>[
            (producto.fotoUrl == null) 
              ? Image(image: AssetImage('assets/no-image.png'),) 
              : FadeInImage(
                image: NetworkImage(producto.fotoUrl),
                placeholder: AssetImage('assets/jar-loading.gif'),
                height: 300.0,
                width: double.infinity,
                fit: BoxFit.cover
              ),
              ListTile(
                title: Text('${producto.titulo} - ${producto.valor}'),
                subtitle: Text(producto.id),
                onTap: ()=> Navigator.pushNamed(c, 'producto', arguments: producto),
              ),
          ],
        ),
      )
    );
  }
}