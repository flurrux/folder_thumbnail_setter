import 'package:flutter/material.dart';

class StateBuilder<S> extends StatefulWidget {

  const StateBuilder({
    super.key,
    required this.makeInitialState,
    required this.builder,
  });

  final S Function() makeInitialState;
  final Widget Function(S state, void Function(S) setState) builder;

  @override
  State<StateBuilder<S>> createState() {
    return _StateBuilderState();
  }
}

class _StateBuilderState<S> extends State<StateBuilder<S>> {
  
  late S _currentState;
  
  @override
  void initState() {
    super.initState();
    _currentState = widget.makeInitialState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      _currentState,
      _setState,
    );
  }

  void _setState(S newState){
    setState(() {
      _currentState = newState;
    });
  }
}
