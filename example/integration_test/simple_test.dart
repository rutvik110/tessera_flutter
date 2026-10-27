import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tessera_flutter/tessera_flutter.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const sample =
      'Jordan Avery, Project Coordinator\n'
      'Acme Corporation\n'
      '500 Main St, Springfield, IL 62701\n'
      '+1 202-555-0199\n'
      'jordan@acme.example';

  test('detects email and phone and parses an address', () async {
    final tessera = await Tessera.open();
    addTearDown(tessera.dispose);

    final entities = await tessera.detect(sample);
    final email = entities.singleWhere(
      (entity) => entity.kind == EntityKind.email,
    );
    expect(email.text, 'jordan@acme.example');
    expect(sample.substring(email.start, email.end), email.text);

    final phone = entities.singleWhere(
      (entity) => entity.kind == EntityKind.phone,
    );
    expect(phone.normalized, '+12025550199');

    final contacts = await tessera.extractContacts(sample);
    expect(contacts.contacts.length + contacts.unassigned.length, greaterThan(0));

    final address = await tessera.parseAddress(
      '400 Broad St, Seattle, WA 98109',
    );
    expect(
      address.components.map((component) => component.text),
      containsAll(['Broad St', 'Seattle', 'WA', '98109']),
    );
  });
}
