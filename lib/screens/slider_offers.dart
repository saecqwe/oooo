import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../net/http_client.dart';
import '../components/AppColors.dart';
import '../components/ProviderItem.dart';
import '../components/MyAppBar.dart';
import '../models/serializable_model/RecommendedServiceProvidersResponse.dart';

class ProviderOffersFromHomePage extends ModalRoute<void> {
  final int serviceid;
  final String name;
  final String desc;


  ProviderOffersFromHomePage({required this.serviceid, required this.name, required this.desc});

  @override
  Duration get transitionDuration => const Duration(milliseconds: 500);

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  Color get barrierColor => Colors.black.withOpacity(0.5);

  @override
  String get barrierLabel => "";

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,) {
    // This makes sure that text and other content follows the material style
    return Material(
      type: MaterialType.transparency,
      child: _buildOverlayContent(context),
    );
  }




  Widget _buildOverlayContent(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.app_bg,
        appBar: MyAppBar(title: 'Service Provide List'),
        body: SingleChildScrollView(
          physics: ScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                color: Colors.white,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(30, 20, 30, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(this.name,
                          style: TextStyle(
                              fontSize: 20.sp,
                              color: Colors.black,
                              fontFamily: "Montserrat-bold")),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        this.desc,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.title_desc,
                            fontFamily: "Montserrat-regular"),
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(10,25,5,10),
                child: Text(
                  "Recommended for you",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.sp,
                      fontFamily: "Montserrat-bold"
                  ),
                ),
              ),
              Padding(
                  padding: EdgeInsets.all(10),
                  child: FutureBuilder(
                      future: HttpClient().getRecommendedServiceProviders("${this.serviceid}"),
                      builder: (context,
                          AsyncSnapshot<List<RecommendedServiceProvidersResponse>> response) {
                        if (response.connectionState != ConnectionState.done) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return ListView.separated(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: response.data!.length,
                          itemBuilder: (context, position) {

                            return ItemServicesCard(data : response.data![position]);
                          }
                          ,
                          separatorBuilder: (context, index) =>
                              SizedBox(
                                height: 10,
                              )
                          ,
                        );

                      })
              ),
            ],
          ),
        )
    );
  }
}
