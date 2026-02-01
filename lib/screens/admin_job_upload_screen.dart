import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job_model.dart';

class AdminUploadScreen extends StatefulWidget {
  const AdminUploadScreen({super.key});

  @override
  State<AdminUploadScreen> createState() => _AdminUploadScreenState();
}

class _AdminUploadScreenState extends State<AdminUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Controllers for text fields
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _expController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();

  bool _visaRequired = false;
  bool _isLoading = false;

  Future<void> _uploadJob() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        JobModel newJob = JobModel(
          jobId: _idController.text.trim(),
          company: _companyController.text.trim(),
          role: _roleController.text.trim(),
          location: _locationController.text.trim(),
          jobType: _typeController.text.trim(),
          visaRequired: _visaRequired,
          startDate: _startController.text.trim(),
          experienceLevel: _expController.text.trim(),
          skillsRequired: _skillsController.text.split(',').map((e) => e.trim()).toList(),
          description: _descController.text.trim(),
          applyEndpoint: _linkController.text.trim(),
        );

        await _firestore.collection('jobs').doc(newJob.jobId).set(newJob.toMap());

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Job Uploaded Successfully!")),
          );
          _formKey.currentState!.reset();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hello Admin")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Upload Job #51", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              _buildTextField(_idController, "Job ID (Unique)"),
              _buildTextField(_companyController, "Company Name"),
              _buildTextField(_roleController, "Job Role"),
              _buildTextField(_locationController, "Location"),
              _buildTextField(_typeController, "Job Type (e.g. Remote/Full-time)"),
              _buildTextField(_startController, "Start Date"),
              _buildTextField(_expController, "Experience Level"),
              _buildTextField(_skillsController, "Skills (Comma separated: Java, Flutter)"),
              _buildTextField(_descController, "Description", maxLines: 3),
              _buildTextField(_linkController, "Apply Endpoint (URL)"),

              SwitchListTile(
                title: const Text("Visa Sponsorship Required?"),
                value: _visaRequired,
                onChanged: (val) => setState(() => _visaRequired = val),
              ),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _uploadJob,
                  child: const Text("Submit Job Entry"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        validator: (value) => value!.isEmpty ? "Field cannot be empty" : null,
      ),
    );
  }
}