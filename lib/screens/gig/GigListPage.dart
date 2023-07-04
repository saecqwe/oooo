import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kappu/common/validation_dialogbox.dart';
import 'package:kappu/components/MyAppBar.dart';
import 'package:kappu/constants/storage_manager.dart';
import 'package:kappu/models/serializable_model/GigListResponse.dart';
import 'package:kappu/net/http_client.dart';
import 'package:kappu/screens/gig/GigItemWidget.dart';
import 'package:kappu/screens/register/register_more.dart';

import '../../net/base_dio.dart';

class GigListPage extends StatefulWidget {
  const GigListPage({Key? key}) : super(key: key);

  @override
  State<GigListPage> createState() => GigListPageState();
}

class GigListPageState extends State<GigListPage> {
  reloadpage() {
    setState(() {});
  }

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: "GIGs List"),
      body:  FutureBuilder(
          future: HttpClient().getGigList(),
          builder: (context,
              AsyncSnapshot<List<GigListResponse>> snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.data == null || snapshot.data!.isEmpty) {
              return Center(child: Padding(
                padding: EdgeInsets.only(top: 20.h),
                child: Column(
                  children: [
                    const Text("No Gig Found", style: TextStyle(color: Colors.black, fontFamily: "Montserrat-Regular")),
                    TextButton(
                        onPressed: () {
                          setState(() {});
                        },
                        child: const Text('Reload')),
                  ],
                ),
              ),);
            }
            return ListView(
              padding: const EdgeInsets.only(bottom: 50),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              children: snapshot.data!
                  .map((item) => Padding(
                padding: EdgeInsets.all(
                    ScreenUtil().setHeight(10)),
                child: GigItemWidget(
                  item: item,
                  menuItemClicked: (String value) {
                    callAPI(context, item, value);
                  },
                ),
              ))
                  .toList(),
            );
          }),
    );
  }

  Future<void> callAPI(BuildContext context, GigListResponse item, String value) async {
    // setState(() {
    //   isLoading = true;
    // });
    if (value == 'edit')  {
      Map<String, dynamic> map = {};
      final result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => RegisterMore(bodyprovider: map, isFromEditGig : true, myGig: item)));

      if(result == "1"){
        setState(() {
        });
      }
    }
    else if (value == 'delete') {
     deleteGig(item);
    }
  }

  deleteGig(item) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return WarningDialogBox(title: "Delete?",descriptions: "Are You sure You want to Delete?",buttonTitle: "ok",
            onPressed: () async{
              Navigator.pop(context);
              await HttpClient()
                  .deleteGig(item.id.toString(), "Bearer "+StorageManager().accessToken)
                  .then((value) {
                if (value.status) {
                  setState(() {
                    isLoading = false;
                  });
                  reloadpage();
                }
              }).catchError((e) {
                setState(() {
                  isLoading = false;
                });
                BaseDio.getDioError(e);
              });
            },icon: Icons.cancel,);
        });
  }
}
