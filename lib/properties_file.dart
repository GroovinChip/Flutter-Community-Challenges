import 'package:meta/meta.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:yaml/yaml.dart';

class GithubProperties {
  final String clientID;
  final String clientSecret;
  final String redirectURL;

  GithubProperties({
    @required this.clientID,
    @required this.clientSecret,
    @required this.redirectURL
  });

  factory GithubProperties.fromYaml(YamlMap data) {
    return new GithubProperties(
      clientID: data['client-id'],
      clientSecret: data['client-secret'],
      redirectURL: data['redirect-url']
    );
  }
}

class Properties {
  final GithubProperties github;

  Properties({
    @required this.github,
  });

  factory Properties.fromYaml(YamlMap data) {
    return new Properties(
      github: GithubProperties.fromYaml(data['github']),
    );
  }
}

class PropertiesFile {
  Future<String> _loadFileAsString() async {
    return await rootBundle.loadString('properties/properties.yaml');
  }

  Future<Properties> load() async {
    final data = await _loadFileAsString();
    final doc = loadYaml(data);
    
    return Properties.fromYaml(doc);
  }
}