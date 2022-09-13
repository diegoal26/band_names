import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/socket_service.dart';
class StatusPage extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    final socketService = Provider.of<SocketService>(context);
    return Scaffold(floatingActionButton: FloatingActionButton(child: Icon(Icons.message),
      onPressed: (){
        print('floating');
        socketService.socket.emit('emitir-flutter',{'nombre':'Flutter', 'mensaje':'Hola desde Flutter'});
      },),
      body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,
      children: [
      Text('Server Status:'+ socketService.serverStatus.name)
    ],)
      ),);
  }
}