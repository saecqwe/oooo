import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kappu/common/custom_progress_bar.dart';
import 'package:kappu/common/dialogues.dart';
import 'package:kappu/common/validation_dialogbox.dart';
import 'package:kappu/components/AppColors.dart';
import 'package:kappu/constants/storage_manager.dart';
import 'package:kappu/models/serializable_model/GigListResponse.dart';
import 'package:kappu/net/base_dio.dart';
import 'package:kappu/provider/provider_provider.dart';
import 'package:kappu/screens/submitdocument/add_photo.dart';
import 'package:provider/provider.dart';
import '../../common/bottom_nav_bar.dart';
import '../../net/http_client.dart';
import '../../common/CircleButton.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class AddGig extends StatefulWidget {
  final Map<String, dynamic> bodyprovider;
  bool? isFromAddGig = false;
  // final File doc;
  // final File licence;
  bool? isFromEditGig = false;
  GigListResponse? myGig;


  AddGig(
      {Key? key,
      required this.bodyprovider,
        this.isFromAddGig,
        this.isFromEditGig,
        this.myGig
      // ,required this.doc,
      // required this.licence
      })
      : super(key: key);

  @override
  State<AddGig> createState() => _AddGigState();
}

class _AddGigState extends State<AddGig> {
  bool isUploading = false;
  bool isLoading = false;
  double progress = 0;
  List<File> images = [];

  @override
  void initState() {
    super.initState();
    if(widget.isFromEditGig??false){
      setState(() {
        isLoading = true;
      });
      for( var i=0; i< widget.myGig!.servicepackages!.gigdocument!.length; i++) {
        getFileFromUrl(widget.myGig!.servicepackages!.gigdocument![i]);
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  Future getImage(ImageSource imageSource, context, bool isVideo) async {
    XFile? image;
    image = await ImagePicker().pickImage(source: imageSource);
    ImageCropper imageCropper = ImageCropper();
    if (image != null && !isVideo) {
      File? croppedFile = await imageCropper.cropImage(
          sourcePath: image.path,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2
          ],
          androidUiSettings: const AndroidUiSettings(
              toolbarTitle: 'Crop',
              toolbarColor: AppColors.app_color,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: true),
          iosUiSettings: const IOSUiSettings(
            minimumAspectRatio: 1,
          ));
      if (croppedFile != null) {
        setState(() {
          images.add(croppedFile);
        });
      }
    }
    Navigator.pop(context);
  }

  Future source(BuildContext mContext, bool isVideo) async {
    return showDialog(
        context: mContext,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
              title: const Text("Choose Option"),
              content: const Text(
                'Select Source',
              ),
              insetAnimationCurve: Curves.decelerate,
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: GestureDetector(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const <Widget>[
                        Icon(
                          Icons.photo_camera,
                          size: 28,
                        ),
                        Text(
                          "Camera",
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                              decoration: TextDecoration.none),
                        ),
                      ],
                    ),
                    onTap: () {
                      //   Navigator.pop(context);
                      showDialog(
                          context: context,
                          builder: (context) {
                            getImage(ImageSource.camera, context, isVideo);
                            return const Center(
                                child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ));
                          });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: GestureDetector(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const <Widget>[
                        Icon(
                          Icons.photo_library,
                          size: 28,
                        ),
                        Text(
                          "Gallery",
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                              decoration: TextDecoration.none),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) {
                            getImage(ImageSource.gallery, context, isVideo);
                            return const Center(
                                child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ));
                          });
                    },
                  ),
                ),
              ]);
        });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                  padding: const EdgeInsets.fromLTRB(15, 30, 15, 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: ScreenUtil().setHeight(40)),
                      Center(
                        child: Image.asset(
                          "assets/icons/logo-no_shadow.png",
                          height: 80.h,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: ScreenUtil().setHeight(10)),
                      Center(
                        child: Text(
                          "Add GIG Profile",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: ScreenUtil().setSp(24), fontFamily: "Montserrat-Bold"),
                        ),
                      ),
                      15.verticalSpace,
                      Text(
                        "Upload Multiple Images",
                        style: TextStyle(
                            color: AppColors.text_desc,
                            fontSize: ScreenUtil().setSp(14),
                            fontFamily: 'Montserrat-Medium'),
                      ),
                      10.verticalSpace,
                      AddPhotoWidget(
                        isUploading: false,
                        onTap: () async {
                          await source(context, false);
                        },
                        icon: Icons.upload,
                        progress: progress,
                        isImage: false,
                        onTapCancel: () {
                          setState(() {
                            // uploadTask.cancel();
                            isUploading = false;
                          });
                        },
                      ),
                      20.verticalSpace,
                      images != null && images.length > 0
                          ? Container(
                        height: 100,
                        child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: images.length,
                            itemBuilder: (_, index) {
                              return Container(
                                  margin: EdgeInsets.only(left: 5),
                                  width: 100,
                                  height: 100,
                                  child: AddPhotoWidget(
                                    isUploading: isUploading,
                                    filePath: images[index],
                                    onTap: () {
                                      source(context, false);
                                    },
                                    icon: Icons.upload,
                                    progress: progress,
                                    isImage: false,
                                    onTapCancel: () {
                                      print('aaaa');
                                      setState(() {
                                        images.removeAt(index);
                                      });
                                    },
                                  ));
                            }),
                      )
                          : SizedBox(),
                      20.verticalSpace,
                      SizedBox(
                        height: ScreenUtil().screenHeight * 0.07,
                        child: TextButton(
                          style: ButtonStyle(
                            backgroundColor:
                            MaterialStateProperty.all(AppColors.app_color),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      ScreenUtil().screenHeight * 0.035)),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Opacity(
                                opacity: 0,
                                child: Icon(Icons.arrow_forward_ios),
                              ),
                              Text(
                                "Submit",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                  fontSize: 14.sp,
                                  fontFamily: 'Montserrat-Medium',
                                ),
                              ),
                              Image.asset('assets/icons/arw.png', scale: 1.0),
                            ],
                          ),
                          onPressed: () {
                            doRegister();
                          },
                        ),
                      ),
                    ],
                  )),
            ],
          ),
          if(isLoading)
            CustomProgressBar()
        ],)
      ),
    );
  }

  void doRegister() async {
    if(images.isEmpty){
      showAlertDialog(
          error: "Please add gig image",
          errorType: "Alert");
    }else{
      setState(() {
        isLoading = true;
      });
      if(widget.isFromAddGig??false){
        await HttpClient()
            .addGig(
            widget.bodyprovider, images)
            .then((value) {
          setState(() {
            isLoading = false;
          });
          if (value?.data['status']) {
            showSuccessDialog("Gig added successfully");
          }
          }).catchError((e) {
          setState(() {
            isLoading = false;
          });
          print(e);
          BaseDio.getDioError(e);
        });
      }
      if(widget.isFromEditGig??false){
        await HttpClient()
            .editGig(
            widget.bodyprovider, images, widget.myGig!.id!)
            .then((value) {
          setState(() {
            isLoading = false;
          });
          if (value?.data['status']) {
            showSuccessDialog("Gig updated successfully");
          }
          }).catchError((e) {
          setState(() {
            isLoading = false;
          });
          print('its coming from gig edit page'
              '');
          BaseDio.getDioError(e);
          // if (e.response != null && e.response.data['errors'].length > 0) {
          //   showAlertDialog(
          //       error: "Please check your email address",
          //       errorType: "Alert");
          // }
        });
      }
      else {
        await HttpClient()
            .providersignup(
            widget.bodyprovider, images)
            .then((value) {
          setState(() {
            isLoading = false;
          });
          if (value?.data['status']) {
            var provider = StorageManager();
            provider.accessToken = value?.data['token'];
            provider.userId = value?.data['user']['id'];
            provider.name = widget.bodyprovider['first_name'];
            provider.phone = widget.bodyprovider['phone_number'];
            provider.email = widget.bodyprovider['email'];
            provider.isProvider = true;
          //  provider.isSocialUser = !widget.bodyprovider['social_login_id'].isEmpty();
            provider.nationality = widget.bodyprovider['nationality'];
            provider.language = value?.data['user']['languages'];

            while(Navigator.canPop(context)){
              Navigator.pop(context);
            }
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const BottomNavBar(isprovider: true)));
            // provider.stripeId =
            //     "" + value?.data['user']['customer_stripe_id'];
          }
          });
      }
    }


  }

  getFileFromUrl(Gigdocument item) {
    String url = "https://urbanmalta.com/public/users/user_${item.userid}/documents/${item.fileName}";
    var rng = new Random();
    var tempDir;
    getTemporaryDirectory().then((value) {
      tempDir = value;
      String tempPath = tempDir.path;
      File file = new File('$tempPath'+ (rng.nextInt(100)).toString() +'.png');
      http.get(Uri.parse(url)).then((value){
        file.writeAsBytes(value.bodyBytes);
        setState(() {
            images.add(file);
        });
      });
      });
  }

  showSuccessDialog(desc) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return WarningDialogBox(title: "Success",descriptions: desc,buttonTitle: "ok",
            onPressed: () {
              Navigator.pop(context, "1");
              Navigator.pop(context, "1");
            },
            buttonColor: AppColors.color_green,
            icon: Icons.check);
        });
  }

}
