import 'dart:io';
import 'package:band_names/services/socket_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:band_names/models/band.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget{
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands =[];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('active-bands', _handleActiveBands);
    super.initState();
  }

  _handleActiveBands(dynamic payload){
    bands.clear();

    print(payload);
    for(var band in payload){
        this.bands.add(Band.fromMap(band));
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context){
    final socketService = Provider.of<SocketService>(context);
    //bands = socketService.bands;

    return Scaffold(appBar: AppBar(elevation: 1,
    actions: [
      Container(margin: EdgeInsets.only(right: 10), 
      child: socketService.serverStatus.name=='Online'?Icon(Icons.check_circle, color: Colors.blue[300],):
      Icon(Icons.offline_bolt, color: Colors.red,),)
    ],
      title: Text('BandNames',style: TextStyle(color: Colors.black87),),
    backgroundColor: Colors.white,),
      body: Column(children: [
        FutureBuilder(
          builder:(BuildContext context, AsyncSnapshot<String> snapshot) {
          if(bands.length>0){
            return _showGraph();
          }else{
            return Container(width: double.infinity,
              height: 10,);
          }
          
        }),
        Expanded(
          child: ListView.builder(
            itemCount: bands.length,
            itemBuilder: (BuildContext context, int index) => _bandTile(bands[index])
                ),
        ),
      ],),
      floatingActionButton: FloatingActionButton(elevation: 1,
        child: Icon(Icons.add),
        onPressed: addNewBand
        ),);
  }

  Widget _showGraph(){
    Map<String, double> dataMap = new Map();
    bands.forEach((band){
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    });
    
    final List<Color> colorList = [Colors.blue[50]!, Colors.blue[200]!,
    Colors.pink[50]!, Colors.pink[200]! ];
    return Container(width: double.infinity,
      height: 200,
      child: PieChart(colorList: colorList,
      chartType: ChartType.disc,
      dataMap: dataMap));
    
  }

  Widget _bandTile(Band band){
    final socketService = Provider.of<SocketService>(context);
    return Dismissible(key: Key(band.id),
    direction: DismissDirection.startToEnd,
    onDismissed: (direction) => socketService.emit('delete-band',{'id':band.id}),
    background: Container(padding: EdgeInsets.only(left: 8.0),
      child: Align(alignment: Alignment.centerLeft,
      child: Text('Delete Band', style: TextStyle(color: Colors.white),)),
      color: Colors.red,),
    child: ListTile(leading: CircleAvatar(child: Text(band.name.substring(0,2)),
    backgroundColor: Colors.blue[100],),
    title: Text(band.name),
    trailing: Text('${band.votes}', style: TextStyle(fontSize: 20),),
    onTap: () => socketService.socket.emit('vote-band',{'id':band.id}),),
  );
  }

  addNewBand(){
    final textController = new TextEditingController();
    if(Platform.isAndroid){
      return showDialog(context: context, builder: (context){

      final socketService = Provider.of<SocketService>(context);

      return AlertDialog(title: Text('New band name:'),
      content: TextField(
        controller: textController,
      ),
      actions: [
        MaterialButton(child: Text('Add'),
          elevation: 5,
          textColor: Colors.blue,
          onPressed: (){
            addBandToList(textController.text, socketService);
        })
      ],);
      });
    }

    showCupertinoDialog(context: context, builder: (context){
      final socketService = Provider.of<SocketService>(context);
      return CupertinoAlertDialog(title: Text('New band name:'),
      content: CupertinoTextField(controller: textController,),
      actions: [
        CupertinoDialogAction(child: Text('Add'), isDefaultAction: true,
        onPressed: (){
          addBandToList(textController.text, socketService);},),

        CupertinoDialogAction(child: Text('Dismiss'),isDestructiveAction: true,
        onPressed: (){
          Navigator.pop(context);
         },)
      ],);
    });
  }

  addBandToList(String name, SocketService socketService){
    //final socketService = Provider.of<SocketService>(context);
    if(name.length > 1){
      /*this.bands.add(new Band(id:DateTime.now().toString(),name: name, votes: 0));
      setState(() {});*/

      socketService.socket.emit('add-band', {'name':name});
    }
    Navigator.pop(context);
  }
}