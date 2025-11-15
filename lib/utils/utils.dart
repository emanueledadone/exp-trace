import 'package:math_expressions/math_expressions.dart';

double evalExpression(String expression) {
  try {
    GrammarParser p = GrammarParser();
    Expression exp = p.parse(expression);
    ContextModel cm = ContextModel();
    return exp.evaluate(EvaluationType.REAL, cm);
  } catch (e) {
    return double.nan;
  }
}

int getDaysInMonth(DateTime date) {
  DateTime firstDayOfNextMonth = DateTime(date.year, date.month + 1, 0);
  return firstDayOfNextMonth.day;
}
