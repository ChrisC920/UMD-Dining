// import 'package:hive/hive.dart';
// import 'package:umd_dining_refactor/features/dining/data/models/dining_model.dart';

// abstract interface class DiningLocalDataSource {
//   void uploadLocalFoods({required List<DiningModel> foods});
//   List<DiningModel> loadFoods();
// }

// class DiningLocalDataSourceImpl implements DiningLocalDataSource {
//   final Box box;
//   DiningLocalDataSourceImpl(this.box);

//   @override
//   List<DiningModel> loadFoods() {
//     List<DiningModel> foods = [];
//     box.read(() {
//       for (int i = 0; i < box.length; i++) {
//         foods.add(DiningModel.fromJson(box.get(i.toString())));
//       }
//     });

//     return foods;
//   }

//   @override
//   void uploadLocalFoods({required List<DiningModel> foods}) {
//     box.clear();

//     box.write(() {
//       for (int i = 0; i < foods.length; i++) {
//         box.put(i.toString(), foods[i].toJson());
//       }
//     });
//   }
// }
