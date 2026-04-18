import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddEventPage extends StatefulWidget {
  const AddEventPage({super.key});

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController eventName = TextEditingController();
  final TextEditingController eventDate = TextEditingController();
  final TextEditingController expiryDate = TextEditingController();
  final TextEditingController startTime = TextEditingController();
  final TextEditingController endTime = TextEditingController();
  final TextEditingController eventLocation = TextEditingController();
  final TextEditingController description = TextEditingController();
  final TextEditingController phone = TextEditingController();

  String? selectedImage;
  String status = 'Active';

  final List<String> imageAssets = [
    'assets/img1.jpg',
    'assets/img2.jpeg',
    'assets/img3.jpg',

  ];

  @override
  void dispose() {
    eventName.dispose();
    eventDate.dispose();
    expiryDate.dispose();
    startTime.dispose();
    endTime.dispose();
    eventLocation.dispose();
    description.dispose();
    phone.dispose();
    super.dispose();
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        controller.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _selectTime(TextEditingController controller) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        controller.text = pickedTime.format(context);
      });
    }
  }

  void clearForm() {
    eventName.clear();
    eventDate.clear();
    expiryDate.clear();
    startTime.clear();
    endTime.clear();
    eventLocation.clear();
    description.clear();
    phone.clear();
    setState(() {
      selectedImage = null;
      status = 'Active';
    });
  }

  void addEvent() async {
  if (_formKey.currentState!.validate()) {
    try {
      final date = DateTime.parse(eventDate.text);

      final startParts = startTime.text.split(':');
      final startHour = int.parse(startParts[0]);
      final startMinute = int.parse(startParts[1].split(' ')[0]);
      final isStartPM = startTime.text.toLowerCase().contains('pm');
      final startTime24 = TimeOfDay(hour: isStartPM && startHour != 12 ? startHour + 12 : startHour, minute: startMinute);

      final endParts = endTime.text.split(':');
      final endHour = int.parse(endParts[0]);
      final endMinute = int.parse(endParts[1].split(' ')[0]);
      final isEndPM = endTime.text.toLowerCase().contains('pm');
      final endTime24 = TimeOfDay(hour: isEndPM && endHour != 12 ? endHour + 12 : endHour, minute: endMinute);

      final DateTime startDateTime = DateTime(date.year, date.month, date.day, startTime24.hour, startTime24.minute);
      final DateTime endDateTime = DateTime(date.year, date.month, date.day, endTime24.hour, endTime24.minute);

      DateTime expiry = DateTime.parse(expiryDate.text);
      String statusValue = DateTime.now().isAfter(expiry) ? 'Passed' : 'Active';

      await FirebaseFirestore.instance.collection('events').add({
        'name': eventName.text,
        'date': eventDate.text,
        'expiryDate': expiryDate.text,
        'startTime': Timestamp.fromDate(startDateTime),
        'endTime': Timestamp.fromDate(endDateTime),
        'location': eventLocation.text,
        'description': description.text,
        'phone': phone.text,
        'image': selectedImage ?? '',
        'status': statusValue,
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event added successfully')),
      );

      clearForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding event: $e')),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) { 
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Event',
          style: TextStyle(
            fontSize: 25, 
            fontFamily: 'Sans-serif',
            color: Colors.white, 
            fontWeight: FontWeight.bold
            ),
            ),
        backgroundColor: Color.fromARGB(255, 181, 17, 6),
         iconTheme: const IconThemeData(
        color: Colors.white, // Set the back arrow color 
      ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(300, 16, 300, 16),
        child: Card(
          elevation: 5,
          color: const Color.fromARGB(255, 255, 245, 238),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            ),
          child: Padding(///Form Details
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Text('Event Details',
                    style: TextStyle(
                      fontSize: 30, 
                      fontWeight: FontWeight.bold, 
                      color: Color.fromARGB(255, 201, 5, 5),
                      ),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(eventName, 'Event Name',maxLines: 2),
                  _buildDateField(eventDate, 'Event Date', Icons.calendar_today),
                  _buildDateField(expiryDate, 'Expiry Date', Icons.event_busy),
                  _buildTimeField(startTime, 'Start Time', Icons.access_time),
                  _buildTimeField(endTime, 'End Time', Icons.access_time),
                  _buildTextField(eventLocation, 'Event Location'),
                  _buildTextField(phone, 'Phone Number', inputType: TextInputType.phone),
                  _buildTextField(description, 'Description', maxLines: 3),
                  //IMAGE
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedImage,
                    decoration: const InputDecoration(labelText: 'Select Image',
                    labelStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)
                    ), // Label color
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0), width: 2),
                      ),
                    ),
                    items: imageAssets.map((image) {
                      return DropdownMenuItem(
                        value: image,
                        child: Text(image.split('/').last),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedImage = value;
                      });
                    },
                    validator: (val) => val == null ? 'Please select an image' : null,
                  ),

                  //BUTTONS
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: addEvent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 201, 5, 5),
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                        ),
                        icon: const Icon(Icons.add,
                          color: Colors.white,
                          size: 25,
                        ),
                        label: const Text('Add Event',
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.bold,
                            color:Colors.white
                            ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: clearForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 201, 5, 5),
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                        ),
                        icon: const Icon(Icons.clear,
                          color: Colors.white,
                          size: 25,
                        ),
                        label: const Text('Clear',
                        style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.bold,
                            color:Colors.white
                        ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  //TEXT FIELD
  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType inputType = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)), // Label color
          border: const OutlineInputBorder(),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0), width: 2),
          ),
        ),
        keyboardType: inputType,
        maxLines: maxLines,
        validator: (val) => val == null || val.isEmpty ? 'Enter $label'.toLowerCase() : null,
      ),
    );
  }

  //DATE FIELD
  Widget _buildDateField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)), // Label color
          suffixIcon: Icon(icon),
          border: const OutlineInputBorder(),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0), width: 2),
          ),
        ),
        readOnly: true,
        onTap: () => _selectDate(controller),
        validator: (val) => val == null || val.isEmpty ? 'Enter $label'.toLowerCase() : null,
      ),
    );
  }

  //TIME FIELD
  Widget _buildTimeField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)), // Label color
          suffixIcon: Icon(icon),
          border: const OutlineInputBorder(),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0), width: 2),
          ),
        ),
        readOnly: true,
        onTap: () => _selectTime(controller),
        validator: (val) => val == null || val.isEmpty ? 'Enter $label'.toLowerCase() : null,
      ),
    );
  }
}
