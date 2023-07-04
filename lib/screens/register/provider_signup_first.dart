import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kappu/components/AppColors.dart';
import 'package:kappu/components/MyAppBar.dart';
import 'package:kappu/helperfunctions/screen_nav.dart';
import 'package:kappu/screens/register/social_signup.dart';
import 'register.dart';

class ProviderSignupFirstScreen extends StatelessWidget {
  const ProviderSignupFirstScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: "Service Provider Signup"),
      body: Container(
        color: Colors.white,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 30, 15, 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Work your way",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      fontFamily: 'Montserrat-Bold',
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "You bring the skill. We’ll make earning easy",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Montserrat-Regular',
                        color: Color(0xFF9A9A9A)),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Flexible(flex:1,child:SizedBox(height:120,child:Card(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: const [
                              Text(
                                "Gig is Bought\nEvery",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Color(0xFF7B7D83), fontSize: 10, fontFamily: "Montserrat-Regular"),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "5 Sec",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.app_color,
                                  fontSize: 16,
                                  fontFamily: 'Montserrat-Bold',
                                ),
                              )
                            ],
                          ),
                        ),
                      ))),
                      Flexible(flex:1,child:SizedBox(height:120,child:Card(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: const [
                              Text(
                                "Project Completed\n",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Color(0xFF7B7D83), fontSize: 10, fontFamily: "Montserrat-Regular"),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "50 M+",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.app_color,
                                  fontSize: 16,
                                  fontFamily: 'Montserrat-Bold',
                                ),
                              )
                            ],
                          ),
                        ),
                      ))),
                      Flexible(flex:1,child:SizedBox(height:120,child:Card(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: const [
                              Text(
                                "Price Range\n",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Color(0xFF7B7D83), fontSize: 10, fontFamily: "Montserrat-Regular"),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              FittedBox(
                                fit: BoxFit.contain,
                                child: Text(
                                  '\u{20AC}${5}-\u{20AC}${10}',
                                  textAlign: TextAlign.justify,
                                  style: TextStyle(
                                    color: AppColors.app_color,
                                    fontSize: 16,
                                    fontFamily: 'Montserrat-Bold',
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ))),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Image.asset(
                        "assets/icons/create-gig-icon.png",
                        height: ScreenUtil().setHeight(50),
                        width: ScreenUtil().setHeight(50),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Container(
                        color: const Color(0xFFEBEBEB),
                        width: 1,
                        height: 50,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Create a Gig",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                              fontFamily: 'Montserrat-Bold',
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "Offer Your services to a global audience \nand start earning more.",
                            style: TextStyle(
                                fontSize: 12,
                                overflow: TextOverflow.clip,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Montserrat-Regular',
                                color: Color(0xFF9A9A9A)),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                        ],
                      )
                    ],
                  ),
                  Container(
                    color: const Color(0xFFEBEBEB),
                    height: 1,
                    margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  ),
                  Row(
                    children: [
                      Image.asset(
                        "assets/icons/deliver-icon.png",
                        height: ScreenUtil().setHeight(50),
                        width: ScreenUtil().setHeight(50),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Container(
                        color: const Color(0xFFEBEBEB),
                        width: 1,
                        height: 50,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Deliver your work",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                              fontFamily: 'Montserrat-Bold',
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "Used our buit-in-tools to communicate with \nyour customers and deliver their order.",
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Montserrat-Regular',
                                color: Color(0xFF9A9A9A)),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                        ],
                      )
                    ],
                  ),
                  Container(
                    color: const Color(0xFFEBEBEB),
                    height: 1,
                    margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  ),
                  Row(
                    children: [
                      Image.asset(
                        "assets/icons/get-paid.png",
                        height: ScreenUtil().setHeight(50),
                        width: ScreenUtil().setHeight(50),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Container(
                        color: const Color(0xFFEBEBEB),
                        width: 1,
                        height: 50,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Get paid",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                              fontFamily: 'Montserrat-Bold',
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "Receive your payment once the order is \ncomplete. It’s that simple.",
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Montserrat-Regular',
                                color: Color(0xFF9A9A9A)),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                        ],
                      )
                    ],
                  ),
                  Container(
                    color: const Color(0xFFEBEBEB),
                    height: 1,
                    margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  ),
                ],
              ),
            ),
            Spacer(),
            Container(
              height: ScreenUtil().screenHeight * 0.05,
              margin: EdgeInsets.all(15),
              child: TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(AppColors.app_color),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            ScreenUtil().screenHeight * 0.025)),
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
                      "Continue",
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
                  changeScreen(
                      context: context,
                      screen: SocailSignUpScreen(isprovider: true));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
