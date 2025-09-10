import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:msu_flutter/config/config.dart';
import 'package:msu_flutter/model/request/customer_login_post_req.dart';
import 'package:msu_flutter/model/response/customer_login_post_res.dart';
import 'package:msu_flutter/pages/register.dart';
import 'package:msu_flutter/pages/trips.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String text = '';
  int number = 0;
  TextEditingController phoneNoCtl = TextEditingController();
  TextEditingController passwordCtl = TextEditingController();
  String url = '';
  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then((config) {
      url = config['API_ENDPOINT'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login Page")),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              GestureDetector(
                onTap: () => login(),

                child: Image.asset("assets/img/logo.png"),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "หมายเลขโทรศัพท์",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: TextField(
                      controller: phoneNoCtl,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(width: 1),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "รหัสผ่าน",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: TextField(
                      controller: passwordCtl,
                      obscureText: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(width: 1),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => register(),
                    child: const Text('ลงทะเบียนใหม่'),
                  ),
                  FilledButton(
                    onPressed: () => login(),
                    child: const Text('เข้าสู่ระบบ'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void register() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegisterPage()),
    );
  }

  void login() {
    // var data = {"phone": "0817399999", "password": "1111"};
    CustomerLoginPostRequest customerLoginPostRequest =
        CustomerLoginPostRequest(
          phone: phoneNoCtl.text,
          password: passwordCtl.text,
        );

    http
        .post(
          Uri.parse("$url/customers/login"),
          headers: {"Content-Type": "application/json; charset=utf-8"},
          body: customerLoginPostRequestToJson(customerLoginPostRequest),
        )
        .then((value) {
          log(value.body);
          CustomerLoginPostResponse customerLoginPostResponse =
              customerLoginPostResponseFromJson(value.body);
          log(customerLoginPostResponse.customer.fullname);
          log(customerLoginPostResponse.customer.email);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  TripsPage(cid: customerLoginPostResponse.customer.idx),
            ),
          );
        })
        .catchError((error) {
          log('Error $error');
        });
  }
}