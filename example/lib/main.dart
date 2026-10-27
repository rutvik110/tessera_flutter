import 'package:flutter/material.dart';
import 'package:tessera_flutter/tessera_flutter.dart';

const _sample =
    'Jordan Avery, Project Coordinator\n'
    'Acme Corporation\n'
    '500 Main St, Springfield, IL 62701\n'
    '+1 202-555-0199\n'
    'jordan@acme.example';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final tessera = await Tessera.open();
  runApp(TesseraDemo(tessera: tessera));
}

class TesseraDemo extends StatefulWidget {
  const TesseraDemo({super.key, required this.tessera});

  final Tessera tessera;

  @override
  State<TesseraDemo> createState() => _TesseraDemoState();
}

class _TesseraDemoState extends State<TesseraDemo> {
  final _controller = TextEditingController(text: _sample);
  var _busy = false;
  var _output = 'Detect, group contacts, or parse the text as one address.';

  @override
  void dispose() {
    _controller.dispose();
    widget.tessera.dispose();
    super.dispose();
  }

  Future<void> _run(_Job job) async {
    setState(() => _busy = true);
    try {
      final text = _controller.text;
      final output = switch (job) {
        _Job.detect => _formatEntities(await widget.tessera.detect(text)),
        _Job.contacts => _formatContacts(await widget.tessera.extractContacts(text)),
        _Job.address => _formatEntities([
          await widget.tessera.parseAddress(text),
        ]),
      };
      if (mounted) setState(() => _output = output);
    } catch (error) {
      if (mounted) setState(() => _output = '$error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Tessera')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _controller,
                minLines: 5,
                maxLines: 8,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Text',
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  FilledButton(
                    onPressed: _busy ? null : () => _run(_Job.detect),
                    child: const Text('Detect'),
                  ),
                  FilledButton(
                    onPressed: _busy ? null : () => _run(_Job.contacts),
                    child: const Text('Contacts'),
                  ),
                  FilledButton(
                    onPressed: _busy ? null : () => _run(_Job.address),
                    child: const Text('Parse address'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: SelectableText(_busy ? 'Reading…' : _output),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _Job { detect, contacts, address }

String _formatEntities(List<TextEntity> entities) {
  if (entities.isEmpty) return 'Nothing found.';
  return entities.map(_formatEntity).join('\n');
}

String _formatEntity(TextEntity entity) {
  final normalized = entity.normalized == null ? '' : ' → ${entity.normalized}';
  final components = entity.components
      .map((component) => '    ${component.label.name}: ${component.text}')
      .join('\n');
  final body = components.isEmpty ? '' : '\n$components';
  return '${entity.kind.name}  ${entity.text}$normalized$body';
}

String _formatContacts(ContactExtraction extraction) {
  final contacts = extraction.contacts.map((contact) {
    final lines = <String>[
      if (contact.person != null) 'person: ${contact.person!.text}',
      if (contact.org != null) 'org: ${contact.org!.text}',
      for (final address in contact.addresses) 'address: ${address.text}',
      for (final email in contact.emails) 'email: ${email.text}',
      for (final phone in contact.phones) 'phone: ${phone.text}',
    ];
    return lines.join('\n');
  });
  final unassigned = extraction.unassigned.map(
    (entity) => 'unassigned ${entity.kind.name}: ${entity.text}',
  );
  final blocks = [...contacts, ...unassigned];
  if (blocks.isEmpty) return 'Nothing found.';
  return blocks.join('\n\n');
}
