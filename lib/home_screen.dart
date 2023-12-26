import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  List<Map<String,dynamic>> _list = [];

  final _todoBox = Hive.box('To Do box');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _refreshList();
  }
  void _refreshList(){
    final data = _todoBox.keys.map((key){
      final list = _todoBox.get(key);
      return {"key": key, "title": list["title"], "description": list["description"]};
    }).toList();
    setState(() {
      _list = data.reversed.toList();
      debugPrint('${_list.length}');
    });
  }



  Future<void> _createItem(Map<String, dynamic > newItem)async{
    await _todoBox.add(newItem);
    _refreshList();
  }

  Future<void> _updateItem(int itemKey, Map<String, dynamic > list)async{
    await _todoBox.put(itemKey ,  list);
    _refreshList();
  }

  Future<void> _deleteItem(int itemKey)async{
    await _todoBox.delete(itemKey);
    _refreshList();

    ScaffoldMessenger.of(context).showSnackBar(

      const SnackBar(content: Text("Task Deleted"))
    );

  }





  void _showForm(BuildContext context , int?  itemKey)async{

    if(itemKey != null ){
      final existingItem = _list.firstWhere((element) => element['key'] == itemKey);
      titleController.text = existingItem['title'];
      descriptionController.text= existingItem['description'];

    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 15,
        left: 15,
        right: 15,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(

                hintText: 'Title'
              ),
            ),
            const SizedBox(height: 10,),
            TextField(
              controller: descriptionController,
              maxLines: null,

              decoration: const InputDecoration(
                  hintText: 'Description'
              ),
            ),
            const SizedBox(height: 20,),
            ElevatedButton(
                onPressed: ()async{

                  if(itemKey == null){

                  _createItem({
                    "title" : titleController.text,
                    "description" : descriptionController.text,
                    "key" : itemKey,

                  });
                  }

                  if(itemKey != null){
                    _updateItem(itemKey, {
                      'title': titleController.text.trim(),
                      'description': descriptionController.text.trim(),
                    });
                  }

                  titleController.text = '';
                  descriptionController.text = '';

                  Navigator.of(context).pop();

            }, child: Text(  itemKey == null ? 'Create New' : "Update")),
            const SizedBox(height: 15,),

        ],),
      ),
    ));

  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: const Text('To do List'),
      ),
      body: ListView.builder(
        itemCount: _list.length,
          itemBuilder: (_, index) {
          final currentList = _list[index];
          return Card(

            color: Colors.grey,
            margin: const EdgeInsets.all(10),
            elevation: 3,
            child: ListTile(

              title: Text(currentList['title'].toString() , style: const TextStyle(fontWeight: FontWeight.bold , fontSize: 25 , color: Colors.white),),
              subtitle: Text(currentList['description'].toString() , style: const TextStyle(fontSize: 15 , color: Colors.black45),),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [

                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: ()=> _showForm(context, currentList['key']), ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: ()=> _deleteItem(currentList['key'])),

                ],
              ),
            ),
          );



          }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueGrey,
        onPressed: () => _showForm(context, null),
        child: const Icon(Icons.add , ),
      ),
    );
  }
}
