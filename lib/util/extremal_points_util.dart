
import 'package:flutter/widgets.dart';

class ExtremalPointsUtil {

  static Offset findMinXMaxY(List<Offset> points){
    return Offset(
      _findMinX(points),
      _findMaxY(points)
    );
  }

  static double _findMinX(List<Offset> points){
    return _findMinNum(
      points
      .map( (point) => point.dx )
      .toList()
    );
  }

  static double _findMaxY(List<Offset> points){
    return _findMaxNum(
      points
      .map( (point) => point.dy )
      .toList()
    );
  }

  static double _findMinNum(List<double> nums){
    return _findExtremal(
      nums: nums,
      compareFn: ( A, B ) => A < B
    );
  }

  static double _findMaxNum(List<double> nums){
    return _findExtremal(
      nums: nums,
      compareFn: ( A, B ) => A > B
    );
  }

  static double _findExtremal({
    required List<double> nums,
    // if this function returns true, then [A] will
    // be taken as the next extremal element
    required bool Function( double A, double B ) compareFn
  }){
    double currentExtremal = nums[0];
    for (int i = 1; i < nums.length; i++){
      var next = nums[i];
      if (compareFn( next, currentExtremal )){
        currentExtremal = next;
      }
    }
    return currentExtremal;
  }

}
