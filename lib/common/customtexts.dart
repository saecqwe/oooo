import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kappu/components/AppColors.dart';

Widget buttontext({required String buttontext}) {
  return Text(
    buttontext,
    style: TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  );
}

Widget customtext(
    {required String buttontext,
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    String fontfailmy = '',
    Color color = Colors.black}) {
  return Text(
    buttontext,
    textAlign: TextAlign.center,
    style: TextStyle(
      fontFamily: fontfailmy,
      fontSize: fontSize.sp,
      fontWeight: fontWeight,
      color: color,
    ),
  );
}

Widget ProfileItem(
    {required String label,
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.normal,
    String fontfailmy = 'Montserrat-Medium',
      Function()? onTap,
      required String iconPath,
    Color color = AppColors.text_desc}) {
  return InkWell(
    onTap: onTap,
    child: Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(10,12,10,12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ImageIcon(AssetImage(iconPath), color: AppColors.app_color,),
              SizedBox(width: 10,),
              Text(label, style: TextStyle(color: AppColors.text_desc, fontSize: 16, fontFamily: "Montserrat-Medium"),),
              Spacer(flex: 1,),
              Icon(
                Icons.keyboard_arrow_right,
                color: AppColors.text_desc,
              ),
            ],
          ),
        ),
        Container(color: AppColors.color_fafafa,height: 1,)
      ],
    ),
  );
}

Widget ProfileItemTitle(
    {required String label,context}) {
  return Container(
    width: MediaQuery.of(context).size.width,
    color: AppColors.color_fafafa,
    child: Padding(
      padding: EdgeInsets.fromLTRB(10,12,10,12),
      child: Text(label, style: TextStyle(color: AppColors.app_color, fontSize: 20, fontFamily: "Montserrat-Bold"),),

    ),
  );
}


