// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final CollectionReference _mainCollection = _firestore.collection('users');

class DataBase{
  static String? userUid;
  static String? name;

  /*static getUid() async {
    FirebaseAuth.instance.authStateChanges().listen((user) { userUid= user?.uid; });
  }*/

  static Future<void> addListNewUser() async{
    print(userUid);
    DocumentReference documentReference = _mainCollection.doc(userUid);
    //converting json to map  
    var jsonTaskList = await http.get(Uri.parse("https://firebasestorage.googleapis.com/v0/b/go-green-8868a.appspot.com/o/go-green-tasks2.json?alt=media&token=34de5b20-eb70-4b73-9f61-6cd1fbb06bbd"));
    var decTaskList= jsonDecode(jsonTaskList.body);

    Map<String, bool> convertedTaskList={};
    decTaskList.forEach((index)=> convertedTaskList[index['task-name']]= index['completed']);

   //print(decTaskList);

   await documentReference.set({'tasklist':convertedTaskList}).whenComplete(() => print("tasklist uploaded")).catchError((error) => print(error));
   await documentReference.update({'score':0});
   await documentReference.update({'name': FirebaseAuth.instance.currentUser?.displayName});
   }
  
  static Future<Map<String, dynamic>> readTasksList() async{
    print("uid inside readTasksList : $userUid");
    DocumentReference userDoc = _mainCollection.doc(userUid);
    final docSnap=await userDoc.get().whenComplete(() => {print("tasklist downloaded")});
    if(docSnap.exists){
      print("Document data: ${docSnap.data()}");
    }
    else {
      print("No such document");
    }
    if(docSnap.data()==null) 
    {
      await DataBase.addListNewUser();
      return readTasksList();
    }
   return docSnap.data() as Map<String, dynamic>;
  }

  static Future<void> updateTaskStatus({required String taskName, bool? status, int? score})async {

    DocumentReference documentReference= _mainCollection.doc(userUid);

    documentReference.set({'tasklist':{taskName:status}}, SetOptions(merge: true));
    documentReference.update({'score':score});
  }
 }
 