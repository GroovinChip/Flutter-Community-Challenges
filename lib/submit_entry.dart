import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:groovin_material_icons/groovin_material_icons.dart';
import 'package:localstorage/localstorage.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:groovin_widgets/groovin_widgets.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class SubmitEntryToChallenge extends StatefulWidget {
  @override
  _SubmitEntryToChallengeState createState() => _SubmitEntryToChallengeState();
}

class _SubmitEntryToChallengeState extends State<SubmitEntryToChallenge> {
  String _githubRepo;
  List<String> repoNames = [];
  TextEditingController _appNameController = TextEditingController();
  TextEditingController _submissionDescriptionController = TextEditingController();
  List<File> _screenshots = [];
  final LocalStorage storage = LocalStorage("Repositories");
  bool refreshButtonChecked = false;

  File _image;

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
      _screenshots.add(_image);
    });
  }

  @override
  void initState() {
    super.initState();
  }

  Future getRepositories() async {
    if(refreshButtonChecked == false) {
      var repositories = storage.getItem("user_repositories");
      return repositories;
    } else {
      /*var repoResponse = await http.get(reposURL, headers: {HttpHeaders.authorizationHeader : "Bearer " + token});
      var repoJson = json.decode(repoResponse.body); */
      print("refresh button clicked");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: FirebaseAuth.instance.currentUser(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return CircularProgressIndicator();
            }
            final currentUser = snapshot.data;
            return StreamBuilder<DocumentSnapshot>(
              stream: Firestore.instance.collection("Users").document(currentUser.uid).snapshots(),
              builder: (context, snapshot) {
                if(!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  final snap = snapshot.data;
                  return SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0, bottom: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "Submit Challenge Entry",
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0, top: 16.0),
                          child: FutureBuilder(
                            future: getRepositories(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                               /* http.Response response = snapshot.data;
                                var reposJson = json.decode(response.body) as List;*/
                                //var repositoriesList = snapshot.data
                                List<DropdownMenuItem> _githubRepos = snapshot.data.map<DropdownMenuItem>((repo) {
                                  return DropdownMenuItem(
                                    child: Text(repo['name']),
                                    value: repo['name'],
                                  );
                                }).toList();
                                return Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 16.0),
                                        child: OutlineDropdownButton(
                                          items: _githubRepos,
                                          value: _githubRepo,
                                          onChanged: (value) {
                                            setState(() {
                                              _appNameController.text = value;
                                              _githubRepo = value;
                                            });
                                          },
                                          hint: Row(
                                            children: <Widget>[
                                              Padding(
                                                padding: const EdgeInsets.only(left: 4.0),
                                                child: Icon(
                                                    GroovinMaterialIcons.github_circle),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(left: 10.0),
                                                child: Text("Choose Repo"),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      flex: 7,
                                    ),
                                    Expanded(
                                      child: IconButton(
                                        icon: Icon(Icons.refresh),
                                        onPressed: (){
                                          //refreshButtonChecked = true;
                                          getRepositories();
                                        },
                                      ),
                                      flex: 1,
                                    ),
                                  ],
                                );
                              } else {
                                return Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: OutlineDropdownButton(
                                    items: [
                                      DropdownMenuItem(
                                        value: "",
                                        child: Row(
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.only(left: 4.0),
                                              child: Icon(GroovinMaterialIcons.github_circle),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 10.0),
                                              child: Text("Loading repositories..."),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 10.0),
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                    value: "",
                                    onChanged: (value) {
                                      setState(() {
                                        _githubRepo = value;
                                      });
                                    },
                                    hint: Row(
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(left: 4.0),
                                          child: Icon(
                                              GroovinMaterialIcons.github_circle),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 10.0),
                                          child: Text("Choose Repo"),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                            }
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: TextField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "App Name",
                              prefixIcon: Icon(OMIcons.shortText)
                            ),
                            controller: _appNameController,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: TextField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Submission Description",
                              prefixIcon: Icon(OMIcons.textsms)
                            ),
                            maxLines: 2,
                            controller: _submissionDescriptionController,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0),
                          child: Divider(
                            color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0),
                          child: ListTile(
                            //leading: Icon(OMIcons.image),
                            title: Text("Upload Screenshots"),
                            trailing: IconButton(
                              icon: Icon(OMIcons.addPhotoAlternate, color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white),
                              onPressed: () {
                                getImage();
                              },
                            ),
                          ),
                        ),
                        /*Padding(
                          padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                          child: Container(
                            height: 50.0,
                            child: ListView.builder(
                              itemCount: _screenshots.length,
                              itemBuilder: (builder, index) {
                                return ListTile(
                                  leading: Image.file(_screenshots[index]),
                                );
                              },
                            ),
                          ),
                        ),*/
                      ],
                    ),
                  );
                }
              },
            );
          },
        )
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.cloud_upload),
        label: Text("Submit"),
        onPressed: () {},
      ),
      bottomNavigationBar:  BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            IconButton(
              icon: Icon(OMIcons.info),
              onPressed: () {

              },
            ),
          ],
        ),
      ),
    );
  }
}