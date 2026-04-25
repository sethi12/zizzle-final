import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../model/reel.dart';

class SearchVideoController extends GetxController {
  String? selectedvideoid;
  SearchVideoController({required this.selectedvideoid});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<Video> _videolt = RxList<Video>();
  List<Video> get videolt => _videolt;
  bool _videosLoaded = false;

  Stream<List<Video>> get videoListStream =>
      _firestore.collection("reels").snapshots().map((QuerySnapshot query) {
        List<Video> retval = [];
        int selectedIndex = -1;

        for (var element in query.docs) {
          final data = element.data() as Map<String, dynamic>;

          final isGlobal = data['isGlobalOptionEnabled'] == true;
          final isPaidGlobal = data['GlobalPaymentActivation'] == true;

          if (isGlobal || isPaidGlobal) {
            Video video = Video.fromSnap(element);
            retval.add(video);
          }
        }

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
  }

  void updateData({required String newvideoid}) {
    print("Updating selectedVideoId to: $newvideoid");
    this.selectedvideoid = newvideoid;
    _videolt.clear();
    _videolt.bindStream(videoListStream);
  }

  Future<void> preloadVideos() async {
    for (var video in videolt) {
      await video.initializeController();
      print('Video ${video.videourl} is loaded.');
      print(video);
    }
    _videosLoaded = true;
    print('All videos are loaded.');
  }
}
