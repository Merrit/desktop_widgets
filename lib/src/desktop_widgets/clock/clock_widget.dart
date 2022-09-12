import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

extension on DateTime {
  String basicDate() => DateFormat('EEEE, MMMM d').format(this);

  String basicTime() => DateFormat('h:mm a').format(this);
}

class ClockCubit extends Cubit<ClockState> {
  ClockCubit()
      : super(ClockState(
          date: DateTime.now().basicDate(),
          time: DateTime.now().basicTime(),
        )) {
    timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      emit(ClockState(
        date: DateTime.now().basicDate(),
        time: DateTime.now().basicTime(),
      ));
    });
  }

  Timer? timer;

  @override
  Future<void> close() {
    timer?.cancel();
    return super.close();
  }
}

class ClockState extends Equatable {
  final String date;
  final String time;

  const ClockState({
    required this.date,
    required this.time,
  });

  @override
  List<Object> get props => [date, time];
}

class NewClockWidget extends StatelessWidget {
  const NewClockWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ClockCubit(),
      child: Builder(builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              BlocBuilder<ClockCubit, ClockState>(
                builder: (context, state) {
                  return Text(
                    state.time,
                    style: TextStyle(
                      fontSize: 50,
                      color: Colors.grey[300],
                    ),
                  );
                },
              ),
              BlocBuilder<ClockCubit, ClockState>(
                builder: (context, state) {
                  return Text(
                    state.date,
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.grey[300],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      }),
    );
  }
}

// class ClockWidget extends StatefulWidget {
//   const ClockWidget({
//     Key? key,
//   }) : super(key: key);

//   @override
//   State<ClockWidget> createState() => _ClockWidgetState();
// }

// class _ClockWidgetState extends State<ClockWidget> {
//   Timer? timer;

//   @override
//   void initState() {
//     timer = Timer.periodic(const Duration(minutes: 1), (timer) {
//       setState(() => _dateTime = DateTime.now());
//     });

//     super.initState();
//   }

//   @override
//   void dispose() {
//     timer?.cancel();
//     super.dispose();
//   }

//   DateTime _dateTime = DateTime.now();

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Text(
//           DateFormat('h:mm a').format(_dateTime),
//           style: TextStyle(
//             fontSize: 50,
//             color: Colors.grey[300],
//           ),
//         ),
//         Text(
//           DateFormat('EEEE, MMMM d').format(_dateTime),
//           style: TextStyle(
//             fontSize: 17,
//             color: Colors.grey[300],
//           ),
//         ),
//       ],
//     );
//   }
// }
