import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kappu/common/validation_dialogbox.dart';
import 'package:kappu/components/AppColors.dart';
import 'package:kappu/components/ProviderItem.dart';
import 'package:kappu/constants/storage_manager.dart';
import 'package:kappu/models/serializable_model/AddOrderResponse.dart';
import 'package:kappu/net/base_dio.dart';
import 'package:kappu/net/http_client.dart';

import '../../common/save_dialogbox.dart';
import '../../components/MyAppBar.dart';

class ProviderProfileScreen extends StatefulWidget {
  @override
  _ProviderProfileScreenState createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen> {
  @override
  void initState() {
    super.initState();
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
        HttpClient().UpdateUserProfilePic(croppedFile).then((value) => {
          // setState(() {
          //   this.loading = false;
          // }),
          print(value),
          if (value!.data['status'])
            {
              StorageManager().userImage = value!.data['profile_name'],
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(''+value!.data['message'])),
            ),
              setState(() {
              })
            }
        })
            .catchError((e) {
          // setState(() {
          //   this.loading = true;
          // });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error : $e')),
          );
          BaseDio.getDioError(e);
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
        appBar: MyAppBar(title: "Profile detail"),
        backgroundColor: Colors.white,
        body: Container(
          color: Colors.grey.withOpacity(0.1),
          child: Column(
            children: [
              const Divider(
                height: 0.5,
                color: Colors.grey,
              ),
              Container(
                  padding: const EdgeInsets.only(left: 20,right: 20,top: 32,bottom: 32),
                  width: double.infinity,
                  color: Colors.white,
                  child: Row(
                    children: [
                      InkWell(
                        child: CircleAvatar(
                            radius: 40,
                            backgroundImage: StorageManager().userImage.length>0 ?
                            NetworkImage("https://urbanmalta.com/public/users/user_${StorageManager().userId}/profile/${StorageManager().userImage}")
                                : NetworkImage(
                                'https://urbanmalta.com/public/frontend/images/johnwing.png')
                        ),
                        onTap: () async {
                          await source(context, false);
                        },
                      ),
                      SizedBox(width: 15,),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: (){
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return SaveDialogBox(
                                      buttonTitle:'Save',
                                      buttonColor: AppColors.app_color,
                                      onPressed: (name) {
                                        HttpClient().updateName(name).then((value) {
                                          print(value);
                                          StorageManager().name = name;
                                          setState(() {

                                          });
                                        })
                                            .catchError((e) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Error : $e')),
                                          );
                                          BaseDio.getDioError(e);
                                        });
                                        Navigator.pop(context);
                                      },
                                    );
                                  });
                            },
                              child:Text(
                            StorageManager().name,
                            maxLines: 3,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 24,
                                fontWeight: FontWeight.bold),
                          )),
                          SizedBox(height: 5,),
                          Text(
                            StorageManager().email,
                            maxLines: 3,
                            style: TextStyle(
                                color: AppColors.color_7B7D83,
                                fontSize: 16,
                                fontWeight: FontWeight.normal),
                          ),
                        ],
                      ))
                    ],
                  )
              ),
              Expanded(
                  child: ListView(
                padding: EdgeInsets.all(20),
                shrinkWrap: true,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)
                    ),
                    padding: const EdgeInsets.only(left: 20,right: 20,top: 10,bottom: 10),
                    child: Row(
                      children: [
                        Image.asset('assets/icons/prf.png',
                            scale: 1.0),
                        SizedBox(width: 20,),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                            'Name',
                              maxLines: 3,
                              style: TextStyle(
                                  color: AppColors.color_7B7D83,
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal),
                            ),
                            SizedBox(height: 5,),

                            Text(
                              StorageManager().name,
                              maxLines: 3,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal),
                            ),
                          ],
                        ))
                      ],
                    ),
                  ),
                  SizedBox(height: 20,),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)
                    ),
                    padding: const EdgeInsets.only(left: 20,right: 20,top: 10,bottom: 10),
                    child: Row(
                      children: [
                        Image.asset('assets/icons/email.png',
                            scale: 1.0),
                        SizedBox(width: 20,),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "email",
                              maxLines: 3,
                              style: TextStyle(
                                  color: AppColors.color_7B7D83,
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal),
                            ),
                            SizedBox(height: 5,),
                            Text(
                              StorageManager().email,
                              maxLines: 3,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal),
                            ),
                          ],
                        ))
                      ],
                    ),
                  ),
                  SizedBox(height: 20,),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)
                    ),
                    padding: const EdgeInsets.only(left: 20,right: 20,top: 10,bottom: 10),
                    child: Row(
                      children: [
                        Image.asset('assets/icons/call.png',
                            scale: 1.0),
                        SizedBox(width: 20,),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:  [
                            Text(
                              "Phone Number",
                              maxLines: 3,
                              style: TextStyle(
                                  color: AppColors.color_7B7D83,
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal),
                            ),
                            SizedBox(height: 5,),
                            Text(
                              StorageManager().phone.toString(),
                              maxLines: 3,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal),
                            ),
                          ],
                        ))
                      ],
                    ),
                  ),
                ],
              ))
            ],
          ),
        ));
  }
}