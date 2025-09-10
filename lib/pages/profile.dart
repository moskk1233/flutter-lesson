import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:msu_flutter/config/config.dart';
import 'package:msu_flutter/model/response/customer_idx_get_res.dart';

class ProfilePage extends StatefulWidget {
  final int idx;
  const ProfilePage({super.key, required this.idx});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<CustomerIdxGetResponse> loadData;
  late CustomerIdxGetResponse customerIdxGetResponse;

  final fullnameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final imageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData = loadDataAsync();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CustomerIdxGetResponse>(
      future: loadData,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('ข้อมูลส่วนตัว'),
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) {
                  log(value);
                  if (value == 'delete') {
                    showDialog(
                      context: context,
                      builder: (context) => SimpleDialog(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'ยืนยันการยกเลิกสมาชิก?',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('ปิด'),
                              ),
                              FilledButton(
                                onPressed: delete,
                                child: const Text('ยืนยัน'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Text('ยกเลิกสมาชิก'),
                  ),
                ],
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                
                CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(customerIdxGetResponse.image),
                ),
                const SizedBox(height: 20),

                
                TextFormField(
                  controller: fullnameController,
                  decoration: const InputDecoration(
                    labelText: "ชื่อ-นามสกุล",
                    border: UnderlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),

                
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: "หมายเลขโทรศัพท์",
                    border: UnderlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),

                
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: "อีเมล์",
                    border: UnderlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),

                
                TextFormField(
                  controller: imageController,
                  decoration: const InputDecoration(
                    labelText: "รูปภาพ",
                    border: UnderlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 30),

                
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: update,
                    child: const Text('บันทึกข้อมูล'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<CustomerIdxGetResponse> loadDataAsync() async {
    var config = await Configuration.getConfig();
    var url = config['API_ENDPOINT'];
    var res = await http.get(Uri.parse('$url/customers/${widget.idx}'));
    log(res.body);
    customerIdxGetResponse = customerIdxGetResponseFromJson(res.body);

    
    fullnameController.text = customerIdxGetResponse.fullname;
    phoneController.text = customerIdxGetResponse.phone;
    emailController.text = customerIdxGetResponse.email;
    imageController.text = customerIdxGetResponse.image;

    return customerIdxGetResponse;
  }

  void update() async {
    var config = await Configuration.getConfig();
    var url = config['API_ENDPOINT'];

    var json = {
      "fullname": fullnameController.text,
      "phone": phoneController.text,
      "email": emailController.text,
      "image": imageController.text,
    };

    try {
      var res = await http.put(
        Uri.parse('$url/customers/${widget.idx}'),
        headers: {"Content-Type": "application/json; charset=utf-8"},
        body: jsonEncode(json),
      );
      log(res.body);
      var result = jsonDecode(res.body);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('สำเร็จ'),
          content: Text('บันทึกข้อมูลเรียบร้อย'),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ปิด'),
            ),
          ],
        ),
      );
    } catch (err) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('ผิดพลาด'),
          content: Text('บันทึกข้อมูลไม่สำเร็จ: $err'),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ปิด'),
            ),
          ],
        ),
      );
    }
  }

  void delete() async {
    var config = await Configuration.getConfig();
    var url = config['API_ENDPOINT'];

    var res = await http.delete(Uri.parse('$url/customers/${widget.idx}'));
    log(res.statusCode.toString());
    if (res.statusCode == 200) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('สำเร็จ'),
          content: Text('ลบข้อมูลสำเร็จ'),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text('ปิด'),
            ),
          ],
        ),
      ).then((s) {
        Navigator.popUntil(context, (route) => route.isFirst);
      });
    } else {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('ผิดพลาด'),
          content: Text('ลบข้อมูลไม่สำเร็จ'),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('ปิด'),
            ),
          ],
        ),
      );
    }
  }
}