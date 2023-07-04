import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../../components/AppColors.dart';

Widget HomeItem({
  String? title,
  String? imagePath,
  Function()? onTap,
}){
  return InkWell(
    onTap: onTap,
    child: Card(
      elevation: 2,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children:  [
            Image.asset(imagePath!,
                height: 80,
                width: 80,
                fit: BoxFit.cover),

            SizedBox(
              height: 10,
            ),
            Text(
              title!,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.text_desc,
                  fontSize: 12,
                  fontFamily: "Montserrat-Medium"
              ),
            )
          ],
        ),
      ),

    ),
  );
}
