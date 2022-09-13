import 'package:band_names/models/band.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus{
  Online,
  Offline,
  Connecting
}

class SocketService with ChangeNotifier{
  ServerStatus _serverStatus = ServerStatus.Connecting;

  late IO.Socket _socket;

  IO.Socket get socket => _socket;

  ServerStatus get serverStatus => _serverStatus;

  Function get emit => this._socket.emit;

  List<Band> bands = [];

  SocketService(){
    this._initConfig();
  }

  void _initConfig(){
    //this._socket = IO.io('http://10.30.0.126:3000',{
    this._socket = IO.io('http://192.168.100.15:3000',{
      'transports':['websocket'],
      'autoconnect': true
    });
    this._socket.on('connect', (_){
      print('Connect');
      _serverStatus = ServerStatus.Online;

      notifyListeners();
    });

    this._socket.on('disconnect',(_){
      print('disconnect');
      _serverStatus = ServerStatus.Offline;

      notifyListeners();
    });

    /*this._socket.on('active-bands',(bandas){
      for(var band in bandas){
        bands.add(Band.fromMap(band));
      }
    });*/

    /*socket.on('vote-band', (bandas){
      print('Recibo de vuelta');
      for(var band in bandas){
        bands.add(Band.fromMap(band));
      }
    });*/

    /*socket.on('nuevo-mensaje',(payload){
      print('Llega mensaje '+payload['admin']);
    });*/

    
  }
}