import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:imts_frontend/providers/attendance_provider.dart';
import 'package:imts_frontend/widgets/custom_button.dart';
import 'package:imts_frontend/widgets/custom_text_field.dart';

class SubmitLogScreen extends StatefulWidget {
  const SubmitLogScreen({super.key});

  @override
  State<SubmitLogScreen> createState() => _SubmitLogScreenState();
}

class _SubmitLogScreenState extends State<SubmitLogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _logController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _timeIn = TimeOfDay.now();
  TimeOfDay _timeOut = TimeOfDay.now();
  PlatformFile? _selectedFile;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isTimeIn) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isTimeIn ? _timeIn : _timeOut,
    );

    if (picked != null) {
      setState(() {
        if (isTimeIn) {
          _timeIn = picked;
        } else {
          _timeOut = picked;
        }
      });
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }

  String _calculateHours() {
    final now = DateTime.now();
    final timeIn =
        DateTime(now.year, now.month, now.day, _timeIn.hour, _timeIn.minute);
    final timeOut =
        DateTime(now.year, now.month, now.day, _timeOut.hour, _timeOut.minute);

    final difference = timeOut.difference(timeIn);
    final hours = difference.inMinutes / 60;

    return hours.toStringAsFixed(2);
  }

  Future<void> _submitLog() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<AttendanceProvider>(context, listen: false);

      final success = await provider.submitDailyLog(
        date: DateFormat('yyyy-MM-dd').format(_selectedDate),
        timeIn:
            '${_timeIn.hour.toString().padLeft(2, '0')}:${_timeIn.minute.toString().padLeft(2, '0')}',
        timeOut:
            '${_timeOut.hour.toString().padLeft(2, '0')}:${_timeOut.minute.toString().padLeft(2, '0')}',
        logText: _logController.text,
        file: _selectedFile,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Log submitted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Submission failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Daily Log'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _selectDate(context),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat('EEEE, MMMM d, yyyy')
                                    .format(_selectedDate),
                                style: const TextStyle(fontSize: 16),
                              ),
                              const Icon(Icons.calendar_today),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Time Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Working Hours',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Time In'),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () => _selectTime(context, true),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _timeIn.format(context),
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const Icon(Icons.access_time),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Time Out'),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () => _selectTime(context, false),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _timeOut.format(context),
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const Icon(Icons.access_time),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Hours:',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            '${_calculateHours()} hours',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Log Description
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Work Description',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: _logController,
                        labelText: 'Describe your work today...',
                        maxLines: 5,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please describe your work';
                          }
                          if (value.length < 10) {
                            return 'Please provide more details (minimum 10 characters)';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // File Attachment
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Attachment (Optional)',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      if (_selectedFile != null)
                        ListTile(
                          leading: const Icon(Icons.attach_file),
                          title: Text(_selectedFile!.name),
                          subtitle: Text(
                              '${(_selectedFile!.size / 1024).toStringAsFixed(2)} KB'),
                          trailing: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              setState(() {
                                _selectedFile = null;
                              });
                            },
                          ),
                        )
                      else
                        OutlinedButton.icon(
                          onPressed: _pickFile,
                          icon: const Icon(Icons.attach_file),
                          label: const Text('Add Attachment'),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Submit Button
              Consumer<AttendanceProvider>(
                builder: (context, provider, child) {
                  return CustomButton(
                    onPressed: provider.isLoading ? null : _submitLog,
                    text: provider.isLoading ? 'Submitting...' : 'Submit Log',
                    icon: Icons.send,
                    fullWidth: true,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
