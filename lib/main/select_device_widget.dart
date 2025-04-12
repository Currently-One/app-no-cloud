import 'dart:collection';
import 'dart:io';

import 'package:currently_local/model/device.dart';
import 'package:currently_local/model/states.dart';
import 'package:flutter/material.dart';
import 'package:nsd/nsd.dart';
import 'package:provider/provider.dart';

import '../analysis/analysis_tab.dart';

class SelectDeviceWidget extends StatefulWidget {
  const SelectDeviceWidget({super.key});

  @override
  State<SelectDeviceWidget> createState() => _SelectDeviceWidgetState();
}

class _SelectDeviceWidgetState extends State<SelectDeviceWidget> {
  final _available = SplayTreeMap<String, Device>();
  Device? _selectedDevice;
  Discovery? _discovery;
  static final String serviceName =
      Platform.isAndroid ? "_currently._tcp" : "_currently._tcp.";

  @override
  void initState() {
    _startMDnsClient();
    // _addAndListen(Device(deviceId: "b8b41879cf58", localIP: "10.0.1.122"));
    super.initState();
  }

  void _addAndListen(Device device) {
    final sub = device.listen();
    sub?.then((s) {
      setState(() {
        _available[device.deviceId] = device;
        _selectedDevice ??= device;
      });
    });
  }

  Future<void> _startMDnsClient() async {
    final serviceNameRegexp = RegExp(r'CurrentlyOne_([0-9a-fA-F]+)');

    _discovery?.dispose();

    final discovery =
        startDiscovery(serviceName, ipLookupType: IpLookupType.v4);
    discovery.then((d) {
      _discovery = d;
      d.addServiceListener((service, status) {
        final match = serviceNameRegexp.firstMatch(service.name ?? "");
        final id = match?.group(1);
        if (null != id && null != service.addresses) {
          String ipv4 = service.addresses!
              .firstWhere((element) => element.type == InternetAddressType.IPv4)
              .address;
          if (ServiceStatus.found == status) {
            debugPrint('+ found $id at $ipv4');
            _addAndListen(Device(
              deviceId: id,
              localIP: ipv4,
            ));
          } else {
            debugPrint('- lost $id at $ipv4');
            // _onLostDevice(id, ipv4);
          }
        }
      });
    });
  }

  List<DropdownMenuEntry<Device>> _dropdownMenuEntries() => _available.values
      .map((device) => DropdownMenuEntry(
            value: device,
            label: device.name ?? device.deviceId,
          ))
      .toList(growable: false);

  void _onSelectedDevice(Device? maybe) => setState(() {
        _selectedDevice = maybe;
      });

  @override
  Widget build(BuildContext context) {
    Widget _buildBottomNavigationBar() => Container(
        color: Theme.of(context).colorScheme.secondary,
        padding: const EdgeInsets.fromLTRB(8, 16, 8, 35),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 2,
            horizontal: 0,
          ),
          height: 64,
          decoration: ShapeDecoration(
            // color: CurrentlyApp.neutralWhite,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [],
          ),
        ));
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<Device?>.value(value: _selectedDevice),
          ChangeNotifierProvider<StatesCache?>.value(value: _selectedDevice?.states),
        ],
        child: Consumer<Device?>(
            builder: (context, device, child) => Scaffold(
                  appBar: AppBar(
                    backgroundColor:
                        Theme.of(context).colorScheme.inversePrimary,
                    title: DropdownMenu<Device>(
                      width: 200,
                      dropdownMenuEntries: _dropdownMenuEntries(),
                      initialSelection: device,
                      onSelected: _onSelectedDevice,
                    ),
                  ),
                  body: Center(
                    child: AnalysisTab(),
                  ),
              bottomNavigationBar: _buildBottomNavigationBar(),
                )));
  }
}
