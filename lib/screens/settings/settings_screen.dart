
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kappu/common/customtexts.dart';
import 'package:kappu/common/validation_dialogbox.dart';
import 'package:kappu/components/AppColors.dart';
import 'package:kappu/components/MyAppBar.dart';
import 'package:kappu/constants/storage_manager.dart';
import 'package:kappu/net/http_client.dart';
import 'package:kappu/provider/userprovider.dart';
import 'package:kappu/screens/faqs/frequently_asked_questions.dart';
import 'package:kappu/screens/gig/GigListPage.dart';
import 'package:kappu/screens/login/splash_view.dart';
import 'package:kappu/screens/notification/notification_screen.dart';
import 'package:kappu/screens/privacy_policy/privacy_policy.dart';
import 'package:kappu/screens/profilepage/profile_page.dart';
import 'package:kappu/screens/register/register_more.dart';
import 'package:kappu/screens/reset_password/create_new_password.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';

import '../../../helperfunctions/screen_nav.dart';
import '../ProviderScreens/settings/widgets/alert_dialogue.dart';
import '../bookings/booking_screen.dart';
import '../change_password/ChangePasswordPage.dart';
import '../login/login_screen.dart';
import '../provider_reviews/provider_reviews.dart';
import '../register/provider_signup_first.dart';
import 'provider_profile.dart';


class SettingsPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return SettingsPageState();
  }
}

class SettingsPageState extends State<SettingsPage> {

  @override
  Widget build(BuildContext context) {
    return _buildOverlayContent(context);
  }
}

class SettingsRoutePage extends ModalRoute<void> {
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
  Widget buildPage(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      ) {
    // This makes sure that text and other content follows the material style
    return Material(
      type: MaterialType.transparency,
      child: loadLayout(context),
    );
  }

  Widget loadLayout(BuildContext context){
    return _buildOverlayContent(context);
  }
}

Widget _buildOverlayContent(BuildContext context) {
  final provider = StorageManager();
  return Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(centerTitle: true,title: Text('Settings',style: TextStyle(color: Colors.black),),backgroundColor: Colors.white,elevation: 0,leading: SizedBox(),),
    body: SingleChildScrollView(
      child: Consumer<UserProvider>(
        builder: (context, loggedinuser, child) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  CircleAvatar(
                      radius: 40,
                      backgroundImage: StorageManager().userImage.length > 0
                          ? NetworkImage(
                              "https://urbanmalta.com/public/users/user_${StorageManager().userId}/profile/${StorageManager().userImage}")
                          : NetworkImage(
                              'https://urbanmalta.com/public/frontend/images/johnwing.png')),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          provider.name,
                          textAlign: TextAlign.justify,
                          softWrap: true,
                          maxLines: 2,
                          style: TextStyle(
                            fontFamily: "Montserrat-Bold",
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          provider.email,
                          softWrap: true,
                          maxLines: 2,
                          style: TextStyle(
                              fontFamily: "Montserrat-Regular",
                              fontSize: 12,
                              color: AppColors.text_desc),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Padding(
                    padding: EdgeInsets.all(0),
                    child: RawMaterialButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProviderProfileScreen()));
                      },
                      fillColor: AppColors.app_color,
                      child: Icon(
                        Icons.edit,
                        size: 16.0,
                        color: Colors.white,
                      ),
                      shape: CircleBorder(),
                    ),
                  )
                ],
              ),
            ),
            ProfileItemTitle(label: "Account Setting", context: context),
            if(!provider.isSocialUser)
              ProfileItem(
                  label: "Change Password",
                  iconPath: 'assets/icons/loc.png',
                  onTap: () {
                    changeScreen(context: context, screen: ChangePasswordPage());
                  }),
            ProfileItem(
                label: "Logout",
                iconPath: 'assets/icons/exit.png',
                onTap: () {
                  // showAlertDialog(context);
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return WarningDialogBox(
                          title: "Logout?",
                          descriptions: "Are You sure You want to Logout?",
                          buttonTitle: "ok",
                          onPressed: () {
                            Navigator.pop(context);
                            logout(context);
                          },
                          icon: Icons.close,
                        );
                      });
                }),

            ProfileItem(
                label: "Delete Account",
                iconPath: 'assets/icons/exit.png',
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return WarningDialogBox(
                          title: "Delete?",
                          descriptions:
                              "Are You sure You want to Delete this account?",
                          buttonTitle: "ok",
                          onPressed: () {
                            deleteAccount(context);
                          },
                          icon: Icons.close,
                        );
                      });
                }),
            ProfileItemTitle(label: "General", context: context),
            if (provider.isProvider)
              ProfileItem(
                  label: "Add GIG",
                  iconPath: 'assets/icons/addgig.png',
                  onTap: () {
                    Map<String, dynamic> map = {};
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RegisterMore(
                                bodyprovider: map, isFromAddGig: true)));
                  }),
            if (provider.isProvider)
              ProfileItem(
                  label: "GIGs Offered",
                  iconPath: 'assets/icons/savegig.png',
                  onTap: () {
                    changeScreen(context: context, screen: GigListPage());
                  }),
            ProfileItem(
                label: "Faq’s",
                iconPath: 'assets/icons/loc.png',
                onTap: () {
                  changeScreen(
                      context: context, screen: FrequentlyAskedQuestions());
                }),
            ProfileItem(
                label: "Notifications",
                iconPath: 'assets/icons/nt.png',
                onTap: () {
                  changeScreen(context: context, screen: NotificationScreen());
                }),
            ProfileItem(
                label: "Privacy Policy",
                iconPath: 'assets/icons/pl.png',
                onTap: () {
                  changeScreen(context: context, screen: PrivacyPolicyPage());
                }),
            if (provider.isProvider)
              ProfileItem(
                  label: "Services Completed",
                  iconPath: 'assets/icons/chk.png',
                  onTap: () {
                    changeScreen(context: context, screen: BookingScreen());
                  }),
            if (provider.isProvider)
              ProfileItem(
                label: "Total Ratings and Reviews",
                iconPath: 'assets/icons/rv.png',
                onTap: () {
                  changeScreen(
                      context: context,
                      screen: ProviderReviewsPage(
                        providerid: provider.userId,
                        averagerating: provider.rating,
                      ));
                },
              ),
            ProfileItemTitle(label: "Support", context: context),
            ProfileItem(
                label: "Help Center",
                iconPath: 'assets/icons/help.png',
                onTap: () {
                  changeScreen(context: context, screen: HelpCenterQuestions());
                }),
             if(provider.isSocialUser)
            ProfileItem(
                label: "Become a Service Provider",
                iconPath: 'assets/icons/deliver-icon.png',
                onTap: () {
                  // showAlertDialog(context);
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return WarningDialogBox(
                          title: "Switch to Provider Mode",
                          descriptions: "Are You sure You want to Switch to Provider Mode?",
                          buttonTitle: "ok",
                          onPressed: () {
                           // 4263982640269299

                            logout(context);
                            Navigator.push(context, MaterialPageRoute(builder: (context) {
                              return ProviderSignupFirstScreen();
                            },));
                          },
                          icon: Icons.close,
                        );
                      });
                }),
            const SizedBox(height: 80.0),
          ],
        ),
      ),
    ),
  );
}

Future<void> deleteAccount(BuildContext context) async {
  // isLoading = true;

  await HttpClient().deleteAccount().then((loginresponse) {
    // isLoading = false;

    if (loginresponse?.data['status'] == true) {
      logout(context);
    }
  }).catchError((error) {
    // isLoading = false;
    // setState(() {});
  });
}

void logout(BuildContext context) {
  StorageManager().clear();
  Navigator.pushAndRemoveUntil(context,
      MaterialPageRoute(builder: (BuildContext context) {
    return SplashView();
  }), (r) {
    return false;
  });
  Phoenix.rebirth(context);
}
