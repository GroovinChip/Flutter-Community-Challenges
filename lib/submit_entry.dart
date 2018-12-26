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
import 'package:rounded_modal/rounded_modal.dart';
import 'package:rxdart/rxdart.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';

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

typedef CurrentUserBuilderFunction = Function(BuildContext, FirebaseUser);

class GithubRepository {
  final String name;
  final String url;

  GithubRepository(dynamic repoData):
    name = repoData['name'],
    url = '${repoData['html_url']}/${repoData['name']}';

  @override
  int get hashCode => name.hashCode ^ url.hashCode;

  @override
  bool operator ==(o) => o is GithubRepository
    && o.name == name
    && o.url == url;
}

class CurrentUserBuilder extends StatelessWidget {
  final CurrentUserBuilderFunction builder;

  const CurrentUserBuilder({Key key, @required this.builder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseUser>(
      future: FirebaseAuth.instance.currentUser(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        return builder(context, snapshot.data);
      }
    );
  }
}

class _SubmitEntryToChallengeState extends State<SubmitEntryToChallenge> {
  final storage = LocalStorage("Repositories");
  final _repositoriesSubject = BehaviorSubject<RepositoriesState>(seedValue: RepositoriesState.loading());
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  PermissionStatus status;
  GithubRepository _githubRepo;
  TextEditingController _appNameController = TextEditingController();
  TextEditingController _submissionDescriptionController = TextEditingController();
  List<File> _screenshots = [];
  List<File> _selectedScreenshots = [];

  File _image;

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return;
    }

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

  void submitEntry(FirebaseUser currentUser) async {
    if(!formKey.currentState.validate()) {
      return;
    }

    final docs = await Firestore.instance.collection("CurrentChallenge").getDocuments();
    if (docs.documents.isEmpty) {
      return;
    }

    final snackBarController = _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text("Submitting..."),
            const Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: CircularProgressIndicator(),
            ),
          ],
        ),
      )
    );

    final imageBase64 = _screenshots.map((f) {
      return base64Encode(f.readAsBytesSync());
    }).toList();

    final challenge = docs.documents.first;

    await Firestore.instance.collection("ChallengeEntries").document(currentUser.uid).setData({
      "Challenge": challenge.documentID,
      "Repo": _githubRepo.url,
      "Description": _submissionDescriptionController.text,
      "Images": imageBase64,
    });

    snackBarController.close();
    Navigator.of(context).pop();
  }

  Widget _buildLoadingDropdown() {
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

  deleteSelectedImages() {
    setState(() {
      _selectedScreenshots.forEach((s) => _screenshots.remove(s));
      _selectedScreenshots = [];
    });
  }

  void onRepositorySelect(GithubRepository repository) {
    final usingRepositoryName = _githubRepo?.name == _appNameController.text;

    setState(() {
      _githubRepo = repository;

      if (usingRepositoryName || _appNameController.text.isEmpty) {
        _appNameController.text = repository.name;
      }
    });
  }

  Widget _buildReposDropdown(DocumentSnapshot userDocument) {
    return StreamBuilder(
      stream: _repositoriesSubject.stream,
      initialData: _repositoriesSubject.value,
      builder: (context, AsyncSnapshot<RepositoriesState> snapshot) {
        final status = snapshot.data;

        if (!snapshot.hasData || status.isLoading) {
          return _buildLoadingDropdown();
        }

        final _githubRepos = status.repos.map<DropdownMenuItem<GithubRepository>>((repo) {
          return DropdownMenuItem<GithubRepository>(
            child: Text(repo['name']),
            value: GithubRepository(repo),
          );
        }).toList();

        return Row(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: OutlineDropdownButtonFormField<GithubRepository>(
                  items: _githubRepos,
                  value: _githubRepo,
                  onChanged: (value) => onRepositorySelect(value),
                  validator: (repo) {
                    print(repo);
                    return repo == null ? 'This field is required' : null;
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
                onPressed: () => refreshRepositories(userDocument),
              ),
              flex: 1,
            ),
          ],
        );
      }
    );
  }

  void _onImageSelected(File image) {
    if (_selectedScreenshots.isEmpty) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (ctx) {
          return PhotoView(
            imageProvider: FileImage(image)
          );
        },
        fullscreenDialog: true,
      ));
    } else {
      if (_selectedScreenshots.contains(image)) {
        _selectedScreenshots.remove(image);
      } else {
        _selectedScreenshots.add(image);
      }
    }
  }

  Widget _buildImageGrid() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      physics: NeverScrollableScrollPhysics(),
      itemCount: _screenshots.length,
      itemBuilder: (context, index) {
        final image = _screenshots[index];

        final child = _selectedScreenshots.contains(image)
        ? Image.file(_screenshots[index], color: Colors.black45, colorBlendMode: BlendMode.darken, fit: BoxFit.cover)
        : Image.file(_screenshots[index], fit: BoxFit.cover);

        return GridTile(
          child: GestureDetector(
            onLongPress: () {
              setState(() { 
                  if (_selectedScreenshots.contains(image)) {
                    _selectedScreenshots.remove(image);
                  } else {
                    _selectedScreenshots.add(image);
                  }
              });
            },
            onTap: () {
              setState(() {
                _onImageSelected(image);
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: child,
            )
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CurrentUserBuilder(
      builder: (context, currentUser) {
        final body = StreamBuilder<DocumentSnapshot>(
          stream: Firestore.instance.collection("Users").document(currentUser.uid).snapshots(),
          builder: (context, snapshot) {
            if(!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            final title = Text(
              "Submit Challenge Entry",
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            );

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
                        child: title,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0, top: 16.0),
                        child: _buildReposDropdown(snap),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TextFormField(
                          validator: (input) => input.isEmpty ? 'This field is required' : null,
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
                          title: _selectedScreenshots.isNotEmpty
                            ? Text("Selecting Images (${_selectedScreenshots.length} of ${_screenshots.length})")
                            : Text("Upload Screenshots"),
                          trailing: _selectedScreenshots.isNotEmpty
                          ? IconButton(
                            icon: Icon(Icons.delete, color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white),
                            onPressed: () => deleteSelectedImages(),
                          )
                          : IconButton(
                            icon: Icon(OMIcons.addPhotoAlternate, color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white),
                            onPressed: _screenshots.length > 5 ? null : () => getImage(),
                          ),
                        ),
                      ),
                      Expanded(child: _buildImageGrid()),
                    ],
                  ),
                ),
              ),
            );
          },
        );

        return Scaffold(
          key: _scaffoldKey,
          body: SafeArea(child: body),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          floatingActionButton: FloatingActionButton.extended(
            icon: Icon(Icons.cloud_upload),
            label: Text("Submit"),
            onPressed: () => submitEntry(currentUser),
          ),
          bottomNavigationBar: BottomAppBar(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context)
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
      },
    );
  }
}