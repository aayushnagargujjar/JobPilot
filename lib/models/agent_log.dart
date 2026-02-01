import 'dart:math';
import 'package:intl/intl.dart';

class AgentLog {
  final String id;
  final String timestamp;
  final String agent;
  final String message;
  final String type; // INFO, SUCCESS, WARNING, ERROR

  AgentLog(this.agent, this.message, this.type)
      : id = Random().nextInt(100000).toString(),
        timestamp = DateFormat('h:mm:ss a').format(DateTime.now());
}