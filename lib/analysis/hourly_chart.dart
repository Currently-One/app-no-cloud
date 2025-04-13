import 'package:community_charts_common/community_charts_common.dart' as common
    show AnnotationSegment, BarGroupingType;
import 'package:community_charts_flutter/community_charts_flutter.dart'
    as charts;
import 'package:currently_local/model/hourly.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart';

import '../main.dart';
import '../model/device.dart';
import '../services/hourly_service.dart';

class HourlyChart extends StatelessWidget {
  static const hourLabels = {"00", "03", "06", "09", "12", "15", "18", "21"};
  static final dateFormat = DateFormat("HH");
  static const colorUsage = AppWidget.marigold300;
  static const colorCurrentUsage = AppWidget.neutral200;
  static const colorProduced = AppWidget.leaf400;
  static const colorPrice = AppWidget.neutral900;
  static const colorCost = AppWidget.neutral900;

  final Device device;
  final DateTime startHour, endHour;
  late final HourlyService hourlyService;

  HourlyChart({
    super.key,
    required this.device,
    required this.startHour,
    required this.endHour,
  }) {
    hourlyService = HourlyService(device);
  }

  DateTime _domainBars(Hourly h, _) => h.startHour.add(Duration(minutes: 30));

  num? _importedFn(Hourly h, _) => null == h.dWh ? null : h.dWh! / 1000.0;
  num? _exportedFn(Hourly h, _) => null == h.dPh ? null : h.dPh! / 1000.0;

  List<charts.TickSpec<DateTime>> get _tickSpecs {
    final tickSpecs = <charts.TickSpec<DateTime>>[];
    DateTime dt = startHour;
    while (dt.isBefore(endHour)) {
      final s = dateFormat.format(dt); // dt.hour.toString().padLeft(2, "0");
      // ticks
      if (hourLabels.contains(s)) {
        tickSpecs.add(charts.TickSpec(
          dt,
          label: s,
        ));
      }
      dt = dt.add(Duration(hours: 1));
    }
    return tickSpecs;
  }

  List<common.AnnotationSegment<Object>> get _rangeAnnotations {
    final ranges = <common.AnnotationSegment<Object>>[];
    DateTime dt = startHour;
    while (dt.isBefore(endHour)) {
      final s = dateFormat.format(dt); // dt.hour.toString().padLeft(2, "0");
      // ticks
      if (hourLabels.contains(s)) {
        final las = charts.LineAnnotationSegment(
          dt,
          charts.RangeAnnotationAxisType.domain,
          strokeWidthPx: 2.0,
        );
        ranges.add(las);
      }
      dt = dt.add(Duration(hours: 1));
    }
    return ranges;
  }

  static charts.Color chartColor(Color color) => charts.Color(
      r: (color.r * 255.0).round() & 0xff,
      g: (color.g * 255.0).round() & 0xff,
      b: (color.b * 255.0).round() & 0xff);

  @override
  Widget build(BuildContext context) {
    final currentHour = Hourly.truncated(TZDateTime.now(device.location));
    final data = hourlyService.getHourlyList(startHour, endHour);

    charts.Color colorImported(Hourly h, int? index) =>
        chartColor(currentHour.millisecondsSinceEpoch == h.ms
            ? colorCurrentUsage
            : colorUsage);

    charts.Color colorExported(Hourly h, int? index) =>
        chartColor(currentHour.millisecondsSinceEpoch == h.ms
            ? colorCurrentUsage
            : colorProduced);

    final seriesList = [
      charts.Series<Hourly, DateTime>(
        id: "imported",
        data: data,
        measureFn: _importedFn,
        domainFn: _domainBars,
        colorFn: colorImported,
      ),
      charts.Series<Hourly, DateTime>(
        id: "exported",
        data: data,
        measureFn: _exportedFn,
        domainFn: _domainBars,
        colorFn: colorExported,
      ),
    ];
    return charts.TimeSeriesChart(
      seriesList,
      animate: false,
      behaviors: [
        charts.RangeAnnotation(_rangeAnnotations),
      ],
      defaultRenderer: charts.BarRendererConfig<DateTime>(
        groupingType: common.BarGroupingType.groupedStacked,
        stackedBarPaddingPx: 0,
      ),
      domainAxis: charts.DateTimeAxisSpec(
        tickFormatterSpec:
            charts.BasicDateTimeTickFormatterSpec.fromDateFormat(dateFormat),
        tickProviderSpec: charts.StaticDateTimeTickProviderSpec(_tickSpecs),
      ),
      primaryMeasureAxis: const charts.NumericAxisSpec(
          tickProviderSpec: charts.BasicNumericTickProviderSpec(
              dataIsInWholeNumbers: false, desiredTickCount: 6)),
      secondaryMeasureAxis: const charts.NumericAxisSpec(
          tickProviderSpec: charts.BasicNumericTickProviderSpec(
              dataIsInWholeNumbers: false, desiredTickCount: 6)),
    );
  }
}
