import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kappu/components/AppColors.dart';
import 'package:kappu/models/serializable_model/RecommendedServiceProvidersResponse.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/ProviderScreens/provider_detail.dart';

class ItemServicesCard extends StatefulWidget {
  RecommendedServiceProvidersResponse data;

  ItemServicesCard({required this.data});

  // final CartItem item;
  // final VoidCallback onAddClick;
  // final VoidCallback onMinusClick;
  //
  // ItemCartCard({required this.item,required this.onAddClick,required this.onMinusClick});

  @override
  State<StatefulWidget> createState() {
    return ItemServicesCardState();
  }
}

class ItemServicesCardState extends State<ItemServicesCard> {
  @override
  Widget build(BuildContext context) {

    return GestureDetector(
        onTap: ()async{
          SharedPreferences prefs=await SharedPreferences.getInstance();
         String? addres= prefs.getString('currentLocation');

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                  ProviderDetailScreen(id: widget.data.id!,location: addres)));

        },
        child: Container(
          // clipBehavior: Clip.antiAlias,
      child: DecoratedBox(

        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(6)),
            color: Colors.white),
        child: Row(
          children: [
            Container(
              clipBehavior: Clip.antiAlias,
              child: getImage(widget.data!),
              decoration: new BoxDecoration(
                color: Colors.white,
                borderRadius: new BorderRadius.only(topLeft: new Radius.circular(6), bottomLeft: new Radius.circular(6)),
              ),
            ),
            Expanded(child: Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text(
                  //   this.widget.data.title!,
                  //   textAlign: TextAlign.start,
                  //   style: TextStyle(
                  //       color: AppColors.app_color,
                  //       fontSize: 16.sp,
                  //       fontFamily: "Montserrat-bold"),
                  // ),
                  5.verticalSpace,
                  Container(
                    width: 200,
                    child: Text(
                      // "ugfiuegfiue efgeigifiuef eifgegfeiugfef eifge8gfe ihgeoirghor",
                       this.widget.data.description==null ? "" : this.widget.data.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: TextStyle(
                          color: AppColors.text_desc, fontSize: 12.sp,
                          fontFamily: "Montserrat-regular"
                      ),
                    ),
                  ),
                  10.verticalSpace,
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 12.0,
                        color: AppColors.app_yellow,
                      ),
                      Text(
                        ' ${this.widget.data.rating}',
                        style: TextStyle(fontSize: 12.sp, color: AppColors.app_yellow, fontFamily: "Montserrat-bold"),
                      ),Text(
                        ' (0 Rating)',
                        style: TextStyle(fontSize: 10.sp, color: AppColors.text_desc,
                            fontFamily: "Montserrat-regular"
                        ),
                      ),
                    ],
                  ),
                  // Text(
                  //   'Including 2 Packages',
                  //   textAlign: TextAlign.start,
                  //   style: TextStyle(color: Colors.black, fontSize: 10.sp),
                  // ),
                  10.verticalSpace,
                  Container(
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Hourly Price  :  ',
                          style:
                              TextStyle(color: Colors.black, fontSize: 10.sp,
                                  fontFamily: "Montserrat-bold"
                              ),

                        ),
                        Text(
                          this.widget.data.servicepackages?.price==null ? "\€0" : "\€${this.widget.data.servicepackages?.price}" ,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 12.sp,
                              fontFamily: "Montserrat-bold"
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ))
          ],
        ),
      ),
    ));
  }

  getImage(RecommendedServiceProvidersResponse item) {
    if(item.gigdocument!=null && item.gigdocument!.length>0 ){
      print(item.gigdocument![0].fileName);
      return Image.network("https://urbanmalta.com/public/users/user_${item.gigdocument![0].userid}/documents/${item.gigdocument![0].fileName}",
            height: 120,
            width: 150,
            fit: BoxFit.fill);
    }else{
      return Image.asset('assets/images/barber.jpg',
          height: 120,
          width: 150,
          fit: BoxFit.fill);
    }
  }
}

Card getCard(mChild){

  return Card(child: mChild);

}
