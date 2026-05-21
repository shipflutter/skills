import 'package:flutter/material.dart';

import 'score_calculator.dart';
import 'score_result.dart';

class ScoreForm extends StatefulWidget {
  const ScoreForm({super.key});

  @override
  State<ScoreForm> createState() => _ScoreFormState();
}

class _ScoreFormState extends State<ScoreForm> {
  final _countController = TextEditingController(text: '12');
  final _multiplierController = TextEditingController(text: '8');
  final _discountController = TextEditingController(text: '10');
  late ScoreResult _result;

  @override
  void initState() {
    super.initState();
    _result = _calculate();
  }

  @override
  void dispose() {
    _countController.dispose();
    _multiplierController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  void _updateResult() {
    setState(() {
      _result = _calculate();
    });
  }

  ScoreResult _calculate() {
    return calculateScore(
      count: int.tryParse(_countController.text) ?? 0,
      multiplier: int.tryParse(_multiplierController.text) ?? 0,
      discountPercent: int.tryParse(_discountController.text) ?? 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Test Skills POC')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Deterministic score calculator',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text(
            'Edit the inputs and calculate a stable score for unit, integration, screenshot, and coverage demos.',
          ),
          const SizedBox(height: 16),
          _NumberField(
            key: const Key('count-field'),
            label: 'Item count',
            controller: _countController,
          ),
          const SizedBox(height: 12),
          _NumberField(
            key: const Key('multiplier-field'),
            label: 'Multiplier',
            controller: _multiplierController,
          ),
          const SizedBox(height: 12),
          _NumberField(
            key: const Key('discount-field'),
            label: 'Discount percent',
            controller: _discountController,
          ),
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('calculate-button'),
            onPressed: _updateResult,
            child: const Text('Calculate'),
          ),
          const SizedBox(height: 16),
          _ResultCard(result: _result),
        ],
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    super.key,
    required this.label,
    required this.controller,
  });

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: label,
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});

  final ScoreResult result;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Result', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            _ResultRow(
              label: 'Subtotal',
              value: result.subtotal.toString(),
              valueKey: const Key('subtotal-value'),
            ),
            _ResultRow(
              label: 'Discount',
              value: formatMoney(result.discount),
              valueKey: const Key('discount-value'),
            ),
            _ResultRow(
              label: 'Total',
              value: formatMoney(result.total),
              valueKey: const Key('total-value'),
            ),
            _ResultRow(
              label: 'Rating',
              value: result.rating,
              valueKey: const Key('rating-value'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.label,
    required this.value,
    required this.valueKey,
  });

  final String label;
  final String value;
  final Key valueKey;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(key: valueKey, value),
        ],
      ),
    );
  }
}
