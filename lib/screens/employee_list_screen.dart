import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/employee_cubit.dart';
import '../bloc/employee_state.dart';
import '../models/employee_model.dart';
import 'edit_employee_screen.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({Key? key}) : super(key: key);

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  // Shows a SnackBar with an Undo option when deleting a current employee.
  void _deleteCurrentEmployee(BuildContext context, Employee employee) async {
    final employeeCubit = context.read<EmployeeCubit>();
    final updatedEmployee = Employee(
      id: employee.id,
      name: employee.name,
      role: employee.role,
      startDate: employee.startDate,
      endDate: employee.endDate,
      isDeleted: true,
    );
    await employeeCubit.updateEmployee(updatedEmployee);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Employee data has been deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            final revertedEmployee = Employee(
              id: employee.id,
              name: employee.name,
              role: employee.role,
              startDate: employee.startDate,
              endDate: employee.endDate,
              isDeleted: false,
            );
            await employeeCubit.updateEmployee(revertedEmployee);
          },
        ),
      ),
    );
  }

  // Helper: Format date range.
  String _formatDateRange(DateTime? start, DateTime? end) {
    final startStr = start != null ? _formatDate(start) : '';
    final endStr = end != null ? _formatDate(end) : '';
    if (startStr.isEmpty && endStr.isEmpty) return '';
    if (startStr.isNotEmpty && endStr.isNotEmpty) {
      return 'From $startStr - $endStr';
    } else if (startStr.isNotEmpty) {
      return 'From $startStr';
    } else {
      return 'Until $endStr';
    }
  }

  // Helper: Format a single date.
  String _formatDate(DateTime date) {
    final day = date.day;
    final year = date.year;
    final monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final monthName = monthNames[date.month - 1];
    return '$day $monthName, $year';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1DA1F2),
        title: const Text('Employee List'),
      ),
      body: BlocBuilder<EmployeeCubit, EmployeeState>(
        builder: (context, state) {
          final employees = state.employees;
          final currentEmployees =
          employees.where((emp) => !emp.isDeleted).toList();
          final previousEmployees =
          employees.where((emp) => emp.isDeleted).toList();

          return employees.isEmpty
              ? Center(
            child: LayoutBuilder(builder: (context, constraints) {
              return ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth * 0.8,
                  maxHeight: constraints.maxHeight * 0.8,
                ),
                child: Image.asset(
                  'assets/images/notfound.png',
                  fit: BoxFit.contain,
                ),
              );
            }),
          )
              : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current Employees Heading.
                  Container(
                    width: double.infinity,
                    height: 40,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.zero,
                    child: const Text(
                      'Current Employees',
                      style: TextStyle(
                        color: Color(0xFF1DA1F2),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  // Fixed-size container for current employees list.
                  Container(
                    color: Colors.white,
                    height: 260,
                    margin: EdgeInsets.zero,
                    child: currentEmployees.isNotEmpty
                        ? ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: currentEmployees.length,
                      itemBuilder: (context, index) {
                        final employee =
                        currentEmployees[index];
                        return GestureDetector(
                          onTap: () {
                            // Navigate to Edit screen.
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditEmployeeScreen(
                                        employee: employee),
                              ),
                            ).then((_) {
                              context
                                  .read<EmployeeCubit>()
                                  .fetchEmployees();
                            });
                          },
                          child: Dismissible(
                            key: ValueKey(employee.id),
                            direction:
                            DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red,
                              alignment:
                              Alignment.centerRight,
                              padding: const EdgeInsets.only(
                                  right: 20),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            onDismissed: (direction) {
                              _deleteCurrentEmployee(
                                  context, employee);
                            },
                            child: ListTile(
                              tileColor: Colors.white,
                              title: Text(
                                employee.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(employee.role),
                                  if (employee.startDate != null ||
                                      employee.endDate != null)
                                    Text(_formatDateRange(
                                        employee.startDate,
                                        employee.endDate)),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    )
                        : const Center(
                      child: Text('No Current Employees',
                          style: TextStyle(
                              color: Colors.grey)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Previous Employees Heading.
                  Container(
                    width: double.infinity,
                    height: 40,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.zero,
                    child: const Text(
                      'Previous Employees',
                      style: TextStyle(
                        color: Color(0xFF1DA1F2),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  // Fixed-size container for previous employees list.
                  Container(
                    color: Colors.white,
                    height: 260,
                    margin: EdgeInsets.zero,
                    child: previousEmployees.isNotEmpty
                        ? ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: previousEmployees.length,
                      itemBuilder: (context, index) {
                        final employee =
                        previousEmployees[index];
                        return ListTile(
                          tileColor: Colors.white,
                          title: Text(
                            employee.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(employee.role),
                              if (employee.startDate != null ||
                                  employee.endDate != null)
                                Text(_formatDateRange(
                                    employee.startDate,
                                    employee.endDate)),
                            ],
                          ),
                        );
                      },
                    )
                        : const Center(
                      child: Text('No Previous Employees',
                          style: TextStyle(
                              color: Colors.grey)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      // Bottom bar with "Swipe left to delete" on left and FAB on right.
      bottomNavigationBar: BlocBuilder<EmployeeCubit, EmployeeState>(
        builder: (context, state) {
          return state.employees.isEmpty
              ? const SizedBox.shrink()
              : Container(
            color: Colors.transparent,
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Swipe left to delete',
                  style:
                  TextStyle(fontSize: 14, color: Colors.grey),
                ),
                FloatingActionButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/add')
                        .then((_) {
                      context
                          .read<EmployeeCubit>()
                          .fetchEmployees();
                    });
                  },
                  backgroundColor:
                  const Color(0xFF1DA1F2),
                  child: const Icon(Icons.add,
                      color: Colors.white),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: BlocBuilder<EmployeeCubit, EmployeeState>(
        builder: (context, state) {
          return state.employees.isEmpty
              ? FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, '/add')
                  .then((_) {
                context
                    .read<EmployeeCubit>()
                    .fetchEmployees();
              });
            },
            backgroundColor:
            const Color(0xFF1DA1F2),
            child:
            const Icon(Icons.add, color: Colors.white),
          )
              : const SizedBox.shrink();
        },
      ),
    );
  }
}
