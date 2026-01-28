import 'package:flutter_riverpod/flutter_riverpod.dart';

// class TodoProvider extends Notifier<List<TodoModel>> {
//   @override
//   build() {
//     return [];
//   }
//
//   void add(TodoModel todo) {
//     // state++;
//     state = [...state, todo];
//   }
//
//   void remove(TodoModel model) {
//     state = state.where((todo) => todo.id != model.id).toList();
//   }
// }
//
// final todoNotifierProvider = NotifierProvider<TodoProvider, List<TodoModel>>(TodoProvider.new);

class TodoModel {
  final String id;
  final String title;
  final String description;

  @override
  String toString() {
    // TODO: implement toString
    return 'TodoModel(id: $id, title: $title, description: $description)';
  }

  TodoModel({required this.id, required this.title, required this.description});
}

class TodoNotifier extends AsyncNotifier<List<TodoModel>> {
  @override
  Future<List<TodoModel>> build() async {
    // Initial load can be done here if needed
    return [TodoModel(id: '1', title: 'Initial Todo', description: 'This is an initial todo item')];
  }

  Future<void> addTodo(TodoModel model) async {
    //     final previous = state.value ?? [];
    //     state = AsyncLoading<List<TodoModel>>()
    //         .copyWithPrevious(state);
    // //hoặc
    // //     state = const AsyncLoading();
    //     await Future.delayed(const Duration(seconds: 1));
    //     state = AsyncData([...previous, model]);
    try {
      // ignore: invalid_use_of_internal_member
      state = AsyncLoading<List<TodoModel>>().copyWithPrevious(state);
      await Future.delayed(const Duration(seconds: 1));
      final previous = state.value ?? [];
      // var dd = future;
      // state = await AsyncValue.guard(() async {
      //   // Logic gọi API để update ở đây
      //   return dd;
      // },  (err) => err is! FormatException,);
      state = AsyncData([...previous, model]);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  removeTodo(TodoModel model) {
    final previous = state.value ?? [];
    state = AsyncData(previous.where((todo) => todo.id != model.id).toList());
  }
}

final todoProvider = AsyncNotifierProvider<TodoNotifier, List<TodoModel>>(TodoNotifier.new);

class AddTodoNotifier extends AsyncNotifier<List<TodoModel>> {
  @override
  Future<List<TodoModel>> build() async {
    // Initial load can be done here if needed
    return [];
  }

  Future<void> addTodo(TodoModel model) async {
    try {
      state = AsyncLoading<List<TodoModel>>().copyWithPrevious(state);
      await Future.delayed(const Duration(seconds: 1));
      final previous = state.value ?? [];
      // state = AsyncData([...previous, model]);
      ref.invalidate(todoProvider);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  removeTodo(TodoModel model) {
    final previous = state.value ?? [];
    state = AsyncData(previous.where((todo) => todo.id != model.id).toList());
  }
}

final addTodoProvider = AsyncNotifierProvider<AddTodoNotifier, List<TodoModel>>(
  AddTodoNotifier.new,
);
