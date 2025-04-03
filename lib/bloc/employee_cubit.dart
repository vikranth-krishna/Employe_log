import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/employee_model.dart';
import '../services/db_helper.dart';
import 'employee_state.dart';

class EmployeeCubit extends Cubit<EmployeeState> {
  final DBHelper _dbHelper;
  EmployeeCubit(this._dbHelper) : super(EmployeeState());

  Future<void> fetchEmployees() async {
    emit(state.copyWith(loading: true));
    final employees = await _dbHelper.getAllEmployees();
    emit(state.copyWith(employees: employees, loading: false));
  }

  Future<void> addEmployee(Employee employee) async {
    await _dbHelper.insertEmployee(employee);
    fetchEmployees();
  }

  Future<void> updateEmployee(Employee employee) async {
    await _dbHelper.updateEmployee(employee);
    fetchEmployees();
  }

  Future<void> deleteEmployee(int id) async {
    await _dbHelper.deleteEmployee(id);
    fetchEmployees();
  }
}
