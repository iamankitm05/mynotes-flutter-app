import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_services.dart';
import 'package:mynotes/views/login_view.dart';
import 'package:mynotes/views/notes/create_update_note_view.dart';
import 'package:mynotes/views/notes/notes_view.dart';
import 'package:mynotes/views/registration_view.dart';
import 'package:mynotes/views/verify_email_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'My Notes',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const HomePage(),
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegistrationView(),
        verifyEmailRoute: (context) => const VerifyEmailView(),
        notesRoute: (context) => const NotesView(),
        createOrUpdateNoteRoute: (context) => const CreateUpdateNoteView(),
      },
    ),
  );
}

// class HomePage extends StatelessWidget {
//   const HomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       future: AuthService.firebase().initialize(),
//       builder: (context, snapshot) {
//         switch (snapshot.connectionState) {
//           case ConnectionState.done:
//             final user = AuthService.firebase().currentUser;
//             if(user != null) {
//               if(user.isEmailVerified) {
//                 return const NotesView();
//               } else {
//                 return const VerifyEmailView();
//               }
//             } else {
//               return const LoginView();
//             }
//           default:
//             return const Center(child: CircularProgressIndicator());
//         }
//       },
//     );
//   }
// }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CounterBloc(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepPurple,
          title: const Text(
            'Testing Bloc',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        body: BlocConsumer<CounterBloc, CounterState>(
          listener: ((context, state) {
            _controller.clear();
          }),
          builder: (context, state) {
            final invalidValue =
                (state is CounterStateInvalidNumber) ? state.invalidValue : '';

            return Column(
              children: [
                Text("Current Value is ${state.value}"),
                Visibility(
                  child: Text("Invalid input: $invalidValue"),
                  visible: state is CounterStateInvalidNumber,
                ),
                TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: "Enter a number here",
                  ),
                  keyboardType: TextInputType.number,
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: Text('-'),
                    ),
                    TextButton(
                      onPressed: () {
                        context
                            .read<CounterBloc>()
                            .add(IncrementEvent(_controller.text));
                      },
                      child: Text('+'),
                    ),
                  ],
                )
              ],
            );
          },
        ),
      ),
    );
  }
}

@immutable
abstract class CounterState {
  final int value;
  const CounterState(this.value);
}

class CounterStateValid extends CounterState {
  const CounterStateValid(int value) : super(value);
}

class CounterStateInvalidNumber extends CounterState {
  final String invalidValue;
  const CounterStateInvalidNumber({
    required this.invalidValue,
    required int previousValue,
  }) : super(previousValue);
}

@immutable
abstract class CounterEvent {
  final String value;
  const CounterEvent(this.value);
}

class IncrementEvent extends CounterEvent {
  const IncrementEvent(String value) : super(value);
}

class DecrementEvent extends CounterEvent {
  const DecrementEvent(String value) : super(value);
}

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(const CounterStateValid(0)) {
    on<IncrementEvent>(((event, emit) {
      final integer = int.tryParse(event.value);
      if (integer == null) {
        emit(CounterStateInvalidNumber(
          invalidValue: event.value,
          previousValue: state.value,
        ));
      } else {
        emit(CounterStateValid(state.value + integer));
      }
    }));
    on<DecrementEvent>(((event, emit) {
      final integer = int.tryParse(event.value);
      if (integer == null) {
        emit(CounterStateInvalidNumber(
          invalidValue: event.value,
          previousValue: state.value,
        ));
      } else {
        emit(CounterStateValid(state.value - integer));
      }
    }));
  }
}
