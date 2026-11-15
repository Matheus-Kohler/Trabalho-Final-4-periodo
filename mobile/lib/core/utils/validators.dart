abstract class AppValidators {
  static String? requiredField(String? value, [String fieldName = 'Campo']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName é obrigatório.';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'E-mail é obrigatório.';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Informe um e-mail válido.';
    }
    return null;
  }

  static String? minLength(String? value, int min, [String fieldName = 'Campo']) {
    if (value == null || value.trim().length < min) {
      return '$fieldName deve conter pelo menos $min caracteres.';
    }
    return null;
  }

  static String? integerNumber(String? value, [String fieldName = 'Valor']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName é obrigatório.';
    }
    final parsed = int.tryParse(value.trim());
    if (parsed == null) {
      return '$fieldName deve ser um número inteiro válido.';
    }
    return null;
  }

  static String? positiveNumber(String? value, [String fieldName = 'Valor']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName é obrigatório.';
    }
    final parsed = double.tryParse(value.trim().replaceAll(',', '.'));
    if (parsed == null || parsed < 0) {
      return '$fieldName deve ser um número positivo.';
    }
    return null;
  }
}
