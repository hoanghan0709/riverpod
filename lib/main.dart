import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod2/todo_provider.dart';

void main() {
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _MyHomePageState();
  }

  // @override
  // State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  late final ProviderSubscription _sub;

  @override
  void initState() {
    super.initState();
    // _sub = ref.listenManual(todoNotifierProvider, (prev, next) {
    //   // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OK')));
    //
    //   // _sub.close();
    // });

    // _sub = ref.listenManual(todoProvider, (prev, next) {
    //   next.whenOrNull(
    //     data: (_) {
    //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Done')));
    //       // _sub.close();
    //     },
    //   );
    // });

    _sub = ref.listenManual<AsyncValue<List<TodoModel>>>(todoProvider, (prev, next) {
      next.whenOrNull(
        data: (d) {
          print('listenManual data: $d');
          if (d.isEmpty) {
            return;
          }
          // if(prev?.isLoading??false)return;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Done')));
          // _sub.close();
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // ref.listen(todoProvider, (prev, next) {
    //   // if (next.showSuccessToast &&
    //   //     !(prev?.showSuccessToast ?? false)) {
    //   //   ScaffoldMessenger.of(context).showSnackBar(
    //   //     const SnackBar(content: Text('Thành công')),
    //   //   );
    //   // ref.read(todoNotifierProvider.notifier).resetToast();
    //   // }
    // });
    // final todos = ref.watch(todoNotifierProvider);
    final todoAsync = ref.watch(todoProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Stack(
          children: [
            // ===== CONTENT =====
            todoAsync.when(
              data:
                  (todos) => Column(
                    children: [
                      TextField(
                        controller: _titleController,
                        onSubmitted: (d) {
                          if (_titleController.text.isEmpty) return;
                          ref
                              .read(addTodoProvider.notifier)
                              .addTodo(
                                TodoModel(
                                  id: '${DateTime.now()}',
                                  title: _titleController.text,
                                  description: 'description',
                                ),
                              );
                          _titleController.clear();
                          // print('list :${ref.read(todoNotifierProvider)}');
                          final todos = ref.read(todoProvider);
                          print('list1 :${todos.value}');
                        },
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: todos.length,
                          itemBuilder:
                              (_, i) => ListTile(
                                onTap: () {
                                  ref.read(todoProvider.notifier).removeTodo(todos[i]);
                                },
                                title: Text(todos[i].title),
                                subtitle: Text(todos[i].description),
                              ),
                        ),
                      ),
                    ],
                  ),
              error: (e, _) => Center(child: Text('$e')),
              loading: () => const SizedBox(), // không dùng
            ),

            // ===== BLUR LOADING =====
            if (todoAsync.isLoading)
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(),
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: () {
              if (_titleController.text.isEmpty) return;
              ref
                  .read(todoProvider.notifier)
                  .addTodo(
                    TodoModel(
                      id: '${DateTime.now()}',
                      title: _titleController.text,
                      description: 'description',
                    ),
                  );
              _titleController.clear();
              // print('list :${ref.read(todoNotifierProvider)}');
              final todos = ref.read(todoProvider);
              print('list :${todos.value}');
            },
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
          // FloatingActionButton(
          //   onPressed: () {
          //     // ref.read(todoNotifierProvider.notifier).remove();
          //   },
          //   tooltip: 'remove',
          //   child: const Icon(Icons.add),
          // ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  //   @override
  //   Widget build(BuildContext context) {
  //     return Scaffold(
  //       appBar: AppBar(
  //         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
  //         title: Text(widget.title),
  //       ),
  //       body: Center(
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: <Widget>[
  //             const Text('You have pushed the button this many times:'),
  //             Text('$_counter', style: Theme.of(context).textTheme.headlineMedium),
  //           ],
  //         ),
  //       ),
  //       floatingActionButton: FloatingActionButton(
  //         onPressed: _incrementCounter,
  //         tooltip: 'Increment',
  //         child: const Icon(Icons.add),
  //       ), // This trailing comma makes auto-formatting nicer for build methods.
  //     );
  //   }
  // }
}

class GlobalListen extends ConsumerWidget {
  final Widget child;
  const GlobalListen({super.key, required this.child});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listenManual(todoProvider, (previous, next) {
      if (!next.isLoading && next.hasError) {
        // Hiển thị SnackBar bất kể đang ở màn hình nào
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi hệ thống: ${next.error}'), backgroundColor: Colors.redAccent),
        );
      }
    });
    return child;
  }
}
