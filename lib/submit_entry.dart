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
import 'package:rxdart/rxdart.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view_gallery.dart';

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

class ImageTile extends StatelessWidget {
  final File image;
  final VoidCallback onLongPress;
  final VoidCallback onTap;
  final Image child;

  ImageTile({
    Key key,
    @required this.image,
    @required this.child,
    this.onLongPress,
    this.onTap
  }): super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridTile(
      child: GestureDetector(
        onLongPress: () => this.onLongPress(),
        onTap: () => this.onTap(),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Hero(
            child: child,
            tag: image.path,
          ),
        )
      ),
    );
  }
}

class _SubmitEntryToChallengeState extends State<SubmitEntryToChallenge> {
  final storage = LocalStorage("Repositories");
  final _repositoriesSubject = BehaviorSubject<RepositoriesState>(seedValue: RepositoriesState.loading());
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  final TextEditingController _submissionDescriptionController = TextEditingController();
  final TextEditingController _appNameController = TextEditingController();

  PermissionStatus status;
  GithubRepository _githubRepo;
  List<File> _screenshots = [];
  List<File> _selectedScreenshots = [];

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return;
    }

    setState(() {
      _screenshots.add(image);
    });
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

  Future _refreshRepositories(DocumentSnapshot snap) async {
    _repositoriesSubject.add(RepositoriesState.loading());
    final response = await http.get(snap['ReposUrl']);
    final repoJson = json.decode(response.body) as List;
    storage.setItem("user_repositories", repoJson);
    _repositoriesSubject.add(RepositoriesState.success(repoJson));
  }

  _submitEntry(FirebaseUser currentUser) async {
    if(!formKey.currentState.validate()) {
      return;
    }

    final docs = await Firestore.instance.collection("CurrentChallenge").getDocuments();
    if (docs.documents.isEmpty) {
      // Should be an edge case, or never happen, but maybe add an error?
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
    final loadingItem = DropdownMenuItem(
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
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: OutlineDropdownButton(
        items: [loadingItem],
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

  _deleteSelectedImages() {
    setState(() {
      _selectedScreenshots.forEach((s) => _screenshots.remove(s));
      _selectedScreenshots = [];
    });
  }

  _onRepositorySelect(GithubRepository repository) {
    final isUsingRepositoryName = _githubRepo?.name == _appNameController.text;

    setState(() {
      _githubRepo = repository;

      // Only set name if using pre-loaded or no name
      if (isUsingRepositoryName || _appNameController.text.isEmpty) {
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

        final dropdownHint = Row(
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
        );

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child:  Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: OutlineDropdownButtonFormField<GithubRepository>(
                  items: _githubRepos,
                  value: _githubRepo,
                  onChanged: (value) => _onRepositorySelect(value),
                  validator: (repo) => repo == null ? 'This field is required' : null,
                  hint: dropdownHint,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(8.0),
                    labelText: "Repository",
                    prefixIcon: Icon(Icons.code),
                  ),
                ),
              ),
              flex: 7,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: () => _refreshRepositories(userDocument),
                ),
              ),
              flex: 1,
            ),
          ],
        );
      }
    );
  }

  Future<bool> _showDeleteImageConfirmation() {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Remove Screenshot?"),
          content: const Text("Are you sure you want to remove the screenshot?"),
          actions: <Widget>[
            new FlatButton(
              child: const Text("No"),
              onPressed: () => Navigator.of(context).pop(false)
            ),
            new FlatButton(
              child: const Text("Yes"),
              onPressed: () => Navigator.of(context).pop(true)
            ),
          ],
        );
      },
    );
  }

  void _showImageGallery(File selectedImage) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (ctx) {
        final pages = _screenshots.map((f) => PhotoViewGalleryPageOptions(
          imageProvider: FileImage(f),
          heroTag: f.path
        )).toList();

        final backButton = IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => Navigator.of(context).pop(),
        );

        final deleteButton = IconButton(
          icon: const Icon(Icons.delete),
          color: Colors.white,
          onPressed: () async {
            if (await _showDeleteImageConfirmation()) {
              _screenshots.remove(selectedImage);
              _selectedScreenshots.remove(selectedImage);
              Navigator.of(context).pop();
            }
          },
        );

        return Scaffold(
          body: Container(
            constraints: BoxConstraints.expand(
              height: MediaQuery.of(context).size.height,
            ),
            child: Stack(
              alignment: Alignment.bottomRight,
              children: <Widget>[
                PhotoViewGallery(
                  pageOptions: pages,
                  pageController: PageController(initialPage: _screenshots.indexOf(selectedImage)),
                ),
                Container(
                  color: Colors.black45,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      backButton,
                      deleteButton,
                    ],
                  )
                )
              ],
            )
          ),
        );
      },
      fullscreenDialog: true,
    ));
  }

  void _onImageSelected(File image) {
    if (_selectedScreenshots.isEmpty) {
      _showImageGallery(image);
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

        return ImageTile(
          child: child,
          image: image,
          onTap: () => setState(() { _onImageSelected(image); }),
          onLongPress: () {
            setState(() { 
                if (_selectedScreenshots.contains(image)) {
                  _selectedScreenshots.remove(image);
                } else {
                  _selectedScreenshots.add(image);
                }
            });
          },
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, FirebaseUser currentUser) {
    return StreamBuilder<DocumentSnapshot>(
      stream: Firestore.instance.collection("Users").document(currentUser.uid).snapshots(),
      builder: (context, snapshot) {
        if(!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        final snap = snapshot.data;

        final titleWidget = Text(
          "Submit Challenge Entry",
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        );

        final repoWidget = _buildReposDropdown(snap);

        final appNameWidget = TextFormField(
          validator: (input) => input.isEmpty ? 'This field is required' : null,
          onSaved: (input) => _appNameController.text = input,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: "App Name",
            prefixIcon: Icon(OMIcons.shortText)
          ),
          controller: _appNameController,
        );

        final descriptionWidget = TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Submission Description",
            prefixIcon: Icon(OMIcons.textsms)
          ),
          maxLines: 2,
          controller: _submissionDescriptionController,
        );

        final dividerWidget = Divider(
          color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
        );

        final imageHeaderWidget = ListTile(
          title: _selectedScreenshots.isNotEmpty
            ? Text("Selecting Screenshots (${_selectedScreenshots.length} of ${_screenshots.length})")
            : Text("Upload Screenshots"),
          trailing: _selectedScreenshots.isNotEmpty
          ? IconButton(
            icon: Icon(Icons.delete, color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white),
            onPressed: () => _deleteSelectedImages(),
          )
          : IconButton(
            icon: Icon(OMIcons.addPhotoAlternate, color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white),
            onPressed: _screenshots.length > 5 ? null : () => getImage(),
          ),
        );

        return SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Form(
              key: formKey,
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 16),

                  titleWidget,

                  const SizedBox(height: 28),

                  repoWidget,

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: <Widget>[
                        const SizedBox(height: 32),

                        appNameWidget,

                        const SizedBox(height: 32),

                        descriptionWidget,

                        const SizedBox(height: 24),

                        dividerWidget,

                        const SizedBox(height: 8),

                        imageHeaderWidget,
                      ],
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
  }

  Widget _buildBottomNavigationBar() {
    return BottomAppBar(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return CurrentUserBuilder(
      builder: (context, currentUser) {
        final fab = FloatingActionButton.extended(
          icon: Icon(Icons.cloud_upload),
          label: Text("Submit"),
          onPressed: () => _submitEntry(currentUser),
        );

        final body = SafeArea(
          child: _buildBody(context, currentUser),
        );

        return Scaffold(
          resizeToAvoidBottomPadding: false,
          key: _scaffoldKey,
          body: body,
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          floatingActionButton: fab,
          bottomNavigationBar: _buildBottomNavigationBar()
        );
      },
    );
  }
}