import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;

class UmkmModel {
  String id;
  String name;
  String type;
  // constructor ->
  UmkmModel({required this.name, required this.type, required this.id});
}

class UmkmCubit extends Cubit<List<UmkmModel>> {
  String url = "http://178.128.17.76:8000/daftar_umkm";
  UmkmCubit() : super([UmkmModel(name: "", type: "", id: "")]);

  // map dari json ke atribut
  void setFromJson(Map<String, dynamic> json) {
    List<dynamic> dataList = json['data'];

    List<UmkmModel> datas = dataList
        .map((e) => UmkmModel(name: e['nama'], type: e['jenis'], id: e['id']))
        .toList();
    // emit state baru, berebeda dengan provider
    emit(datas);
  }

  void fetchData() async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      // success
      setFromJson(jsonDecode(response.body));
    } else {
      throw Exception('gagal load');
    }
  }
}

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<UmkmCubit>(
            create: (_) => UmkmCubit(),
          ),
          BlocProvider<UmkmDetailCubit>(
            create: (_) => UmkmDetailCubit(),
          ),
        ],
        child: HalamanUtama(),
      ),
    );
  }
}

class HalamanUtama extends StatelessWidget {
  const HalamanUtama({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.blue,
          title: Text(
            'My App',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: [
                Column(
                  children: [
                    Text(
                        '2103303, Ihsan Ghozi Zulfikar; 2108799, Ade Mulyana; Saya berjanji tidak akan berbuat curang data atau membantu orang lain berbuat curang'),
                    SizedBox(
                      height: 20.0,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        context.read<UmkmCubit>().fetchData();
                      },
                      child: Text('Reload Daftar UMKM'),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    BlocBuilder<UmkmCubit, List<UmkmModel>>(
                        buildWhen: (previousState, state) {
                      developer.log(
                          '${previousState[0].name}->${state[0].name}',
                          name: 'log');
                      return true;
                    }, builder: (context, umkmList) {
                      return Container(
                        height: 500,
                        child: ListView.builder(
                          itemCount: umkmList.length,
                          itemBuilder: (context, index) {
                            if (umkmList[0].name != "") {
                              return ListTile(
                                leading: Image.network(
                                    'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-2.jpg'),
                                title: Text(umkmList[index].name),
                                subtitle: Text(umkmList[index].type),
                                trailing: Icon(Icons.more_vert_rounded),
                                onTap: () {
                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                    context
                                        .read<UmkmDetailCubit>()
                                        .fetchData2(umkmList[index].id);
                                    return LayarKedua();
                                  }));
                                },
                              );
                            }
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class UmkmDetailModel {
  String name;
  String type;
  String member;
  String omzet;
  String lama;
  String jumlah;

  // constructor ->
  UmkmDetailModel(
      {required this.name,
      required this.type,
      required this.member,
      required this.omzet,
      required this.lama,
      required this.jumlah});
}

class UmkmDetailCubit extends Cubit<UmkmDetailModel> {
  String id = "1";
  String url = "http://178.128.17.76:8000/detil_umkm/1";
  UmkmDetailCubit()
      : super(UmkmDetailModel(
            name: "", type: "", member: "", omzet: "", lama: "", jumlah: ""));

  // map dari json ke atribut
  void setFromJson(dynamic json) {
    print(json);
    emit(UmkmDetailModel(
        name: json['nama'],
        type: json['jenis'],
        member: json['member_sejak'],
        omzet: json['omzet_bulan'],
        lama: json['lama_usaha'],
        jumlah: json['jumlah_pinjaman_sukses']));
  }

  void fetchData() async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      // success
      print(response.body);
      setFromJson(jsonDecode(response.body));
    } else {
      throw Exception('gagal load');
    }
  }

  void fetchData2(String id) async {
    url = "http://178.128.17.76:8000/detil_umkm/$id";
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      // success
      print(response.body);
      setFromJson(jsonDecode(response.body));
    } else {
      throw Exception('gagal load');
    }
  }
}

class LayarKedua extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Detail'),
          centerTitle: true,
        ),
        body: Column(
          children: [
            BlocBuilder<UmkmDetailCubit, UmkmDetailModel>(
                buildWhen: (previousState, state) {
              developer.log('${previousState.name}->${state.name}',
                  name: 'log');
              return true;
            }, builder: (context, umkmDetail) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue[200],
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      )
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Text(
                          'Nama: ${umkmDetail.name}',
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                        Text('Detail: ${umkmDetail.type}',
                            style: TextStyle(color: Colors.white)),
                        SizedBox(
                          height: 5.0,
                        ),
                        Text("Membe Sejak: ${umkmDetail.member}",
                            style: TextStyle(color: Colors.white)),
                        SizedBox(
                          height: 5.0,
                        ),
                        Text('Omzet: ${umkmDetail.omzet} ',
                            style: TextStyle(color: Colors.white)),
                        SizedBox(
                          height: 5.0,
                        ),
                        Text('Lama: ${umkmDetail.lama}',
                            style: TextStyle(color: Colors.white)),
                        SizedBox(
                          height: 5.0,
                        ),
                        Text('Jumlah: ${umkmDetail.jumlah}',
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              );
            })
          ],
        ));
  }
}
