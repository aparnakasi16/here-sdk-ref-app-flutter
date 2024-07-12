/*
 * Copyright (C) 2020-2024 HERE Europe B.V.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * SPDX-License-Identifier: Apache-2.0
 * License-Filename: LICENSE
 */

import 'dart:async';
import 'dart:io';
import 'dart:developer';
import 'dart:convert';
import 'package:BMobileNavigation/common/extensions/error_handling/map_loader_error_extension.dart';
import 'package:BMobileNavigation/common/file_utility.dart';
import 'package:BMobileNavigation/routing/routing_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:here_sdk/consent.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/core.engine.dart';
import 'package:here_sdk/gestures.dart';
import 'package:here_sdk/location.dart';
import 'package:here_sdk/maploader.dart';
import 'package:here_sdk/mapview.dart';
import 'package:here_sdk/search.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'route_model.dart';
import 'package:http/http.dart' as http;
import 'common/application_preferences.dart';
import 'common/connection_state_monitor.dart';
import 'common/custom_map_style_settings.dart';
import 'common/load_custom_style_result_popup.dart';
import 'common/place_actions_popup.dart';
import 'common/reset_location_button.dart';
import 'common/ui_style.dart';
import 'common/util.dart' as Util;
import 'download_maps/download_maps_screen.dart';
import 'download_maps/map_loader_controller.dart';
import 'positioning/no_location_warning_widget.dart';
import 'positioning/positioning.dart';
import 'positioning/positioning_engine.dart';
import 'routing/waypoint_info.dart';
import 'search/search_popup.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:uni_links/uni_links.dart';


/// The home screen of the application.
class LandingScreen extends StatefulWidget {
  static const String navRoute = "/";
   final String routeIdParam;
   

  LandingScreen({
    Key? key,
    required this.routeIdParam,
    }) : super(key: key);

  

  @override
  _LandingScreenState createState() => _LandingScreenState();

}



class _LandingScreenState extends State<LandingScreen> with Positioning, WidgetsBindingObserver {
  static const int _kLocationWarningDismissPeriod = 5; // seconds
  static const int _kLoadCustomStyleResultPopupDismissPeriod = 5; // seconds
  static const String _fromAddress = '627 Vallejo St, San Francisco, CA 94133-3918, United States';
  bool _mapInitSuccess = false;
  bool _didBackPressedAndPositionStopped = false;
  final GlobalKey _bottomBarKey = GlobalKey();
  static const double _kPlaceCardHeight = 80;
  late HereMapController _hereMapController;
  late PositioningEngine _positioningEngine;
  GlobalKey _hereMapKey = GlobalKey();
  late TabController _tabController;
  OverlayEntry? _locationWarningOverlay;
  OverlayEntry? _loadCustomSceneResultOverlay;
  ConsentUserReply? _consentState;
  MapMarker? _routeFromMarker;
  Place? _routeFromPlace;
  MapCameraState? _cameraState;
    StreamSubscription? _sub;


  @override
  void initState() {
    super.initState();
      initUniLinks();
    WidgetsBinding.instance.addObserver(this);
       WidgetsBinding.instance.addPostFrameCallback((_) {
      //  Future.delayed(Duration(seconds: 1), () =>  main());
      //  _showRoutingScreen( 
      //             WayPointInfo.withCoordinates(
      //             coordinates:GeoCoordinates(37.7749, -122.4194),
      //           )));
    });
  }
   Future<void> initUniLinks() async {
    // Handle incoming links while the app is in the foreground
    _sub = linkStream.listen((String? link) {
      if (!mounted) return;
      // Handle the link
      print('Received link: $link');
      if(link!=null){
      handleLink(link);
      }
    }, onError: (err) {
      // Handle error
      print('Error receiving link: $err');
    });

    // Handle the initial link if the app is started by a link
    try {
      final initialLink = await getInitialLink();
      // String initialLink = "arcOMDrive-app-ios://LandingScreen/?routeId=cad48ea9-acda-41e9-8ca1-7e8c901fa34e";
      if (initialLink != null) {
        print('Initial link: $initialLink');
        handleLink(initialLink);
        // Navigator.push(context, MaterialPageRoute(builder: (context) => LandingScreen(itemId: itemId)));
      }
    } on PlatformException {
      // Handle exception
      print('Error getting initial link');
    }
  }
    void handleLink(String link) {
    // Parse the link and navigate accordingly
    if (link != null) {
      Uri uri = Uri.parse(link);
        print('Handling link with path: ${link}');
        String routeString = link.substring(44,);
        print('substring: ${routeString}');
        getRouteDetailswithId(routeString);
        // main();
      // if (uri.scheme == 'arcOMDrive-app-ios') {
        // Perform navigation or any other actions based on the link
        // LandingScreen.navRoute: (BuildContext context) => LandingScreen();
        // Navigator.push(context, MaterialPageRoute(builder: (context) => LandingScreen()));
      // }
    }
  }

  Future<void> getRouteDetailswithId(String id) async {
  final queryParameters = {
    'RoutedayId': id,
    'Isliveroute':'true',
  };
    final headers = {
    'tenant':'qa'
  };

  final uri = Uri.https('arcproducts-qa.archarina.com', '/ArcOrderManagement/api/api/v1/order/route/getplannedroutebyid', queryParameters);

  // final uri = Uri.https('arcproducts-qa.archarina.com', '/ArcOrderManagement/api/api/v1/order/route/getplannedroutebyid', queryParameters);
  debugPrint('uri value $uri');
  final response = await http.get(uri, headers: headers);

 if (response.statusCode == 200) {
      // Parse the JSON data
      final data = json.decode(response.body);
      
      // Assuming the response is a list of maps
      if (data is List) {
        for (var item in data) {
          if (item is Map && item.containsKey('destinationaddress')) {
            print('Destination Address: ${item['destinationaddress']}');
              await makeGeocodeApiCall(item['destinationaddress']);
          }
        }
      }
    } else {
      print('Failed to load data: ${response.statusCode}');
    }
  
  }

  @override
  void dispose() {
    stopPositioning();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Stops the location engine when app is detached.
    if (state == AppLifecycleState.detached) {
      // This flag helps us to re-init the positioning when app is resumed.
      _didBackPressedAndPositionStopped = true;
      if (Platform.isAndroid) {
        _cameraState = _hereMapController.camera.state;
      }
      stopPositioning();
    } else if (state == AppLifecycleState.resumed && _didBackPressedAndPositionStopped) {
      _didBackPressedAndPositionStopped = false;
      // Restart the location engine and initiate positioning when the app is resumed.
      _positioningEngine.initLocationEngine(context: context).then((value) {
        initPositioning(context: context, hereMapController: _hereMapController);
      });

      // Rebuilding the HereMap widget when the app is resumed after it was detached via back button
      // this is a workaround to fix the issue of blank PlatformView on Android during app resume
      // Ref: https://github.com/flutter/flutter/issues/148662
      if (Platform.isAndroid) {
        setState(() => _hereMapKey = GlobalKey());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final HereMapOptions options = HereMapOptions()..initialBackgroundColor = Theme.of(context).colorScheme.surface;
    options.renderMode = MapRenderMode.texture;
    return ConnectionStateMonitor(
      mapLoaderController: Provider.of<MapLoaderController>(context, listen: false),
      child: Consumer2<AppPreferences, CustomMapStyleSettings>(
        builder: (context, preferences, customStyleSettings, child) => Scaffold(
          resizeToAvoidBottomInset: false,
          body: 
          Stack(
            children: [
              HereMap(
                key: _hereMapKey,
                options: options,
                onMapCreated: _onMapCreated,
              ),
              //  Text(
              //   'Item ID: $routeIdParam',
              //   style: TextStyle(fontSize: 20),
              // ),
              // _onSearch(context),
              // _buildSearchSection(),
              _buildMenuButton(),
           
              // _onSearch(context)
            ],
          ),
          floatingActionButton: _mapInitSuccess ? _buildFAB(context) : null,
          drawer: _buildDrawer(context, preferences),
          extendBodyBehindAppBar: true,
          onDrawerChanged: (isOpened) => _dismissLocationWarningPopup(),
        ),
      ),
    );
  }

  void _onMapCreated(HereMapController hereMapController) {
    _hereMapController = hereMapController;
    // MapScheme mapScheme = MapScheme.normalDay;
    hereMapController.mapScene.loadSceneForMapScheme(MapScheme.liteDay, (MapError? error) {
      if (error != null) {
        print('Map scene not loaded. MapError: ${error.toString()}');
        return;
      }

      if (_cameraState != null) {
        _hereMapController.camera.lookAtPointWithGeoOrientationAndMeasure(
          _cameraState!.targetCoordinates,
          GeoOrientationUpdate(_cameraState!.orientationAtTarget.bearing, _cameraState!.orientationAtTarget.tilt),
          MapMeasure(MapMeasureKind.distance, _cameraState!.distanceToTargetInMeters),
        );
        _cameraState = null;
      } else {
        hereMapController.camera.lookAtPointWithMeasure(
          Positioning.initPosition,
          MapMeasure(MapMeasureKind.distance, Positioning.initDistanceToEarth),
        );
      }
      _hereMapController.mapScene.enableFeatures({MapFeatures.buildingFootprints: MapFeatureModes.extrudedBuildingsAll});
      _hereMapController.mapScene.enableFeatures({MapFeatures.terrain: MapFeatureModes.terrain3d});
      // hereMapController.setWatermarkLocation(
      //   Anchor2D.withHorizontalAndVertical(-1, 0),
      //   Point2D(
      //     -hereMapController.watermarkSize.width / 2,
      //     -hereMapController.watermarkSize.height / 2,
      //   ),
      // );

      _addGestureListeners();

      _positioningEngine = Provider.of<PositioningEngine>(context, listen: false);
      _positioningEngine.getLocationEngineStatusUpdates.listen(_checkLocationStatus);
      _positioningEngine.initLocationEngine(context: context).then((value) {
        initPositioning(context: context, hereMapController: hereMapController);
        _updateConsentState(_positioningEngine);
      });

      setState(() {
        _mapInitSuccess = true;
      });
    });
  }


 void _onSearch(BuildContext context) async {
    GeoCoordinates currentPosition = _hereMapController.camera.state.targetCoordinates;
           debugPrint('Loggg hereee');
    final SearchResult? result = await showSearchPopup(
      context: context,
      currentPosition: currentPosition,
      hereMapController: _hereMapController,
      hereMapKey: _hereMapKey,
    );
    if (result != null) {
      SearchResult searchResult = result;
      log('Logggg Place: ${searchResult.place}');
      assert(searchResult.place != null);
      _showRoutingScreen(WayPointInfo.withPlace(
        place: searchResult.place,
      ));
    }
  }

 Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomAppBar(
      key: _bottomBarKey,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // _buildNavigationHeader(context, false),
          // _buildPlacesTabs(context),
        ],
      ),
    );
  }

  Widget _buildMenuButton() {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Builder(
        builder: (context) => Padding(
          padding: EdgeInsets.all(UIStyle.contentMarginLarge),
          child: Material(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(UIStyle.popupsBorderRadius),
            elevation: 2,
            child: InkWell(
              child: Padding(
                padding: EdgeInsets.all(UIStyle.contentMarginMedium),
                child: Icon(
                  Icons.menu,
                  color: colorScheme.primary,
                ),
              ),
              onTap: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildUserConsentItems(BuildContext context) {
    PositioningEngine positioningEngine = Provider.of<PositioningEngine>(context, listen: false);
    _consentState = positioningEngine.userConsentState;

    if (_consentState == null) {
      return [];
    }

    ColorScheme colorScheme = Theme.of(context).colorScheme;
    AppLocalizations appLocalizations = AppLocalizations.of(context)!;

    return [
      if (_consentState != ConsentUserReply.granted)
        ListTile(
          title: Text(
            appLocalizations.userConsentDescription,
            style: TextStyle(color: colorScheme.onSecondary),
          ),
        ),
      ListTile(
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.privacy_tip,
              color: _consentState == ConsentUserReply.granted
                  ? UIStyle.acceptedConsentColor
                  : UIStyle.revokedConsentColor,
            ),
          ],
        ),
        title: Text(
          appLocalizations.userConsentTitle,
          style: TextStyle(color: colorScheme.onPrimary),
        ),
        subtitle: _consentState == ConsentUserReply.granted
            ? Text(
                appLocalizations.consentGranted,
                style: TextStyle(color: UIStyle.acceptedConsentColor),
              )
            : Text(
                appLocalizations.consentDenied,
                style: TextStyle(color: UIStyle.revokedConsentColor),
              ),
        trailing: Icon(
          Icons.arrow_forward,
          color: colorScheme.onPrimary,
        ),
        onTap: () {
          Navigator.of(context).pop();
          positioningEngine.requestUserConsent(context)?.then((_) => _updateConsentState(positioningEngine));
        },
      ),
    ];
  }

  void applyCustomStyle(CustomMapStyleSettings customMapStyleSettings, File file) {
    _hereMapController.mapScene.loadSceneFromConfigurationFile(
      file.path,
      (MapError? error) {
        _showLoadCustomSceneResultPopup(error == null);
        if (error != null) {
          print('Custom scene load failed: ${error.toString()}');
        } else {
          customMapStyleSettings.customMapStyleFilepath = file.path;
        }
      },
    );
  }

  Future<void> loadCustomScene(CustomMapStyleSettings customMapStyleSettings) async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result == null) {
      return;
    }
    final File file = File(result.files.single.path!);
    final File? localFile = await FileUtility.createLocalSceneFile(file.path);
    if (localFile != null) {
      applyCustomStyle(customMapStyleSettings, localFile);
    } else {
      customMapStyleSettings.reset();
      FileUtility.deleteScenesDirectory();
      _showLoadCustomSceneResultPopup(false);
    }
  }

  void resetCustomScene(CustomMapStyleSettings customMapStyleSettings) {
    customMapStyleSettings.reset();
    FileUtility.deleteScenesDirectory();
    _hereMapController.mapScene.loadSceneForMapScheme(
      MapScheme.logisticsDay,
      (MapError? error) {
        if (error != null) {
          print('Map scene not loaded. MapError: ${error.toString()}');
        }
      },
    );
  }

  List<Widget> _buildLoadCustomSceneItem(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    CustomMapStyleSettings customMapStyleSettings = Provider.of<CustomMapStyleSettings>(context, listen: false);
    return [
      ListTile(
        onTap: () => loadCustomScene(customMapStyleSettings),
        trailing: customMapStyleSettings.customMapStyleFilepath != null
            ? IconButton(
                icon: Icon(Icons.clear, color: Colors.white),
                onPressed: () => resetCustomScene(customMapStyleSettings),
              )
            : null,
        title: Text(
          appLocalizations.loadCustomScene,
          style: TextStyle(color: themeData.colorScheme.onPrimary),
        ),
        subtitle: customMapStyleSettings.customMapStyleFilepath != null
            ? Text(
                customMapStyleSettings.customMapStyleFilename,
                style: TextStyle(color: themeData.hintColor),
              )
            : null,
      ),
    ];
  }

  Widget _buildDrawer(BuildContext context, AppPreferences preferences) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    AppLocalizations appLocalizations = AppLocalizations.of(context)!;

    return Drawer(
      child: Ink(
        color: colorScheme.primary,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              child: DrawerHeader(
                padding: EdgeInsets.all(UIStyle.contentMarginLarge),
                decoration: BoxDecoration(
                  color: colorScheme.onSecondary,
                ),
                child: Row(
                  children: [
                    // SvgPicture.asset(
                    //   "assets/app_logo.svg",
                    //   width: UIStyle.drawerLogoSize,
                    //   height: UIStyle.drawerLogoSize,
                    // ),
                    SizedBox(
                      width: UIStyle.contentMarginMedium,
                    ),
                    FutureBuilder<PackageInfo>(
                      future: PackageInfo.fromPlatform(),
                      builder: (_, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.done:
                            String title = 'BMobile Navigation';
                            return Expanded(
                              child: Text(
                                title,
                                style: TextStyle(
                                  color: colorScheme.onPrimary,
                                ),
                              ),
                            );
                          default:
                            return const SizedBox();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            ..._buildUserConsentItems(context),
            ListTile(
                leading: Icon(
                  Icons.download_rounded,
                  color: colorScheme.onPrimary,
                ),
                title: Text(
                  appLocalizations.downloadMapsTitle,
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                  ),
                ),
                onTap: () {
                  Navigator.of(context)
                    ..pop()
                    ..pushNamed(DownloadMapsScreen.navRoute);
                }),
            // ..._buildLoadCustomSceneItem(context),
            SwitchListTile(
              title: Text(
                appLocalizations.useMapOfflineSwitch,
                style: TextStyle(
                  color: colorScheme.onPrimary,
                ),
              ),
              value: preferences.useAppOffline,
              onChanged: (newValue) async {
                if (newValue) {
                  MapLoaderController controller = Provider.of<MapLoaderController>(context, listen: false);
                  List<InstalledRegion> installedRegions = [];
                  try {
                    installedRegions = controller.getInstalledRegions();
                  } on MapLoaderExceptionException catch (error) {
                    print(error.error.errorMessage(AppLocalizations.of(context)!));
                  }
                  if (installedRegions.isEmpty) {
                    Navigator.of(context).pop();
                    if (!await Util.showCommonConfirmationDialog(
                      context: context,
                      title: appLocalizations.offlineAppMapsDialogTitle,
                      message: appLocalizations.offlineAppMapsDialogMessage,
                      actionTitle: appLocalizations.downloadMapsTitle,
                    )) {
                      return;
                    }
                    Navigator.of(context).pushNamed(DownloadMapsScreen.navRoute);
                  }
                }
                preferences.useAppOffline = newValue;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!enableMapUpdate)
              ResetLocationButton(
                onPressed: _resetCurrentPosition,
              ),
            Container(
              height: UIStyle.contentMarginMedium,
            ),
            FloatingActionButton(
              child: ClipOval(
                child: Ink(
                  width: UIStyle.bigButtonHeight,
                  height: UIStyle.bigButtonHeight,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        UIStyle.buttonPrimaryColor,
                        UIStyle.buttonSecondaryColor,
                      ],
                    ),
                  ),
                  child: Icon(Icons.search),
                ),
              ),
              onPressed: () => _onSearch(context),
            ),
          ],
        ),
      ],
    );
  }

  void _addGestureListeners() {
    _hereMapController.gestures.panListener = PanListener((state, origin, translation, velocity) {
      if (enableMapUpdate) {
        setState(() => enableMapUpdate = false);
      }
    });

    _hereMapController.gestures.tapListener = TapListener((point) {
      if (_hereMapController.widgetPins.isEmpty) {
        _removeRouteFromMarker();
      }
      _dismissWayPointPopup();
    });

    _hereMapController.gestures.longPressListener = LongPressListener((state, point) {
      if (state == GestureState.begin) {
        _showWayPointPopup(point);
      }
    });
  }

  void _dismissWayPointPopup() {
    if (_hereMapController.widgetPins.isNotEmpty) {
      _hereMapController.widgetPins.first.unpin();
    }
  }

  void _showWayPointPopup(Point2D point) {
    _dismissWayPointPopup();
    GeoCoordinates coordinates =
        _hereMapController.viewToGeoCoordinates(point) ?? _hereMapController.camera.state.targetCoordinates;
      debugPrint('Geocordinate: $GeoCoordinates');
    _hereMapController.pinWidget(
      PlaceActionsPopup(
        coordinates: coordinates,
        hereMapController: _hereMapController,
        onLeftButtonPressed: (place) {
          _dismissWayPointPopup();
          _routeFromPlace = place;
          _addRouteFromPoint(coordinates);
        },
        leftButtonIcon: SvgPicture.asset(
          "assets/depart_marker.svg",
          width: UIStyle.bigIconSize,
          height: UIStyle.bigIconSize,
        ),
        onRightButtonPressed: (place) {
          _dismissWayPointPopup();
          _showRoutingScreen(place != null
              ? WayPointInfo.withPlace(
                  place: place,
                  originalCoordinates:coordinates,
                )
              : WayPointInfo.withCoordinates(
                  coordinates: coordinates,
                ));
        },
        rightButtonIcon: SvgPicture.asset(
          "assets/route.svg",
          colorFilter: ColorFilter.mode(UIStyle.addWayPointPopupForegroundColor, BlendMode.srcIn),
          width: UIStyle.bigIconSize,
          height: UIStyle.bigIconSize,
        ),
      ),
      coordinates,
      anchor: Anchor2D.withHorizontalAndVertical(0.5, 1),
    );
  }

  void _addRouteFromPoint(GeoCoordinates coordinates) {
    if (_routeFromMarker == null) {
      int markerSize = (_hereMapController.pixelScale * UIStyle.searchMarkerSize).round();
      _routeFromMarker = Util.createMarkerWithImagePath(
        coordinates,
        "assets/depart_marker.svg",
        markerSize,
        markerSize,
        drawOrder: UIStyle.waypointsMarkerDrawOrder,
        anchor: Anchor2D.withHorizontalAndVertical(0.5, 1),
      );
      _hereMapController.mapScene.addMapMarker(_routeFromMarker!);
      if (!isLocationEngineStarted) {
        locationVisible = false;
      }
    } else {
      _routeFromMarker!.coordinates = coordinates;
    }
  }

  void _removeRouteFromMarker() {
    if (_routeFromMarker != null) {
      _hereMapController.mapScene.removeMapMarker(_routeFromMarker!);
      _routeFromMarker = null;
      _routeFromPlace = null;
      locationVisible = true;
    }
  }

  void _resetCurrentPosition() {
    GeoCoordinates coordinates = lastKnownLocation != null ? lastKnownLocation!.coordinates : Positioning.initPosition;
    _hereMapController.camera.lookAtPointWithGeoOrientationAndMeasure(
      coordinates,
      GeoOrientationUpdate(double.nan, double.nan),
      MapMeasure(MapMeasureKind.distance, Positioning.initDistanceToEarth),
    );

    setState(() => enableMapUpdate = true);
  }

  void _dismissLocationWarningPopup() {
    _locationWarningOverlay?.remove();
    _locationWarningOverlay = null;
  }

  void _checkLocationStatus(LocationEngineStatus status) {
    if (status == LocationEngineStatus.engineStarted || status == LocationEngineStatus.alreadyStarted) {
      _dismissLocationWarningPopup();
      return;
    }
    // If we manually stopped the [_positioning], then no need to show the
    // warning dialog.
    if (status == LocationEngineStatus.engineStopped && _didBackPressedAndPositionStopped) {
      _dismissLocationWarningPopup();
      return;
    }

    if (_locationWarningOverlay == null) {
      _locationWarningOverlay = OverlayEntry(
        builder: (context) => NoLocationWarning(onPressed: () => _dismissLocationWarningPopup()),
      );

      Overlay.of(context).insert(_locationWarningOverlay!);
      Timer(Duration(seconds: _kLocationWarningDismissPeriod), _dismissLocationWarningPopup);
    }
  }

  void _showLoadCustomSceneResultPopup(bool result) {
    _dismissLoadCustomSceneResultPopup();

    _loadCustomSceneResultOverlay = OverlayEntry(
      builder: (context) => LoadCustomStyleResultPopup(
        loadCustomStyleResult: result,
        onClosePressed: () => _dismissLoadCustomSceneResultPopup(),
      ),
    );

    Overlay.of(context).insert(_loadCustomSceneResultOverlay!);
    Timer(Duration(seconds: _kLoadCustomStyleResultPopupDismissPeriod), _dismissLoadCustomSceneResultPopup);
  }

  void _dismissLoadCustomSceneResultPopup() {
    _loadCustomSceneResultOverlay?.remove();
    _loadCustomSceneResultOverlay = null;
  }

 

  void _showRoutingScreen(WayPointInfo destination) async {
    debugPrint('destination val $destination');
    final GeoCoordinates currentPosition =
        lastKnownLocation != null ? lastKnownLocation!.coordinates : Positioning.initPosition;

    await Navigator.of(context).pushNamed(
      RoutingScreen.navRoute,
      arguments: [
        currentPosition,
        _routeFromMarker != null
            ? _routeFromPlace != null
                ? WayPointInfo.withPlace(
                    place: _routeFromPlace,
                    originalCoordinates: _routeFromMarker!.coordinates,
                  )
                : WayPointInfo.withCoordinates(
                    coordinates: _routeFromMarker!.coordinates,
                  )
            : WayPointInfo(coordinates: currentPosition),
        destination,
      ],
    );

    _routeFromPlace = null;
    _removeRouteFromMarker();
  }

  void _updateConsentState(PositioningEngine positioningEngine) {
    setState(() => _consentState = positioningEngine.userConsentState);
  }

  void main() async {
  String jsonResponse = '''[{
    "routeID": "cad48ea9-acda-41e9-8ca1-7e8c901fa34e",
    "routeDayID": "d1524cbe-cb79-47f9-8df2-34da2067f17e",
    "routeName": "PL 08 07",
    "routeColor": "#117EC3",
    "routeType": null,
    "routeDate": "2024-07-08T00:00:00",
    "routeStatus": "In-Transit",
    "routeInCharge": null,
    "originPointName": "Amazon Warehouse",
    "orginaddress": "47 W 13th St,New York,New York,10011",
    "orginlocationtype": "warehouse",
    "destinationaddress": "47 W 13th St,New York,New York,10011",
    "destinationlocationtype": "warehouse",
    "destinationName": "Amazon Warehouse",
    "routePlannedToStartOn": "2024-07-07T22:48:42.357",
    "destinationDistance": 1000,
    "destinationDuration": 224,
    "destinationId": "f6154090-a70e-4e8b-a26f-679da447ca6f",
    "destinationStopSequenceId": "bcd5ee37-834f-4826-af8e-19d31cd8fbc3",
    "destinationExpectedDeliveryon": "2024-07-07T22:59:44",
    "destinationCompletedOn": null,
    "statusText": "Active",
    "status": true,
    "isActive": true,
    "truck": {
      "trucknum": "Truck1",
      "truckname": "Truck1",
      "trucktypename": "Long Truck"
    },
    "driver": {
      "driverName": "Rico",
      "driverID": null,
      "mobileNumber": "9393999",
      "emailID": "arcplatformdemouser@innospire.com"
    },
    "orders": [],
    "salesOrderReturnProducts": [],
    "inventoryOrders": [],
    "wareHouseAddress": "47 W 13th St,New York,New York,10011",
    "stops": [{
        "id": "06877a96-04f8-4210-a96e-3c47e827c431",
        "sequencedStopID": "06877a96-04f8-4210-a96e-3c47e827c431",
        "routeDayID": null,
        "stopID": "4c3f6b05-8bfa-4a54-b602-a18b28429bf3",
        "stopName": "Arc Corp",
        "type": "customer",
        "sequence": 1,
        "address": "75 3rd Ave,New York,New York,10003",
        "expectedDeliveryOn": "2024-07-08T18:52:33.713",
        "isCompleted": 0,
        "reason": "",
        "sequnceChangeReason": "",
        "comments": "",
        "isPickedUp": null,
        "distance": 1334,
        "duration": 497,
        "completedOn": null,
        "iscancelled": false,
        "isDestination": false,
        "avialbleStartTime": null,
        "avialbleEndTime": null,
        "isPartial": false
    }],
    "routeProducts": [{
        "productID": "1eb6e4c5-7e33-4790-a3db-4058900b867f",
        "warehouseID": "f6154090-a70e-4e8b-a26f-679da447ca6f",
        "loadType": "",
        "productName": "HP Laptop Bag",
        "totaQty": 1,
        "availableQty": 1,
        "requiredQty": 1,
        "soldQty": 0,
        "isLoaded": true,
        "price": 400,
        "producttype": null,
        "warehousename": "Amazon Warehouse",
        "productnumber": "P1028"
    }, {
        "productID": "c806c302-ee5b-4077-9924-98a99c24db07",
        "warehouseID": "f6154090-a70e-4e8b-a26f-679da447ca6f",
        "loadType": "",
        "productName": "LG French Door Refrigerator",
        "totaQty": 1,
        "availableQty": 1,
        "requiredQty": 1,
        "soldQty": 0,
        "isLoaded": true,
        "price": 2000,
        "producttype": "Not Assigned",
        "warehousename": "Amazon Warehouse",
        "productnumber": "P1026"
    }, {
        "productID": "920fa6e5-3e2d-4dad-ad18-b700dee7472b",
        "warehouseID": "f6154090-a70e-4e8b-a26f-679da447ca6f",
        "loadType": "",
        "productName": "Red velvet cake",
        "totaQty": 1,
        "availableQty": 1,
        "requiredQty": 1,
        "soldQty": 0,
        "isLoaded": true,
        "price": 200,
        "producttype": "Not Assigned",
        "warehousename": "Amazon Warehouse",
        "productnumber": "P1057"
    }],
    "routeactualstarton": "2024-07-07T22:48:42.357",
    "totalduration": 0,
    "totaldistance": 0,
    "routecompletedon": null,
    "routeactualendon": null,
    "createdon": "2024-07-07T22:47:47.54",
    "locationtype": null,
    "sodStatus": true,
    "eodStatus": false,
    "routeApproach": "product",
    "invoiceOrders": [],
    "returnOrders": []
  }]''';

  List<dynamic> jsonList = jsonDecode(jsonResponse);
  List<Routes> routes = jsonList.map((json) => Routes.fromJson(json)).toList();

  String routeID = routes[0].routeID;
  debugPrint('Routtteteeeee Id $routeID');

  print(routeID); // Example usage

  // Incase of just a single object
  //  Map<String, dynamic> jsonMap = jsonDecode(jsonResponse);
  // String routeID = jsonMap['routeID'];
  // print(routeID);  // Output: cad48ea9-acda-41e9-8ca1-7e8c901fa34e

  // Make the API call
  await makeGeocodeApiCall(routes[0].destinationAddress);
}
Future<void> makeGeocodeApiCall(String address) async {
  const apiKey = 'dCw0lUcJGmY4HeYhP5rnjotqFnhDYYd205JfMrBmEvU';
  final queryParameters = {
    'q': address,
    'apiKey': apiKey,
  };

  final uri = Uri.https('geocode.search.hereapi.com', '/v1/geocode', queryParameters);
  debugPrint('uri value $uri');
  final response = await http.get(uri);

 if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    final latLng = extractLatLngFromJson(jsonResponse);
    if (latLng != null) {
     double? lat = latLng['lat'];
      double? lng = latLng['lng'];

  if (lat != null && lng != null) {
    var coordinates = GeoCoordinates(lat, lng);
    print(coordinates.latitude); 
    print(coordinates.longitude); 
      _showRoutingScreen( 
                  WayPointInfo.withCoordinates(
                  coordinates:coordinates,
                ));               
  }
    
    } else {
      print('Lat/Lng not found');
    }
  } else {
    print('Failed to get geocode data: ${response.statusCode}');
  }
}
Map<String, double>? extractLatLngFromJson(Map<String, dynamic> json) {
  if (json.containsKey('items') && json['items'] is List && json['items'].isNotEmpty) {
    final firstItem = json['items'][0];
    if (firstItem.containsKey('access') && firstItem['access'] is List && firstItem['access'].isNotEmpty) {
      final accessPoint = firstItem['access'][0];
      return {
        'lat': accessPoint['lat'],
        'lng': accessPoint['lng'],
      };
    }
  }
  return null;
}

}

