import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DiabetesPage extends StatefulWidget {
  const DiabetesPage({super.key});

  @override
  State<DiabetesPage> createState() => _DiabetesPageState();
}

class _DiabetesPageState extends State<DiabetesPage> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _patients = [];
  int? _selectedPatientId;

  List<double> _glucoseRecords = [];

  final String baseUrl = "http://10.0.2.2/api"; // ajuste se estiver usando servidor real

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  // -------------------------------
  // BUSCAR PACIENTES DA API
  // -------------------------------
  Future<void> _loadPatients() async {
    final url = Uri.parse("$baseUrl/get_all_patients.php");

    final res = await http.get(url);
    final data = json.decode(res.body);

    if (data["status"] == true) {
      setState(() {
        _patients = data["patients"];
      });
    }
  }

  // -------------------------------
  // BUSCAR REGISTROS DE GLICOSE
  // -------------------------------
  Future<void> _loadGlucose() async {
    if (_selectedPatientId == null) return;

    final url = Uri.parse("$baseUrl/get_glucose.php?patient_id=$_selectedPatientId");
    final res = await http.get(url);
    final data = json.decode(res.body);

    if (data["status"] == true) {
      setState(() {
        _glucoseRecords = (data["records"] as List)
            .map((e) => double.parse(e["glucose_value"].toString()))
            .toList();
      });
    }
  }

  // -------------------------------
  // ADICIONAR NOVO REGISTRO
  // -------------------------------
  void _addGlucoseDialog() {
    if (_selectedPatientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecione um paciente primeiro")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Adicionar glicose"),
          content: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Glicose (mg/dL)",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _controller.clear();
                Navigator.pop(context);
              },
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                final value = double.tryParse(_controller.text.replaceAll(",", "."));
                if (value != null) {
                  await _saveGlucose(value);
                  _controller.clear();
                  Navigator.pop(context);
                }
              },
              child: const Text("Salvar"),
            )
          ],
        );
      },
    );
  }

  // -------------------------------
  // SALVAR NA API
  // -------------------------------
  Future<void> _saveGlucose(double value) async {
    final url = Uri.parse("$baseUrl/save_glucose.php");

    final res = await http.post(url, body: {
      "patient_id": _selectedPatientId.toString(),
      "glucose_value": value.toString(),
    });

    final data = json.decode(res.body);
    if (data["status"] == true) {
      _loadGlucose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final List<FlSpot> spots =
        List.generate(_glucoseRecords.length, (i) => FlSpot(i.toDouble(), _glucoseRecords[i]));

    return Scaffold(
      appBar: AppBar(title: const Text("Diabetes")),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addGlucoseDialog,
        icon: const Icon(Icons.add),
        label: const Text("Adicionar glicose"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // -------------------------------
          // DROPDOWN DE PACIENTES
          // -------------------------------
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: "Selecione o paciente",
                  border: OutlineInputBorder(),
                ),
                value: _selectedPatientId,
                items: _patients.map((p) {
                  return DropdownMenuItem(
                    value: int.parse(p["patient_id"].toString()),
                    child: Text(p["name"]),
                  );
                }).toList(),
                onChanged: (id) {
                  setState(() => _selectedPatientId = id);
                  _loadGlucose();
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          // -------------------------------
          // GRÁFICO
          // -------------------------------
          if (_glucoseRecords.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  height: 220,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true),
                      titlesData: FlTitlesData(),
                      lineBarsData: [
                        LineChartBarData(
                          isCurved: true,
                          color: scheme.primary,
                          barWidth: 3,
                          spots: spots,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          const SizedBox(height: 16),

          // -------------------------------
          // LISTA DOS REGISTROS
          // -------------------------------
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: _glucoseRecords.isEmpty
                  ? const Center(
                      child: Text("Nenhum registro"),
                    )
                  : Column(
                      children: List.generate(_glucoseRecords.length, (i) {
                        return ListTile(
                          leading: const Icon(Icons.bloodtype, color: Colors.red),
                          title: Text("${_glucoseRecords[i].toStringAsFixed(0)} mg/dL"),
                        );
                      }),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
