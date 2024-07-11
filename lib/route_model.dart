import 'dart:convert';

class Routes {
  final String routeID;
  final String routeDayID;
  final String routeName;
  final String routeColor;
  final String? routeType;
  final DateTime routeDate;
  final String routeStatus;
  final String? routeInCharge;
  final String originPointName;
  final String originAddress;
  final String originLocationType;
  final String destinationAddress;
  final String destinationLocationType;
  final String destinationName;
  final DateTime routePlannedToStartOn;
  final int destinationDistance;
  final int destinationDuration;
  final String destinationId;
  final String destinationStopSequenceId;
  final DateTime destinationExpectedDeliveryOn;
  final DateTime? destinationCompletedOn;
  final String statusText;
  final bool status;
  final bool isActive;
  final Truck truck;
  final Driver driver;
  final List<dynamic> orders;
  final List<dynamic> salesOrderReturnProducts;
  final List<dynamic> inventoryOrders;
  final String wareHouseAddress;
  final List<Stop> stops;
  final List<RouteProduct> routeProducts;
  final DateTime routeActualStartOn;
  final int totalDuration;
  final int totalDistance;
  final DateTime? routeCompletedOn;
  final DateTime? routeActualEndOn;
  final DateTime createdOn;
  final String? locationType;
  final bool sodStatus;
  final bool eodStatus;
  final String routeApproach;
  final List<dynamic> invoiceOrders;
  final List<dynamic> returnOrders;

  Routes({
    required this.routeID,
    required this.routeDayID,
    required this.routeName,
    required this.routeColor,
    this.routeType,
    required this.routeDate,
    required this.routeStatus,
    this.routeInCharge,
    required this.originPointName,
    required this.originAddress,
    required this.originLocationType,
    required this.destinationAddress,
    required this.destinationLocationType,
    required this.destinationName,
    required this.routePlannedToStartOn,
    required this.destinationDistance,
    required this.destinationDuration,
    required this.destinationId,
    required this.destinationStopSequenceId,
    required this.destinationExpectedDeliveryOn,
    this.destinationCompletedOn,
    required this.statusText,
    required this.status,
    required this.isActive,
    required this.truck,
    required this.driver,
    required this.orders,
    required this.salesOrderReturnProducts,
    required this.inventoryOrders,
    required this.wareHouseAddress,
    required this.stops,
    required this.routeProducts,
    required this.routeActualStartOn,
    required this.totalDuration,
    required this.totalDistance,
    this.routeCompletedOn,
    this.routeActualEndOn,
    required this.createdOn,
    this.locationType,
    required this.sodStatus,
    required this.eodStatus,
    required this.routeApproach,
    required this.invoiceOrders,
    required this.returnOrders,
  });

  factory Routes.fromJson(Map<String, dynamic> json) {
    return Routes(
      routeID: json['routeID'],
      routeDayID: json['routeDayID'],
      routeName: json['routeName'],
      routeColor: json['routeColor'],
      routeType: json['routeType'],
      routeDate: DateTime.parse(json['routeDate']),
      routeStatus: json['routeStatus'],
      routeInCharge: json['routeInCharge'],
      originPointName: json['originPointName'],
      originAddress: json['orginaddress'],
      originLocationType: json['orginlocationtype'],
      destinationAddress: json['destinationaddress'],
      destinationLocationType: json['destinationlocationtype'],
      destinationName: json['destinationName'],
      routePlannedToStartOn: DateTime.parse(json['routePlannedToStartOn']),
      destinationDistance: json['destinationDistance'],
      destinationDuration: json['destinationDuration'],
      destinationId: json['destinationId'],
      destinationStopSequenceId: json['destinationStopSequenceId'],
      destinationExpectedDeliveryOn: DateTime.parse(json['destinationExpectedDeliveryon']),
      destinationCompletedOn: json['destinationCompletedOn'] != null ? DateTime.parse(json['destinationCompletedOn']) : null,
      statusText: json['statusText'],
      status: json['status'],
      isActive: json['isActive'],
      truck: Truck.fromJson(json['truck']),
      driver: Driver.fromJson(json['driver']),
      orders: List<dynamic>.from(json['orders']),
      salesOrderReturnProducts: List<dynamic>.from(json['salesOrderReturnProducts']),
      inventoryOrders: List<dynamic>.from(json['inventoryOrders']),
      wareHouseAddress: json['wareHouseAddress'],
      stops: (json['stops'] as List).map((i) => Stop.fromJson(i)).toList(),
      routeProducts: (json['routeProducts'] as List).map((i) => RouteProduct.fromJson(i)).toList(),
      routeActualStartOn: DateTime.parse(json['routeactualstarton']),
      totalDuration: json['totalduration'],
      totalDistance: json['totaldistance'],
      routeCompletedOn: json['routecompletedon'] != null ? DateTime.parse(json['routecompletedon']) : null,
      routeActualEndOn: json['routeactualendon'] != null ? DateTime.parse(json['routeactualendon']) : null,
      createdOn: DateTime.parse(json['createdon']),
      locationType: json['locationtype'],
      sodStatus: json['sodStatus'],
      eodStatus: json['eodStatus'],
      routeApproach: json['routeApproach'],
      invoiceOrders: List<dynamic>.from(json['invoiceOrders']),
      returnOrders: List<dynamic>.from(json['returnOrders']),
    );
  }
}

class Truck {
  final String truckNum;
  final String truckName;
  final String truckTypeName;

  Truck({
    required this.truckNum,
    required this.truckName,
    required this.truckTypeName,
  });

  factory Truck.fromJson(Map<String, dynamic> json) {
    return Truck(
      truckNum: json['trucknum'],
      truckName: json['truckname'],
      truckTypeName: json['trucktypename'],
    );
  }
}

class Driver {
  final String driverName;
  final String? driverID;
  final String mobileNumber;
  final String emailID;

  Driver({
    required this.driverName,
    this.driverID,
    required this.mobileNumber,
    required this.emailID,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      driverName: json['driverName'],
      driverID: json['driverID'],
      mobileNumber: json['mobileNumber'],
      emailID: json['emailID'],
    );
  }
}

class Stop {
  final String id;
  final String sequencedStopID;
  final String? routeDayID;
  final String stopID;
  final String stopName;
  final String type;
  final int sequence;
  final String address;
  final DateTime expectedDeliveryOn;
  final int isCompleted;
  final String reason;
  final String sequenceChangeReason;
  final String comments;
  final bool? isPickedUp;
  final int distance;
  final int duration;
  final DateTime? completedOn;
  final bool isCancelled;
  final bool isDestination;
  final DateTime? availableStartTime;
  final DateTime? availableEndTime;
  final bool isPartial;

  Stop({
    required this.id,
    required this.sequencedStopID,
    this.routeDayID,
    required this.stopID,
    required this.stopName,
    required this.type,
    required this.sequence,
    required this.address,
    required this.expectedDeliveryOn,
    required this.isCompleted,
    required this.reason,
    required this.sequenceChangeReason,
    required this.comments,
    this.isPickedUp,
    required this.distance,
    required this.duration,
    this.completedOn,
    required this.isCancelled,
    required this.isDestination,
    this.availableStartTime,
    this.availableEndTime,
    required this.isPartial,
  });

  factory Stop.fromJson(Map<String, dynamic> json) {
    return Stop(
      id: json['id'],
      sequencedStopID: json['sequencedStopID'],
      routeDayID: json['routeDayID'],
      stopID: json['stopID'],
      stopName: json['stopName'],
      type: json['type'],
      sequence: json['sequence'],
      address: json['address'],
      expectedDeliveryOn: DateTime.parse(json['expectedDeliveryOn']),
      isCompleted: json['isCompleted'],
      reason: json['reason'],
      sequenceChangeReason: json['sequnceChangeReason'],
      comments: json['comments'],
      isPickedUp: json['isPickedUp'],
      distance: json['distance'],
      duration: json['duration'],
      completedOn: json['completedOn'] != null ? DateTime.parse(json['completedOn']) : null,
      isCancelled: json['iscancelled'],
      isDestination: json['isDestination'],
      availableStartTime: json['avialbleStartTime'] != null ? DateTime.parse(json['avialbleStartTime']) : null,
      availableEndTime: json['avialbleEndTime'] != null ? DateTime.parse(json['avialbleEndTime']) : null,
      isPartial: json['isPartial'],
    );
  }
}

class RouteProduct {
  final String productID;
  final String warehouseID;
  final String loadType;
  final String productName;
  final int totalQty;
  final int availableQty;
  final int requiredQty;
  final int soldQty;
  final bool isLoaded;
  final int price;
  final String? productType;
  final String warehouseName;
  final String productNumber;

  RouteProduct({
    required this.productID,
    required this.warehouseID,
    required this.loadType,
    required this.productName,
    required this.totalQty,
    required this.availableQty,
    required this.requiredQty,
    required this.soldQty,
    required this.isLoaded,
    required this.price,
    this.productType,
    required this.warehouseName,
    required this.productNumber,
  });

  factory RouteProduct.fromJson(Map<String, dynamic> json) {
    return RouteProduct(
      productID: json['productID'],
      warehouseID: json['warehouseID'],
      loadType: json['loadType'],
      productName: json['productName'],
      totalQty: json['totaQty'],
      availableQty: json['availableQty'],
      requiredQty: json['requiredQty'],
      soldQty: json['soldQty'],
      isLoaded: json['isLoaded'],
      price: json['price'],
      productType: json['producttype'],
      warehouseName: json['warehousename'],
      productNumber: json['productnumber'],
    );
  }
}

// export 'route_model.dart';

 