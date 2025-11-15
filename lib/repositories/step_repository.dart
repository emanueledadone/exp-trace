import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';

class StepRepository {
  Future<Database> get db async => await DatabaseHelper.instance.database;

  Future<int> insertOrUpdateSteps(DateTime date, int stepCount) async {
    final database = await db;
    String formattedDate = date.toIso8601String().split('T')[0];

    final existingRecord = await database.query(
      'steps',
      where: 'date = ?',
      whereArgs: [formattedDate],
    );

    if (existingRecord.isEmpty) {
      // Nuovo giorno: crea record iniziale
      await database.insert('steps', {
        'date': formattedDate,
        'step_count': 0,
        'previous_step_count': stepCount, // Punto di riferimento per oggi
      });
      return 0;
    }

    int previousStepCount = existingRecord.first['previous_step_count'] as int;
    int dailySteps = stepCount - previousStepCount;

    if (dailySteps < 0) {
      dailySteps = dailySteps.abs(); // fallback, evitare negativi
    }

    await database.update(
      'steps',
      {'step_count': dailySteps, 'previous_step_count': stepCount},
      where: 'date = ?',
      whereArgs: [formattedDate],
    );

    return dailySteps;
  }

  Future<void> clearAllSteps() async {
    final database = await db;
    await database.delete('steps');
  }
}
