
import 'dart:async';
import 'dart:collection';

class HangUpHandle<T> {
  dynamic data;

  HangUpHandle([this.data]) {
    _completer = Completer<T>();
  }

  late Completer<T> _completer;

  Future<T> get whenSuc => _completer.future;

  void suc(T reason) {
    if (!_completer.isCompleted) {
      _completer.complete(reason);
    }
  }

}

class HangUpTask<T> {

  int time = DateTime.now().millisecondsSinceEpoch;
  int timeoutTime ; //秒
  FutureOr<T> Function() timeoutComputation;
  String id;
  HangUpHandle<T> handle;

  HangUpTask.create({
    required this.id,
    required this.handle,
    this.timeoutTime = 3,
    required this.timeoutComputation
  });

}

Queue<HangUpTask> queue = Queue();

Future<T> hangUp<T>(HangUpTask<T> task) {
  queue.add(task);
  return Future.any([
    Future.delayed(Duration(seconds: task.timeoutTime), task.timeoutComputation).then((value) {
      queue.remove(task);
      return value;
    }),
    task.handle.whenSuc.then((value) {
      queue.remove(value);
      return value;
    })
  ]);
}

HangUpTask? findTask(String id) {
  return queue.where((element) => element.id == id).lastOrNull;
}

// void hangupTest() async {
//
//   HangUpTask<String> task = HangUpTask<String>.create('123', HangUpHandle());
//   queue.add(task);
//
//   Future.any([
//     task.handle.whenSuc.then((value) => value),
//     Future.delayed(const Duration(seconds: 3)).then((value) => '错误')
//   ]).then((value) => Log.i('最终处理结果为: $value'));
//
//   Future.delayed(const Duration(seconds: 2)).then((value) {
//     for (var value in queue.where((element) => element.id == '123')) {
//       value.handle.suc('成功');
//     }
//   });
//
// }





