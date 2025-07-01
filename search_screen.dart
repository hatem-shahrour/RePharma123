import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _results = [];
  bool _loading = false;
  String? _error;

  Future<void> _searchMedicines(String query) async {
    if (query.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await http.get(Uri.parse('${apiBaseUrl}/search?query=$query'));
      if (response.statusCode == 200) {
        setState(() {
          _results = json.decode(response.body);
        });
      } else {
        setState(() {
          _error = 'Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to connect to API.';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _showMedicineDetails(Map<String, dynamic> medicine) async {
    // Fetch alternatives
    List<dynamic> alternatives = [];
    try {
      final response = await http.get(Uri.parse('${apiBaseUrl}/alternatives/${Uri.encodeComponent(medicine['activeIngredient'])}'));
      if (response.statusCode == 200) {
        alternatives = json.decode(response.body);
      }
    } catch (_) {}

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(medicine['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Active Ingredient: ${medicine['activeIngredient']}'),
              Text('Concentration: ${medicine['concentration']}'),
              Text('Dosage Form: ${medicine['dosageForm']}'),
              Text('Manufacturer: ${medicine['manufacturer']}'),
              Text('Price: ${medicine['price']} EGP'),
              const SizedBox(height: 8),
              Text('Side Effects:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(medicine['sideEffects']),
              const SizedBox(height: 8),
              Text('Alternatives:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...alternatives.where((alt) => alt['name'] != medicine['name']).map<Widget>((alt) => Text(alt['name'])).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Medicines'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(8),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Search by name or active ingredient...',
                  prefixIcon: const Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onSubmitted: _searchMedicines,
                textInputAction: TextInputAction.search,
              ),
            ),
            const SizedBox(height: 16),
            if (_loading) const CircularProgressIndicator(),
            if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
            if (!_loading && _results.isNotEmpty)
              Expanded(
                child: ListView.separated(
                  itemCount: _results.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final medicine = _results[index];
                    return ListTile(
                      title: Text(medicine['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Active Ingredient: ${medicine['activeIngredient']}'),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                        onPressed: () => _showMedicineDetails(medicine),
                        child: const Text('Details'),
                      ),
                    );
                  },
                ),
              ),
            if (!_loading && _results.isEmpty && _controller.text.isNotEmpty)
              const Text('No medicines found.'),
          ],
        ),
      ),
    );
  }
} 