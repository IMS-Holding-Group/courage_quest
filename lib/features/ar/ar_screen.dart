import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math_64.dart';

import '../../app_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/services/ar_service.dart';
import '../../widgets/bottom_nav_bar.dart';

class ArScreen extends StatefulWidget {
  const ArScreen({super.key});

  @override
  State<ArScreen> createState() => _ArScreenState();
}

class _ArScreenState extends State<ArScreen> {
  ARSessionManager? _session;
  ARNode? _node;
  Timer? _timer;
  double _t = 0;

  @override
  void dispose() {
    _timer?.cancel();
    _session?.dispose();
    super.dispose();
  }

  void _onCreated(
    ARSessionManager session,
    ARObjectManager objects,
    ARAnchorManager anchors,
    ARLocationManager loc,
  ) {
    _session = session;
    objects.onInitialize();
    final u = context.read<CourageQuestState>().user;
    final ocd = u?.ocdType ?? 'Contamination OCD';
    final node = ArService.buildArchieNode(ocdType: ocd);
    _node = node;
    objects.addNode(node);
    _timer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      _t += 0.05;
      final n = _node;
      if (n == null) return;
      if (ocd.contains('Contamination')) {
        final y = -0.05 + 0.08 * math.sin(_t);
        n.position = Vector3(0, y, -0.35);
      } else {
        n.eulerAngles = Vector3(0, 0, 0.25 * math.sin(_t));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!(Platform.isAndroid || Platform.isIOS)) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: Scaffold(
          appBar: AppBar(title: Text('Augmented reality', style: AppTextStyles.pageTitle.copyWith(color: AppColors.white)), backgroundColor: AppColors.darkGreen),
          body: Center(child: Text('AR is available on Android and iPhone devices.', style: AppTextStyles.bodyText, textAlign: TextAlign.center)),
        ),
      );
    }
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ARView(
                    onARViewCreated: _onCreated,
                    planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
                    permissionPromptDescription: 'Camera access is needed to show augmented reality',
                    permissionPromptButtonText: 'Allow',
                    permissionPromptParentalRestriction: 'Camera is restricted on this device',
                  ),
                  Positioned(
                    top: 48,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(12)),
                      child: Text('See? It’s not so scary.', style: AppTextStyles.bodyText, textAlign: TextAlign.center),
                    ),
                  ),
                ],
              ),
            ),
            BottomNavBar(
              currentIndex: 0,
              onTap: (i) {
                if (i == 1) Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
                if (i == 2) Navigator.pushNamed(context, '/profile');
              },
            ),
          ],
        ),
      ),
    );
  }
}
