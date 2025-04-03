import '../models/employee_model.dart';

class EmployeeState {
  final List<Employee> employees;
  final bool loading;

  EmployeeState({this.employees = const [], this.loading = false});

  EmployeeState copyWith({
    List<Employee>? employees,
    bool? loading,
  }) {
    return EmployeeState(
      employees: employees ?? this.employees,
      loading: loading ?? this.loading,
    );
  }
}
