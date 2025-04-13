import 'dart:collection';
import 'dart:io';

import 'package:currently_local/model/device.dart';
import 'package:currently_local/model/states.dart';
import 'package:flutter/material.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;
import 'package:nsd/nsd.dart';
import 'package:provider/provider.dart';

import '../analysis/analysis_tab.dart';
import '../main.dart';

class SelectDeviceWidget extends StatefulWidget {
  const SelectDeviceWidget({super.key});

  @override
  State<SelectDeviceWidget> createState() => _SelectDeviceWidgetState();
}

class _SelectDeviceWidgetState extends State<SelectDeviceWidget> {
  final _available = SplayTreeMap<String, Device>();
  Device? _selectedDevice;
  Discovery? _discovery;
  Widget _selectedTab = AnalysisTab();
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

  List<DropdownMenuItem<Device>> _dropdownMenuItems() => _available.values
      .map((device) => DropdownMenuItem(
            value: device,
            child: Text(
              device.name ?? device.deviceId,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ))
      .toList(growable: false);

  void _onSelectedDevice(Device? maybe) => setState(() {
        _selectedDevice = maybe;
      });

  @override
  Widget build(BuildContext context) {
    Widget buildNavigationButton(Widget icon, Widget tab) => ElevatedButton(
          style: ButtonStyle(
            backgroundColor: _selectedTab == tab
                ? WidgetStatePropertyAll(
                    Theme.of(context).colorScheme.secondary)
                : null,
            overlayColor: const WidgetStatePropertyAll(AppWidget.neutralWhite),
            elevation: const WidgetStatePropertyAll(0),
            minimumSize: const WidgetStatePropertyAll(Size(56, 48)),
            padding: const WidgetStatePropertyAll(EdgeInsets.zero),
          ),
          onPressed: _selectedTab != tab
              ? () {
                  setState(() {
                    _selectedTab = tab;
                  });
                }
              : null,
          child: icon,
        );

    Widget buildBottomNavigationBar() => Container(
        color: Theme.of(context).colorScheme.secondary,
        padding: const EdgeInsets.fromLTRB(8, 16, 8, 35),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 2,
            horizontal: 0,
          ),
          height: 64,
          decoration: ShapeDecoration(
            color: AppWidget.neutralWhite,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildNavigationButton(
                  iconoir.StatsUpSquare(
                      width: 36,
                      height: 36,
                      color: Theme.of(context).colorScheme.onPrimary),
                  AnalysisTab()),
            ],
          ),
        ));

    return MultiProvider(
        providers: [
          ChangeNotifierProvider<Device?>.value(value: _selectedDevice),
          ChangeNotifierProvider<StatesCache?>.value(
              value: _selectedDevice?.states),
        ],
        child: Consumer<Device?>(
            builder: (context, device, child) => Scaffold(
                  appBar: AppBar(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    title: DropdownButton<Device>(
                      items: _dropdownMenuItems(),
                      value: device,
                      onChanged: _onSelectedDevice,
                    ),
                  ),
                  body: Center(
                    child: null != device ? _selectedTab : null,
                  ),
                  bottomNavigationBar: buildBottomNavigationBar(),
                )));
  }
}
