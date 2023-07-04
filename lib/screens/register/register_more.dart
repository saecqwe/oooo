import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kappu/common/custom_progress_bar.dart';
import 'package:kappu/components/AppColors.dart';
import 'package:kappu/models/serializable_model/CategoryResponse.dart';
import 'package:kappu/models/serializable_model/GigListResponse.dart';
import 'package:kappu/screens/gig/AddGig.dart';
import 'package:kappu/screens/register/widgets/text_field.dart';
import 'package:kappu/screens/submitdocument/submit_doc.dart';
import 'package:http/http.dart' as http;
import '../../common/button.dart';
import '../../common/painter.dart';
import '../../constants/icons.dart';
import '../../constants/storage_manager.dart';
import '../../net/base_dio.dart';
import '../../net/http_client.dart';

class RegisterMore extends StatefulWidget {
  final Map<String, dynamic> bodyprovider;
  bool? isFromAddGig = false;
  bool? isFromEditGig = false;
  GigListResponse? myGig;

  RegisterMore({Key? key, required this.bodyprovider, this.isFromAddGig, this.isFromEditGig, this.myGig}) : super(key: key);

  @override
  _RegisterMoreState createState() => _RegisterMoreState();
}

class _RegisterMoreState extends State<RegisterMore> {
  TextEditingController _descriptionController = TextEditingController();
  String _generatedDescription = '';
  String apiUrl = 'https://api.openai.com/v1/completions';
  String apiKey = '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';
  bool loading = false;
  List<String> addedSkills = [];
  List<String> suggestedSkills = [
    'Flutter',
    'Dart',
    'JavaScript',
    'Python',
    'Java',
    'C++',
    'HTML',
    'CSS',
  ];
  Future<String> generateDescription(String skills,) async {
    Map<String, dynamic> body = {
      "model": "text-davinci-003",
      "prompt": "suggest professional description depending upon my knowledge and skills, ${skills}",
      "max_tokens": 40,
      "temperature": 0
    };
    var response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },

      body: jsonEncode(body),
    );

    print('Printing response: ${response.body}');

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      String generatedText = data['choices'][0]['text'];
      return generatedText;
    } else {
      return 'Failed to generate description.';
    }
  }
  TextEditingController skillController = TextEditingController();
  final _formState = GlobalKey<FormState>();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _extraRateController = TextEditingController();
  bool isValidDesc= true;
  bool isValidTitle= true;

  bool isValidRate= true;
  bool isValidExtraRate= true;
  bool isLoading=false;

  List<Category> catagories = [
    Category(id: -1, name: "Select a Service", createdAt: "",image: "", description: "")
  ];

  Category selectedcatagory =
      Category(id: -1, name: "Select a Service", createdAt: "",image: "", description: "");

  @override
  void initState() {
    super.initState();
    print('bbbb');
    getcatagory();
  }
  void addSkill() {
    String skill = skillController.text.trim();
    if (skill.isNotEmpty && !addedSkills.contains(skill)) {
      setState(() {
        addedSkills.add(skill);
        skillController.clear();
      });
    }
    else if(addedSkills.contains(skill)){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Same Skill already added')));
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please write or choose from suggested skills')));

    }
  }

  getcatagory() async {
    setState(() {
      this.loading = true;
    });
    await HttpClient()
        .getCatagory()
        .then((value) => {
              setState(() {
                this.loading = false;
              }),
              print(value),
              if (value.status)
                {
                  if(widget.isFromEditGig??false){
                    for (var value1 in value.data) {
                        if(widget.myGig!.categoryId==value1.id){
                          setState(() {
                            this.catagories = value.data;
                            this.selectedcatagory = value1;
                            this._descController.text = widget.myGig!.description??"";
                            this._titleController.text = widget.myGig!.title??"";
                            this._rateController.text = widget.myGig!.servicepackages?.price??"";
                            this._extraRateController.text = widget.myGig!.servicepackages?.extraForUrgentNeed??"";
                          })
                        }
                    }
                  }else {
                      setState(() {
                        this.catagories = value.data;
                        this.selectedcatagory = value.data[0];
                      })
                    }
                }
            })
        .catchError((e) {
      setState(() {
        this.loading = true;
      });
      BaseDio.getDioError(e);
    });
  }
@override
  void dispose() {
    // TODO: implement dispose
  _descriptionController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: const BackButton(
          color: AppColors.app_color,
        ),
        shadowColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
                    child: Form(
                      key: _formState,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Image.asset(
                              "assets/icons/logo.png",
                              height: 90.h,
                              fit: BoxFit.cover,
                            ),
                          ),
                          30.verticalSpace,
                          Material(
                            borderRadius: BorderRadius.circular(ScreenUtil().screenHeight * 0.03),
                            elevation: 3,
                            shadowColor: Colors.black.withOpacity(0.14),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: ScreenUtil().setHeight(40),
                                    child: DropdownButtonFormField<Category>(
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        prefixIcon: Padding(
                                          padding: const EdgeInsetsDirectional.only(start: 15, end: 10),
                                          child: ImageIcon(
                                            AssetImage('assets/icons/service.png'),
                                            color: AppColors.app_color,
                                          ),
                                        ),
                                        hintStyle: TextStyle(
                                          color: Colors.grey[100],
                                          fontFamily: "Montserrat-Medium",
                                        ),
                                        labelStyle: TextStyle(
                                          color: AppColors.text_desc,
                                          fontFamily: "Montserrat-Medium",
                                        ),
                                        hintText: "Choose category",
                                        fillColor: Colors.red[100],
                                      ),
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                        fontSize: ScreenUtil().setSp(15),
                                      ),
                                      value: widget.isFromEditGig ?? false ? selectedcatagory : catagories.first,
                                      onChanged: widget.isFromEditGig ?? false
                                          ? null
                                          : (value) {
                                        setState(() {
                                          selectedcatagory = value!;
                                        });
                                      },
                                      selectedItemBuilder: (BuildContext context) {
                                        return catagories.map((Category value) {
                                          return Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              value.name,
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontFamily: "Montserrat-Medium",
                                              ),
                                            ),
                                          );
                                        }).toList();
                                      },
                                      items: catagories
                                          .map(
                                            (value) => DropdownMenuItem<Category>(
                                          value: value,
                                          child: Text(value.name),
                                        ),
                                      )
                                          .toList(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          10.verticalSpace,
                          CustomTextFormField(
                            controller: _titleController,
                            hintText: 'Title',
                            keyboardType: TextInputType.text,
                            prefixIcon: ImageIcon(AssetImage('assets/icons/price.png'), color: AppColors.app_color,),
                            isValid: isValidTitle,
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                isValidTitle = true;
                              } else {
                                isValidTitle = false;
                              }
                              setState(() {});
                            },
                            validator: (value) => value!.isEmpty
                                ? "Enter Title"
                                : null,
                          ),

                          10.verticalSpace,

                          Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Add Tags:', style: TextStyle(fontSize: 16)),
                                SizedBox(height: 8.0),
                                TextFormField(
                                  controller: skillController,
                                  decoration: InputDecoration(
                                    hintText: 'Add your skills',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(Icons.add),
                                      onPressed: addSkill,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16.0),
                                Text('Added Skills:', style: TextStyle(fontSize: 16)),
                                SizedBox(height: 8.0),
                                Wrap(
                                  spacing: 8.0,
                                  runSpacing: 8.0,
                                  children: addedSkills.map((skill) {
                                    return Chip(
                                      shadowColor: Colors.lightBlue,
                                      labelPadding: EdgeInsets.symmetric(horizontal: 10),
                                      deleteIconColor: Colors.blue,
                                      label: Text(skill,style: TextStyle(color: Colors.blue),),
                                      backgroundColor: Colors.blue[50],
                                      deleteIcon: Icon(Icons.close),
                                      onDeleted: () {
                                        setState(() {
                                          addedSkills.remove(skill);
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),
                                SizedBox(height: 16.0),
                                Text('Suggested Skills:', style: TextStyle(fontSize: 16)),
                                SizedBox(height: 8.0),
                                Wrap(
                                  spacing: 8.0,
                                  runSpacing: 8.0,
                                  children: suggestedSkills.map((skill) {
                                    return ActionChip(
                                      avatar: Icon(Icons.add),

                                      label: Text(skill),
                                      onPressed: () {
                                        setState(() {
                                          if (!addedSkills.contains(skill)) {
                                            addedSkills.add(skill);
                                          }
                                          else {
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Same Skill already added')));

                                          }
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),

                              ],
                            ),
                          ),

                          10.verticalSpace,


                          CustomTextFormField(
                            controller: _descController,
                            hintText:
                                'Description | Cover letter – why should user hire you?',
                            suffixIcon: IconButton(
                              icon: isLoading ? SizedBox(height: 20,width: 20,child: CircularProgressIndicator(),) : Icon(Icons.replay_circle_filled),
                              onPressed: () async {

                                String skills = 'i am ${selectedcatagory} and my job title is ${_titleController.text} and my skills are the following : ${addedSkills.toString()}';
                                setState(() {
                                  isLoading=true;
                                });
                                String description = await generateDescription(skills);

                                setState(() {
                                  isLoading=false;
                                  _generatedDescription = description;
                                  _descController.text = _generatedDescription;
                                });
                              },
                              color: Colors.blue,
                            ),
                            keyboardType: TextInputType.text,
                            maxlines: 5,
                            isValid: isValidDesc,
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                isValidDesc = true;
                              } else {
                                isValidDesc = false;
                              }
                              setState(() {});
                            },
                            validator: (value) => value!.isEmpty
                                ? "Enter Your Description"
                                : null,
                          ),
                          10.verticalSpace,
                          CustomTextFormField(
                            controller: _rateController,
                            hintText: '\€ per hour',
                            keyboardType: TextInputType.number,
                            prefixIcon: ImageIcon(AssetImage('assets/icons/price.png'), color: AppColors.app_color,),
                            isValid: isValidRate,
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                isValidRate = true;
                              } else {
                                isValidRate = false;
                              }
                              setState(() {});
                            },
                            validator: (value) => value!.isEmpty
                                ? "Enter \€ per hour"
                                : value!.length > 2
                                    ? "Enter valid \€ per hour"
                                    : null,
                          ),
                          Visibility(
                            visible: false,
                            child: CustomTextFormField(
                              controller: _extraRateController,
                              hintText: 'Extra \€ for urgent need',
                              keyboardType: TextInputType.number,
                              prefixIcon: ImageIcon(AssetImage('assets/icons/price.png'), color: AppColors.app_color,),
                              isValid: isValidExtraRate,
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  isValidExtraRate = true;
                                } else {
                                  isValidExtraRate = false;
                                }
                                setState(() {});
                              },
                              validator: (value) => value!.isEmpty
                                  ? "Enter extra \€"
                                  : value!.length > 2
                                      ? "Enter valid extra \€"
                                      : null,
                            ),
                          ),

                          SizedBox(height: ScreenUtil().setHeight(10)),
                          Container(
                            height: ScreenUtil().screenHeight * 0.06,
                            child: TextButton(
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(AppColors.app_color),
                                shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          ScreenUtil().screenHeight * 0.03)),
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
                              onPressed: onregisterpressedprovider,
                            ),
                          ),
                          10.verticalSpace,

                          // const OrSignUpWith()
                        ],
                      ),
                    ),
                  )
                ],
              ),
              if (loading) CustomProgressBar()
            ],
          ),
        ),
      ),
    );
  }

  onregisterpressedprovider() async {
    print('anc');
    if(_titleController.text.isEmpty ||_descController.text.isEmpty || _rateController.text.isEmpty ){
      return;
    }

    print("aa");

    Map<String, dynamic> bodyprovider1 = (widget.isFromAddGig??false || (widget.isFromEditGig??false)) ? {
      'category': selectedcatagory.id,
      "description": _descController.text,
      "Perhour": _rateController.text,
      "Extra_for_urgent_need": 'not provided',
      "service_title": _titleController.text
    } : {
      'first_name': widget.bodyprovider['first_name'],
      'last_name': widget.bodyprovider['last_name'],
      'username': widget.bodyprovider['username'],
      'email': widget.bodyprovider['email'],
      'category': selectedcatagory.id,
      'phone_number': widget.bodyprovider['phone_number'] ?? '',
      'password': widget.bodyprovider['password'],
      'is_provider': true,
      "Age": widget.bodyprovider['Age'],
      "nationality": widget.bodyprovider['nationality'] ?? '',
      "language": widget.bodyprovider['language'] ?? '',
      "service_title": _titleController.text,
      'login_src':widget.bodyprovider['login_src'],
      'social_login_id': widget.bodyprovider['social_login_id'] ?? '',
      "description": _descController.text,
      "Perhour": _rateController.text,
      'fcm_token': StorageManager().fcmToken,
      'os': Platform.isAndroid?'android':'ios',
      "Extra_for_urgent_need": '${_extraRateController.text} 0.00' ?? ''
    };

    print('bb');
    if(widget.isFromEditGig??false){
      final result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AddGig(bodyprovider: bodyprovider1, isFromEditGig: widget.isFromEditGig, myGig: widget.myGig??null)));
      if(result == "1" && (widget.isFromEditGig??false)){
        Navigator.pop(context, "1");
      }
    }
    else {
      final result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  AddGig(bodyprovider: bodyprovider1,
                      isFromAddGig: widget.isFromAddGig)));
      if (result == "1" && (widget.isFromAddGig??false)) {
        Navigator.pop(context, "1");
      }
    }
  }
}
