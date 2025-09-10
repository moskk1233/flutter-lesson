import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:msu_flutter/config/config.dart';
import 'package:msu_flutter/model/response/trip_get_res.dart';
import 'package:msu_flutter/pages/profile.dart';
import 'package:msu_flutter/pages/trip.dart';

class TripsPage extends StatefulWidget {
  int cid = 0;

  TripsPage({super.key, required this.cid});
  @override
  State<TripsPage> createState() => _TripsPageState();
}

class _TripsPageState extends State<TripsPage> {
  String url = '';
  List<TripGetResponse> tripGetResponses = [];
  late Future<void> loadData;
  @override
  void initState() {
    super.initState();
    // Configuration.getConfig().then((config) {
    //   url = config['API_ENDPOINT'];
    //   getTrips();
    // });
    loadData = getTrips();
  }

  @override
  Widget build(BuildContext context) {
    log(widget.cid.toString());
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายการทริป'),
        actions: [
          PopupMenuButton(
            onSelected: (value) => {
              if (value == 'profile')
                {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(idx: widget.cid),
                    ),
                  ),
                }
              else if (value == 'logout')
                {Navigator.popUntil(context, (route) => route.isFirst)},
            },
            itemBuilder: (context) => [
              PopupMenuItem(child: Text('ข้อมูลส่วนตัว'), value: 'profile'),
              PopupMenuItem(child: Text('ออกจากระบบ'), value: 'logout'),
            ],
          ),
        ],
      ),
      body: FutureBuilder(
        future: loadData,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('ปลายทาง'),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    FilledButton(
                      onPressed: () {
                        getTrips();

                        setState(() {
                          // All trips will be replaced by eurotrips
                        });
                      },
                      child: const Text('ทั้งหมด'),
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      onPressed: () {
                        getTrips();
                        List<TripGetResponse> asiaTrips = [];
                        for (var trip in tripGetResponses) {
                          if (trip.destinationZone == 'เอเชีย') {
                            asiaTrips.add(trip);
                          }
                        }
                        setState(() {
                          // All trips will be replaced by eurotrips
                          tripGetResponses = asiaTrips;
                        });
                      },
                      child: const Text('เอเชีย'),
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      onPressed: () {
                        getTrips();
                        List<TripGetResponse> euroTrips = [];
                        for (var trip in tripGetResponses) {
                          if (trip.destinationZone == 'ยุโรป') {
                            euroTrips.add(trip);
                          }
                        }
                        setState(() {
                          // All trips will be replaced by eurotrips
                          tripGetResponses = euroTrips;
                        });
                      },
                      child: const Text('ยุโรป'),
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      onPressed: () {
                        getTrips();
                        List<TripGetResponse> asianTrips = [];
                        for (var trip in tripGetResponses) {
                          if (trip.destinationZone == 'อาเซียน') {
                            asianTrips.add(trip);
                          }
                        }
                        setState(() {
                          // All trips will be replaced by eurotrips
                          tripGetResponses = asianTrips;
                        });
                      },
                      child: const Text('อาเซียน'),
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      onPressed: () {
                        getTrips();
                        List<TripGetResponse> asianTrips = [];
                        for (var trip in tripGetResponses) {
                          if (trip.destinationZone == 'ประเทศไทย') {
                            asianTrips.add(trip);
                          }
                        }
                        setState(() {
                          // All trips will be replaced by eurotrips
                          tripGetResponses = asianTrips;
                        });
                      },
                      child: const Text('ประเทศไทย'),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: ListView(
                  children: tripGetResponses
                      .map(
                        (trip) => Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.network(
                                trip.coverimage,
                                width: double.infinity,
                                height: 150,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image),
                              ),
                              ListTile(
                                title: Text(trip.name),
                                subtitle: Text('ราคา: ${trip.price} บาท'),
                              ),
                              FilledButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          TripPage(idx: trip.idx),
                                    ),
                                  );
                                },
                                child: const Text('รายละเอียดเพิ่มเติม'),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Map<dynamic, dynamic> get gotoTrip => {};

  getTrips() async {
    // var res = await http.get(Uri.parse('$url/trips'));
    // log(res.body);
    // setState(() {
    //   tripGetResponses = tripGetResponseFromJson(res.body);
    // });
    // log(tripGetResponses.length.toString());

    var config = await Configuration.getConfig();
    url = config['API_ENDPOINT'];
    var res = await http.get(Uri.parse('$url/trips'));
    tripGetResponses = tripGetResponseFromJson(res.body);
  }

  Future<void> loadDataAsync() async {
    var config = await Configuration.getConfig();
    url = config['API_ENDPOINT'];

    var res = await http.get(Uri.parse('$url/trips'));
    log(res.body);
    tripGetResponses = tripGetResponseFromJson(res.body);
    log(tripGetResponses.length.toString());
  }
}

void gotoTrip(int id, BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => TripPage(idx: id)),
  );
}