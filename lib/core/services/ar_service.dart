import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:vector_math/vector_math_64.dart';

class ArService {
  static const String archieModelGlbUrl =
      'https://github.com/KhronosGroup/glTF-Sample-Models/raw/master/2.0/Duck/glTF-Binary/Duck.glb';

  static ARNode buildArchieNode({required String ocdType}) {
    final baseScale = Vector3(0.18, 0.18, 0.18);
    final pos = Vector3(0.0, -0.05, -0.35);
    if (ocdType.contains('Contamination')) {
      return ARNode(
        type: NodeType.webGLB,
        uri: archieModelGlbUrl,
        scale: baseScale,
        position: pos,
        rotation: Vector4(0, 1, 0, 0.2),
      );
    }
    return ARNode(
      type: NodeType.webGLB,
      uri: archieModelGlbUrl,
      scale: baseScale,
      position: pos,
      rotation: Vector4(0, 1, 0, -0.35),
    );
  }
}
