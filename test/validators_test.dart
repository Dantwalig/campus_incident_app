import 'package:campus_incident_app/core/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators.aluEmail', () {
    test('accepts ALU student and staff emails', () {
      expect(Validators.aluEmail('jane@alustudent.com'), isNull);
      expect(Validators.aluEmail('prof@alueducation.com'), isNull);
    });

    test('rejects other domains and bad formats', () {
      expect(Validators.aluEmail('jane@gmail.com'), isNotNull);
      expect(Validators.aluEmail('not an email'), isNotNull);
      expect(Validators.aluEmail(''), isNotNull);
    });
  });

  group('Validators.password', () {
    test('requires length and a digit', () {
      expect(Validators.password('short1'), isNotNull);
      expect(Validators.password('longpassword'), isNotNull);
      expect(Validators.password('longpass1'), isNull);
    });
  });

  test('confirmPassword must match', () {
    expect(Validators.confirmPassword('abc12345', 'abc12345'), isNull);
    expect(Validators.confirmPassword('other', 'abc12345'), isNotNull);
  });

  test('minLength trims whitespace', () {
    expect(Validators.minLength('  a ', 3, 'Title'), isNotNull);
    expect(Validators.minLength('abc', 3, 'Title'), isNull);
  });
}
