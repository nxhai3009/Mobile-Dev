// lib/main.dart
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Address Demo',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      debugShowCheckedModeBanner: false,
      home: const AddressScreen(),
    );
  }
}

// ========================== MODEL ==========================
class Address {
  String name;
  String phone;
  String province;
  String district;
  String ward;
  String detail;
  double? lat;
  double? lng;

  Address({
    required this.name,
    required this.phone,
    required this.province,
    required this.district,
    required this.ward,
    required this.detail,
    this.lat,
    this.lng,
  });
}

// ========================== DANH SÁCH ĐỊA CHỈ ==========================
class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final List<Address> _addresses = [];

  void _addAddress(Address addr) {
    setState(() {
      _addresses.add(addr);
    });
  }

  void _editAddress(int index, Address addr) {
    setState(() {
      _addresses[index] = addr;
    });
  }

  void _deleteAddress(int index) {
    setState(() {
      _addresses.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Addresses")),
      body: _addresses.isEmpty
          ? const Center(child: Text("No address yet. Add one!"))
          : ListView.builder(
        itemCount: _addresses.length,
        itemBuilder: (context, index) {
          final addr = _addresses[index];
          return Card(
            child: ListTile(
              title: Text("${addr.name} - ${addr.phone}"),
              subtitle: Text(
                "${addr.province}, ${addr.district}, ${addr.ward}\n${addr.detail}\nLat: ${addr.lat ?? 'N/A'}, Lng: ${addr.lng ?? 'N/A'}",
              ),
              isThreeLine: true,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () async {
                      final updatedAddr = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AddAddressPage(address: addr),
                        ),
                      );
                      if (updatedAddr != null) {
                        _editAddress(index, updatedAddr);
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteAddress(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newAddr = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddAddressPage()),
          );
          if (newAddr != null) _addAddress(newAddr);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ========================== FORM THÊM / SỬA ĐỊA CHỈ ==========================
class AddAddressPage extends StatefulWidget {
  final Address? address;
  const AddAddressPage({super.key, this.address});

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _detailController = TextEditingController();

  String? _province;
  String? _district;
  String? _ward;

  double? _lat;
  double? _lng;

  final provinces = {
    "Hà Nội": ["Ba Đình", "Hoàn Kiếm"],
    "Hồ Chí Minh": ["Quận 1", "Quận 3"],
  };

  final wards = {
    "Ba Đình": ["Phúc Xá", "Trúc Bạch"],
    "Hoàn Kiếm": ["Hàng Bạc", "Cửa Đông"],
    "Quận 1": ["Bến Nghé", "Cầu Ông Lãnh"],
    "Quận 3": ["Phường 6", "Phường 7"],
  };

  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      final addr = widget.address!;
      _nameController.text = addr.name;
      _phoneController.text = addr.phone;
      _detailController.text = addr.detail;
      _province = addr.province;
      _district = addr.district;
      _ward = addr.ward;
      _lat = addr.lat;
      _lng = addr.lng;
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final newAddr = Address(
        name: _nameController.text,
        phone: _phoneController.text,
        province: _province!,
        district: _district!,
        ward: _ward!,
        detail: _detailController.text,
        lat: _lat,
        lng: _lng,
      );
      Navigator.pop(context, newAddr);
    }
  }

  void _selectMap() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MapPickerPage()),
    );
    if (result != null) {
      setState(() {
        _lat = result['lat'];
        _lng = result['lng'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.address != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? "Edit Address" : "Add Address")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Recipient Name"),
                validator: (v) =>
                v!.isEmpty ? "Please enter recipient name" : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: "Phone Number"),
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v!.isEmpty) return "Please enter phone number";
                  if (!RegExp(r'^[0-9]{10}$').hasMatch(v)) {
                    return "Phone must be 10 digits";
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Province/City"),
                value: _province,
                items: provinces.keys
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _province = val;
                    _district = null;
                    _ward = null;
                  });
                },
                validator: (v) => v == null ? "Select province" : null,
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "District"),
                value: _district,
                items: (_province != null
                    ? provinces[_province]!
                    : <String>[])
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _district = val;
                    _ward = null;
                  });
                },
                validator: (v) => v == null ? "Select district" : null,
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Ward"),
                value: _ward,
                items: (_district != null ? wards[_district] ?? [] : [])
                    .map((w) => DropdownMenuItem<String>(value: w, child: Text(w)))
                    .toList(),
                onChanged: (val) => setState(() => _ward = val),
                validator: (v) => v == null ? "Select ward" : null,
              ),
              TextFormField(
                controller: _detailController,
                decoration: const InputDecoration(labelText: "Address Details"),
                maxLines: 3,
                validator: (v) =>
                v!.isEmpty ? "Please enter address detail" : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _selectMap,
                    icon: const Icon(Icons.map),
                    label: const Text("Select on Map"),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(_lat == null
                        ? "No location selected"
                        : "Lat: $_lat, Lng: $_lng"),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text(isEdit ? "Update Address" : "Save Address"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ========================== CHỌN VỊ TRÍ BẢN ĐỒ (GIẢ LẬP) ==========================
class MapPickerPage extends StatefulWidget {
  const MapPickerPage({super.key});

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  double _lat = 21.0278;
  double _lng = 105.8342;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Location on Map")),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.grey[300],
              child: const Center(child: Text("Map would be displayed here")),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, {"lat": _lat, "lng": _lng});
                  },
                  child: const Text("Confirm Location"),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
