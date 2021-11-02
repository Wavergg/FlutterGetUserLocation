import 'package:http/http.dart' as http;

class APILocationData {
  final int userID;
  final double latitude;
  final double longitude;
  final String description;

  APILocationData(this.userID, this.latitude, this.longitude, this.description);

  //get url http://developer.kensnz.com/api/addlocdata?userid=3&latitude=-46.413490&longitude=168.355515&description=test123
  //a get method to send information into the URI above
  Future<http.Response> getLocations() async {
    String _kenUrl =
        "http://developer.kensnz.com/api/addlocdata?userid=$userID&latitude=$latitude&longitude=$longitude&description=$description";

    print('$_kenUrl');

    http.Response response = await http.get(_kenUrl);

    return response;
  }
}
