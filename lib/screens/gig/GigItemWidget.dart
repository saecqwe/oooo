import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:kappu/components/AppColors.dart';
import 'package:kappu/constants/storage_manager.dart';
import 'package:kappu/models/serializable_model/GigListResponse.dart';

import '../../../models/serializable_model/OrderListResponse.dart';
import '../../../net/base_dio.dart';
import '../../../net/http_client.dart';

class GigItemWidget extends StatefulWidget {
  final Function(String) menuItemClicked;
  final GigListResponse item;

  const GigItemWidget(
      {Key? key,
        required this.item,
        required this.menuItemClicked})
      : super(key: key);

  @override
  _GigItemWidgetState createState() => _GigItemWidgetState();
}

class _GigItemWidgetState extends State<GigItemWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          },
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          elevation: 3,
          shadowColor: Colors.black.withOpacity(0.14),
          child: Padding(
            padding: EdgeInsets.all(15.h),
            child:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                children: [
                  Container(
                    child: getImage(widget.item),
                    decoration: new BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      new BorderRadius.all(new Radius.circular(10)),
                    ),
                  ),
                  10.horizontalSpace,
                  Container(
                    height: 80,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          widget.item.title??"",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.values[4]),
                        ),
                        Container(
                          width: 200,
                          child: Text(
                            widget.item.description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            style: TextStyle(
                                color: AppColors.text_desc, fontSize: 12.sp),
                          ),
                        ),
                        Text(
                          '\€ ${widget.item.servicepackages?.price}',
                          style: TextStyle(
                              color: AppColors.app_color,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )
                ],
              ),

              SizedBox(height: 6,),

              Container(
                height: 1,
                width: MediaQuery.of(context).size.width,
                color: AppColors.divider,
              ),
              SizedBox(height: 6,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    getDate(this.widget.item.createdAt!),
                    style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        fontFamily: "Montserrat-SemiBold"),
                  ),
                  PopupMenuButton(
                    icon: const Text("...", style: TextStyle(fontSize: 28, color: AppColors.app_black),),
                    itemBuilder: (context) {
                      return [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text(
                            'Edit GIG',
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: AppColors.app_color),
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            'Delete',
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.black),
                          ),
                        ),
                      ];
                    },
                    onSelected: widget.menuItemClicked,
                  )
                ],
              ),

            ]),
          ),
        ));
  }

  String getDate(dateTime) => DateFormat('dd MMM yyyy').format(dateTime);
}

getImage(GigListResponse item) {
  if (item.servicepackages != null && item.servicepackages?.gigdocument != null && item.servicepackages!.gigdocument!.length > 0) {
    return Image.network(
        "https://urbanmalta.com/public/users/user_${item.servicepackages?.gigdocument![0].userid}/documents/${item.servicepackages?.gigdocument![0].fileName}",
        height: 80,
        width: 100,
        fit: BoxFit.fill);
  } else {
    return Image.asset('assets/images/barber.jpg',
        height: 80, width: 100, fit: BoxFit.fill);
  }
}
