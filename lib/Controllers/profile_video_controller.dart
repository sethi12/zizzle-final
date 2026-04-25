import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../model/reel.dart';

class ProfileVideoController extends GetxController {
 String ?selecteduid;
 String ? selectedvideoid;
  ProfileVideoController({required this.selecteduid,required this.selectedvideoid});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<Video> _videolt = RxList<Video>();
  List<Video> get videolt => _videolt;
 bool _videosLoaded = false;
 Stream<List<Video>> get videoListStream => _firestore
     .collection("reels")
     .where('uid', isEqualTo: selecteduid)
     .snapshots()
     .map((QuerySnapshot query) {
   List<Video> retval = [];
   int selectedIndex = -1;

   for (var element in query.docs) {
     Video video = Video.fromSnap(element);
     retval.add(video);

     // Check if the video is the selected one
     if (video.id == selectedvideoid) {
       selectedIndex = retval.indexOf(video);
     }
   }

   // Sort the list, putting the selected video at the beginning
   retval.sort((a, b) {
     if (a.id == selectedvideoid) {
       return -1; // Selected video comes first
     } else if (b.id == selectedvideoid) {
       return 1;
     } else {
       return 0;
     }
   });

   return retval;
 });


  @override
  void onInit() {
    super.onInit();
    _videolt.bindStream(videoListStream);
    _videolt.clear();
    print(selecteduid);
  }

  void updateData({required String newid,required String newvideoid}) {
    print("Updating selectedid to: $newid");
    print("Updating selectedVideoId to: $newvideoid");
    this.selecteduid = newid;
    this.selectedvideoid =newvideoid;
    _videolt.clear();
    _videolt.bindStream(videoListStream);
  //   print(selecteduid);
  //   print(newid);
  //   print(newvideoid);
   }
 Future<void> preloadVideos() async {
   for (var video in videolt) {
     await video.initializeController();
     print('Video ${video.videourl} is loaded.');
     print(video);
   }
   _videosLoaded = true;
   print('All videos are loaded.'); // Add this line
 }
}
