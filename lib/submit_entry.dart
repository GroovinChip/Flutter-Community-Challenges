import 'dart:io';
import 'dart:typed_data';
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
import 'package:rounded_modal/rounded_modal.dart';
import 'package:rxdart/rxdart.dart';
import 'package:permission_handler/permission_handler.dart';

class RepositoriesState {
  final bool isLoading;
  final List<dynamic> repos;

  RepositoriesState._internal({
    @required this.isLoading,
    @required this.repos
  });

  factory RepositoriesState.loading() {
    return RepositoriesState._internal(isLoading: true, repos: []);
  }

  factory RepositoriesState.success(List<dynamic> repos) {
    return RepositoriesState._internal(isLoading: false, repos: repos);
  }
}

class SubmitEntryToChallenge extends StatefulWidget {
  @override
  _SubmitEntryToChallengeState createState() => _SubmitEntryToChallengeState();
}

class _SubmitEntryToChallengeState extends State<SubmitEntryToChallenge> {
  PermissionStatus status;
  String _githubRepo;
  TextEditingController _appNameController = TextEditingController();
  TextEditingController _submissionDescriptionController = TextEditingController();
  List<File> _screenshots = [];
  final storage = LocalStorage("Repositories");
  final _repositoriesSubject = BehaviorSubject<RepositoriesState>(seedValue: RepositoriesState.loading());

  File _image;

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
      _screenshots.add(_image);
    });
  }

  // Check current permissions. If storage permission not granted, prompt for it.
  void checkPermissions() async {
    Map<PermissionGroup, PermissionStatus> permissions =
      await PermissionHandler.requestPermissions([PermissionGroup.storage]);
    PermissionStatus storagePermission =
      await PermissionHandler.checkPermissionStatus(PermissionGroup.storage);
  }

  @override
  void initState() {
    super.initState();
    this._load();
  }

  void _load() async {
    await storage.ready;

    _repositoriesSubject.add(RepositoriesState.success(storage.getItem("user_repositories")));
  }

  Future refreshRepositories(DocumentSnapshot snap) async {
    _repositoriesSubject.add(RepositoriesState.loading());
    final response = await http.get(snap['ReposUrl']);
    final repoJson = json.decode(response.body) as List;
    storage.setItem("user_repositories", repoJson);
    _repositoriesSubject.add(RepositoriesState.success(repoJson));
  }

  final formKey = GlobalKey<FormState>();

  void submitEntry() {
    if(formKey.currentState.validate()) {
      // submit entry
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
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height / 1,
                        child: Form(
                          key: formKey,
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
                                child: StreamBuilder(
                                  stream: _repositoriesSubject.stream,
                                  initialData: _repositoriesSubject.value,
                                  builder: (context, snapshot) {
                                    final status = snapshot.data;

                                    if (snapshot.hasData && !status.isLoading) {
                                      final _githubRepos = status.repos.map<DropdownMenuItem>((repo) {
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
                                                refreshRepositories(snap);
                                              },
                                            ),
                                            flex: 1,
                                          ),
                                        ],
                                      );
                                    } else {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                                          onChanged: (value) {},
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
                                child: TextFormField(
                                  validator: (input) => input == null || input == "" ? 'This field is required' : null,
                                  onSaved: (input) => _appNameController.text = input,
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
                                      //checkPermissions();
                                      getImage();
                                    },
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GridView.builder(
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                                  itemCount: _screenshots.length,
                                  itemBuilder: (context, index) {
                                    return GridTile(
                                      child: GestureDetector(
                                        onTap: () {
                                          showRoundedModalBottomSheet(
                                            context: context,
                                            dismissOnTap: false,
                                            builder: (context) {
                                              return Container(
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: <Widget>[
                                                    ListTile(
                                                      leading: Icon(OMIcons.delete),
                                                      title: Text("Remove screenshot"),
                                                      onTap: () {
                                                        setState(() {
                                                          _screenshots.removeAt(index);
                                                        });
                                                        Navigator.pop(context);
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }
                                          );
                                        },
                                        child: Image.file(_screenshots[index]),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
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
        onPressed: () {
          submitEntry();
        },
      ),
      bottomNavigationBar: BottomAppBar(
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