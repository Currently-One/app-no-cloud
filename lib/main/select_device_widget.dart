import 'dart:collection';
import 'dart:io';

import 'package:currently_local/model/device.dart';
import 'package:flutter/material.dart';
import 'package:nsd/nsd.dart';
import 'package:provider/provider.dart';

class SelectDeviceWidget extends StatefulWidget {
  const SelectDeviceWidget({super.key});

  @override
  State<SelectDeviceWidget> createState() => _SelectDeviceWidgetState();
}

class _SelectDeviceWidgetState extends State<SelectDeviceWidget> {
  final _available = SplayTreeMap<String, Device>();
  Device? _selected;
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
        _selected ??= device;
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
            _addAndListen(Device(deviceId: id, localIP: ipv4,));
          } else {
            debugPrint('- lost $id at $ipv4');
            // _onLostDevice(id, ipv4);
          }
        }
      });
    });
  }

  List<DropdownMenuEntry<Device>> get _dropdownMenuEntries => _available.values
      .map((device) => DropdownMenuEntry(
            value: device,
            label: device.name ?? device.deviceId,
          ))
      .toList(growable: false);

  void _onSelectedDevice(Device? maybe) => setState(() {
        _selected = maybe;
      });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<Device?>.value(value: _selected),
        ],
        child: Consumer<Device?>(
            builder: (context, device, child) => Scaffold(
                  appBar: AppBar(
                    backgroundColor:
                        Theme.of(context).colorScheme.inversePrimary,
                    title: DropdownMenu<Device>(
                      width: 200,
                      dropdownMenuEntries: _dropdownMenuEntries,
                      initialSelection: device,
                      onSelected: _onSelectedDevice,
                    ),
                  ),
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text(
                          'You have pushed the button this many times:',
                        ),
                        Text(
                          'foo',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ],
                    ),
                  ),
                )));
  }
}
