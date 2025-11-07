import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wanna_do/style/appbar_style.dart';

class WannaLogin extends StatefulWidget {
  const WannaLogin({super.key});

  @override
  State<WannaLogin> createState() => _WannaLoginState();
}

class _WannaLoginState extends State<WannaLogin> {
  String? nickname;
  String? friend;
  int maincash = 1000;
  int cumfriendcash = 0;
  bool gender = false;
  bool gender2 = false;
  bool isChecked1 = false;
  bool isChecked2 = false;
  String? birth;
  final GlobalKey<FormState> formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: SubAppBar(),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.always,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '[필수] 이름',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width / 1.15,
                          height: 100,
                          child: TextFormField(
                            keyboardType: TextInputType.multiline,
                            onSaved: (String? val) {
                              setState(() {
                                nickname = val;
                              });
                            },
                            validator: (String? val) {
                              if (val == null || val.isEmpty) {
                                return '값을 입력해주세요';
                              }
                              if (val.length >= 10) {
                                return '10자 이내로 입력해주세요';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: '박서준',
                              hintStyle: TextStyle(
                                color: Colors.grey[400],
                              ),
                            ),
                            initialValue: nickname ?? '',
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Text(
                      '[필수] 전화번호',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width / 1.15,
                          height: 100,
                          child: TextFormField(
                            keyboardType: TextInputType.multiline,
                            onSaved: (String? val) {
                              setState(() {
                                nickname = val;
                              });
                            },
                            validator: (String? val) {
                              if (val == null || val.isEmpty) {
                                return '값을 입력해주세요';
                              }
                              if (val.length >= 10) {
                                return '10자 이내로 입력해주세요';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: '01012345678',
                              hintStyle: TextStyle(
                                color: Colors.grey[400],
                              ),
                            ),
                            initialValue: nickname ?? '',
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '[필수] 성별',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 30),
                              Table(
                                defaultColumnWidth: IntrinsicColumnWidth(),
                                border: TableBorder.all(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                children: [
                                  TableRow(
                                    children: [
                                      TableCell(
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              gender = true;
                                              gender2 = true;
                                            });
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(8.0),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.horizontal(
                                                left: Radius.circular(8.0),
                                              ),
                                              color: gender2
                                                  ? gender
                                                      ? Color(0xE06592F6)
                                                          .withOpacity(0.6)
                                                      : Colors.white
                                                  : Colors.white,
                                            ),
                                            child: Center(
                                              child: Text(
                                                '남성',
                                                style: TextStyle(
                                                  color: gender2
                                                      ? gender
                                                          ? Colors.black
                                                          : Colors.grey
                                                      : Colors.grey,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      TableCell(
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              gender = false;
                                              gender2 = true;
                                            });
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(8.0),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.horizontal(
                                                right: Radius.circular(8.0),
                                              ),
                                              color: gender2
                                                  ? gender
                                                      ? Colors.white
                                                      : Color(0xE06592F6)
                                                          .withOpacity(0.6)
                                                  : Colors.white,
                                            ),
                                            child: Center(
                                              child: Text(
                                                '여성',
                                                style: TextStyle(
                                                  color: gender2
                                                      ? gender
                                                          ? Colors.grey
                                                          : Colors.black
                                                      : Colors.grey,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '[필수] 생년월일',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 30),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width / 2.5,
                                    height: 65,
                                    child: TextFormField(
                                      onSaved: (String? val) {
                                        setState(() {
                                          birth = val;
                                        });
                                      },
                                      validator: (String? val) {
                                        if (val == null || val.isEmpty) {
                                          return '값을 입력해주세요';
                                        } else if (val.length != 6) {
                                          return '6자리로 입력해주세요';
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        hintText: '020814',
                                        hintStyle: TextStyle(
                                          color: Colors.grey[400],
                                        ),
                                      ),
                                      initialValue: birth ?? '',
                                      maxLines: 1,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter
                                            .digitsOnly, // 숫자만 입력 가능하도록 필터링
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 40),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Checkbox(
                                activeColor: Color(0xE01A61FA),
                                value: isChecked1,
                                onChanged: (bool? newValue) {
                                  setState(
                                    () {
                                      isChecked1 = newValue!;
                                    },
                                  );
                                },
                              ),
                              SizedBox(width: 5),
                              GestureDetector(
                                onTap: () {},
                                child: Row(
                                  children: [
                                    Text(
                                      '[필수] ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: !isChecked1
                                            ? Colors.black
                                            : Color(0xFF3F60FD),
                                      ),
                                    ),
                                    Text(
                                      '워너두 이용약관 동의',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        color: !isChecked1
                                            ? Colors.black
                                            : Color(0xFF3F60FD),
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Checkbox(
                                activeColor: Color(0xE01A61FA),
                                value: isChecked2,
                                onChanged: (bool? newValue) {
                                  setState(
                                    () {
                                      isChecked2 = newValue!;
                                    },
                                  );
                                },
                              ),
                              SizedBox(width: 5),
                              GestureDetector(
                                onTap: () {},
                                child: Row(
                                  children: [
                                    Text(
                                      '[필수] ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: !isChecked2
                                            ? Colors.black
                                            : Color(0xFF3F60FD),
                                      ),
                                    ),
                                    Text(
                                      '워너두 개인정보취급방침 동의',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        color: !isChecked2
                                            ? Colors.black
                                            : Color(0xFF3F60FD),
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
