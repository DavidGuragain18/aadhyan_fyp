import 'course_review_model.dart';

extension CourseRemarkExtensions on List<CourseRemarkModel> {
  double get ratingAverage {
    if (isEmpty) return 0.0;
    final total = fold<int>(0, (sum, remark) => sum + remark.rating);
    return total / length;
  }
}
