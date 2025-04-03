import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/calendar_popup.dart';
import '../bloc/employee_cubit.dart';
import '../models/employee_model.dart';

class EditEmployeeScreen extends StatefulWidget {
  final Employee employee;
  const EditEmployeeScreen({Key? key, required this.employee})
      : super(key: key);

  @override
  _EditEmployeeScreenState createState() => _EditEmployeeScreenState();
}

class _EditEmployeeScreenState extends State<EditEmployeeScreen> {
  final TextEditingController _nameController = TextEditingController();
  String? _selectedRole;
  final List<String> _roles = [
    'Product Designer',
    'Flutter Developer',
    'QA Tester',
    'Product Owner'
  ];

  DateTime? _selectedDateForToday;
  DateTime? _selectedDateForNoDate;

  Widget _buildPopupActionButton({
    required String label,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 73,
      height: 40,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6)),
          padding: EdgeInsets.zero,
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: textColor,
          ),
        ),
      ),
    );
  }

  void _showCalendarPopupForToday() async {
    final selectedDate = await showDialog<DateTime>(
      context: context,
      barrierDismissible: true,
      builder: (context) => CalendarPopup(
        initialDate: _selectedDateForToday ?? DateTime.now(),
        limitedQuickOptions: false,
      ),
    );
    if (selectedDate != null) {
      setState(() {
        _selectedDateForToday = selectedDate;
      });
    }
  }

  void _showCalendarPopupForNoDate() async {
    final selectedDate = await showDialog<DateTime?>(
      context: context,
      barrierDismissible: true,
      builder: (context) => CalendarPopup(
        initialDate: _selectedDateForNoDate ?? DateTime.now(),
        limitedQuickOptions: true,
      ),
    );
    setState(() {
      _selectedDateForNoDate = selectedDate;
    });
  }

  String _formatDate(DateTime? date, String defaultText) {
    return date != null ? DateFormat('d MMM yyyy').format(date) : defaultText;
  }

  Future<void> _updateEmployee() async {
    if (_nameController.text.trim().isEmpty || _selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please provide a name and select a role')),
      );
      return;
    }

    final updatedEmployee = Employee(
      id: widget.employee.id,
      name: _nameController.text.trim(),
      role: _selectedRole!,
      startDate: _selectedDateForToday,
      endDate: _selectedDateForNoDate,
      isDeleted: widget.employee.isDeleted,
    );

    await context.read<EmployeeCubit>().updateEmployee(updatedEmployee);
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.employee.name;
    _selectedRole = widget.employee.role;
    _selectedDateForToday = widget.employee.startDate;
    _selectedDateForNoDate = widget.employee.endDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double appBarFontSize = screenWidth < 600 ? 18 : 24;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1DA1F2),
        title: Text(
          'Edit Employee Details',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w500,
            fontSize: appBarFontSize,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Employee Name field.
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Employee Name',
                hintStyle: const TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: Colors.grey,
                ),
                prefixIcon:
                const Icon(Icons.person, color: Color(0xFF1DA1F2)),
                contentPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                border: OutlineInputBorder(
                  borderSide: const BorderSide(
                      color: Color(0xFFE5E5E5), width: 1.0),
                  borderRadius: BorderRadius.circular(4),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                      color: Color(0xFFE5E5E5), width: 1.0),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Role selection field.
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  barrierColor: const Color(0x66000000),
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  backgroundColor: const Color(0xFFF2F2F2),
                  builder: (BuildContext context) {
                    return Container(
                      padding: const EdgeInsets.only(top: 16, bottom: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: _roles.map((role) {
                          int index = _roles.indexOf(role);
                          return Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16),
                                child: ListTile(
                                  title: Text(
                                    role,
                                    style: const TextStyle(
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _selectedRole = role;
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                              if (index != _roles.length - 1)
                                const Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Color(0xFFF2F2F2),
                                ),
                            ],
                          );
                        }).toList(),
                      ),
                    );
                  },
                );
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  hintText: 'Select role',
                  hintStyle: const TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  prefixIcon: const Icon(Icons.work_outline,
                      color: Color(0xFF1DA1F2)),
                  suffixIcon: const Icon(Icons.arrow_drop_down,
                      color: Color(0xFF1DA1F2)),
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(
                        color: Color(0xFFE5E5E5), width: 1.0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                        color: Color(0xFFE5E5E5), width: 1.0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: Text(
                  _selectedRole ?? 'Select role',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color:
                    _selectedRole == null ? Colors.grey : Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Row with two date fields and a blue arrow between.
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _showCalendarPopupForToday,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        hintText: _formatDate(_selectedDateForToday, 'Today'),
                        hintStyle: const TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                        prefixIcon: const Icon(Icons.calendar_today,
                            color: Color(0xFF1DA1F2)),
                        contentPadding:
                        const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 12),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Color(0xFFE5E5E5), width: 1.0),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Color(0xFFE5E5E5), width: 1.0),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: Text(
                        _formatDate(_selectedDateForToday, 'Today'),
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(
                    Icons.arrow_forward,
                    color: Color(0xFF1DA1F2),
                    size: 24,
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: _showCalendarPopupForNoDate,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        hintText: _formatDate(_selectedDateForNoDate, 'No Date'),
                        hintStyle: const TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                        prefixIcon: const Icon(Icons.calendar_today,
                            color: Color(0xFF1DA1F2)),
                        contentPadding:
                        const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 12),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Color(0xFFE5E5E5), width: 1.0),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Color(0xFFE5E5E5), width: 1.0),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: Text(
                        _formatDate(_selectedDateForNoDate, 'No Date'),
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildPopupActionButton(
                label: 'Cancel',
                backgroundColor: const Color(0xFFEDF8FF),
                textColor: const Color(0xFF1DA1F2),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(width: 8),
              _buildPopupActionButton(
                label: 'Save',
                backgroundColor: const Color(0xFF1DA1F2),
                textColor: Colors.white,
                onPressed: _updateEmployee,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
