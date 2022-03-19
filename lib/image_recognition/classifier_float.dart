import 'package:blossom/image_recognition/classifier.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

class ClassifierFloat extends Classifier {
  ClassifierFloat({int? numThreads}) : super(numThreads: numThreads);

  @override
  // String get modelName => 'model/flower_model.tflite';
  String get modelName => 'model/flower_model_2.tflite';

  @override
  // NormalizeOp get preProcessNormalizeOp => NormalizeOp(0, 255);
  NormalizeOp get preProcessNormalizeOp => NormalizeOp(0, 1);

  @override
  NormalizeOp get postProcessNormalizeOp => NormalizeOp(0, 1);
}
