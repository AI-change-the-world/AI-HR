import 'package:flutter/material.dart';
import 'package:salary_report/src/services/global_analysis_models.dart';

class EmployeeChangesComponent extends StatelessWidget {
  final List<MinimalEmployeeInfo> newEmployees;
  final List<MinimalEmployeeInfo> resignedEmployees;

  const EmployeeChangesComponent({
    super.key,
    required this.newEmployees,
    required this.resignedEmployees,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '人员变动情况',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (newEmployees.isNotEmpty) ...[
              const Text(
                '新入职员工',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: newEmployees.map((employee) {
                  return Chip(
                    label: Text('${employee.name} (${employee.department})'),
                    backgroundColor: Colors.green.withValues(alpha: 0.2),
                    labelStyle: const TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
            ],
            if (resignedEmployees.isNotEmpty) ...[
              const Text(
                '离职员工',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: resignedEmployees.map((employee) {
                  return Chip(
                    label: Text('${employee.name} (${employee.department})'),
                    backgroundColor: Colors.red.withValues(alpha: 0.2),
                    labelStyle: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  );
                }).toList(),
              ),
            ],
            if (newEmployees.isEmpty && resignedEmployees.isEmpty) ...[
              const Text(
                '本期无人员变动',
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
