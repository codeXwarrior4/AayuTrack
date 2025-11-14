// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/services.dart';
import '../theme.dart';

/// Re-uses the SafeLottie widget pattern to avoid crashes if an animation is missing.
/// For simplicity this file copies a minimal SafeLottie; if you imported the other file,
/// you can instead import that widget. For single-file pasting we include a small helper.

class _SafeLottieInline extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;
  const _SafeLottieInline({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
  });

  Future<bool> _exists() async {
    try {
      await rootBundle.loadString(assetPath);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _exists(),
      builder: (c, s) {
        if (s.hasData && s.data == true) {
          return SizedBox(
            width: width ?? 180,
            height: height ?? 140,
            child: Image.asset(assetPath, fit: BoxFit.contain),
          );
        }
        return Container(
          height: height ?? 140,
          decoration: BoxDecoration(
            color: kTeal.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: Icon(Icons.person, size: 56, color: kTeal)),
        );
      },
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Box _box = Hive.box('aayutrack_box');
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _name = TextEditingController();
  final TextEditingController _age = TextEditingController();
  final TextEditingController _gender = TextEditingController();
  final TextEditingController _blood = TextEditingController();
  final TextEditingController _abha = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _contact = TextEditingController();
  final TextEditingController _allergies = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    final Map data = _box.get('profile', defaultValue: {});
    _name.text = (data['name'] ?? '').toString();
    _age.text = (data['age'] ?? '').toString();
    _gender.text = (data['gender'] ?? '').toString();
    _blood.text = (data['blood'] ?? '').toString();
    _abha.text = (data['abha'] ?? '').toString();
    _address.text = (data['address'] ?? '').toString();
    _contact.text = (data['contact'] ?? '').toString();
    _allergies.text = (data['allergies'] ?? '').toString();
    setState(() {});
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final data = {
      'name': _name.text.trim(),
      'age': _age.text.trim(),
      'gender': _gender.text.trim(),
      'blood': _blood.text.trim(),
      'abha': _abha.text.trim(),
      'address': _address.text.trim(),
      'contact': _contact.text.trim(),
      'allergies': _allergies.text.trim(),
    };
    await _box.put('profile', data);
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() => _saving = false);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile saved')));
    }
  }

  Widget _field(
    TextEditingController c,
    String label,
    IconData icon, {
    String? hint,
    bool req = false,
    TextInputType? keyboard,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: c,
        keyboardType: keyboard ?? TextInputType.text,
        validator: (v) =>
            req && (v == null || v.trim().isEmpty) ? 'Required' : null,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 8),
                const SizedBox(height: 8),
                const _SafeLottieInline(
                  assetPath: 'assets/animations/profile.json',
                  width: 180,
                  height: 140,
                ),
                const SizedBox(height: 12),
                Text(
                  'Personal & Government Info',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: kTeal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _field(_name, 'Full name', Icons.person, req: true),
                _field(_age, 'Age', Icons.cake, keyboard: TextInputType.number),
                _field(_gender, 'Gender', Icons.wc),
                _field(_blood, 'Blood group', Icons.bloodtype),
                _field(_abha, 'ABHA ID / Govt ID', Icons.badge),
                _field(_address, 'Full address', Icons.home),
                _field(
                  _contact,
                  'Emergency contact',
                  Icons.phone,
                  keyboard: TextInputType.phone,
                ),
                _field(
                  _allergies,
                  'Allergies (comma separated)',
                  Icons.warning,
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(_saving ? 'Saving...' : 'Save profile'),
                  onPressed: _saving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(45),
                  ),
                ),
                const SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
