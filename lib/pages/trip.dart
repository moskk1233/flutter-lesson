import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:msu_flutter/config/config.dart';
import 'package:msu_flutter/model/response/trip_idx_get_res.dart';

class TripPage extends StatefulWidget {
  int idx = 0;

  TripPage({super.key, required this.idx});

  @override
  State<TripPage> createState() => _TripPageState();
}

class _TripPageState extends State<TripPage> {
  String url = '';
  late TripIdxGetResponse tripIdxGetResponse;
  late Future<void> loadData;
  @override
  void initState() {
    super.initState();
    // Call async function
    loadData = loadDataAsync();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),

      body: FutureBuilder(
        future: loadData,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          // Load Done
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  tripIdxGetResponse.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  tripIdxGetResponse.country,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              Image.network(tripIdxGetResponse.coverimage),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ราคา ${tripIdxGetResponse.price} บาท',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 130),
                    Text(
                      'โซน: ${tripIdxGetResponse.destinationZone}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  tripIdxGetResponse.detail,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              Center(
                child: FilledButton(
                  onPressed: () {},
                  child: const Text('จองทริป'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> loadDataAsync() async {
    var config = await Configuration.getConfig();
    url = config['API_ENDPOINT'];
    var res = await http.get(Uri.parse('$url/trips/${widget.idx}'));
    log(res.body);
    tripIdxGetResponse = tripIdxGetResponseFromJson(res.body);
  }
}