abstract class FormModalPayload {
  Map<String, dynamic> toJson();
}

enum FormType { id, name, categoryId }

class FormModal extends FormModalPayload {
  final String? formId;
  final String? categoryId;
  final String? formName;
  final FormType formType;

  FormModal({
    this.formId,
    this.categoryId,
    this.formName,
    required this.formType,
  });

  @override
  Map<String, dynamic> toJson() {
    switch (formType) {
      case FormType.id:
        return {
          "data": {'formId': formId, 'type': "ID"},
        };
      case FormType.name:
        return {
          "data": {'name': formName, 'type': "NAME"},
        };
      case FormType.categoryId:
        return {
          "data": {'categoryId': categoryId, 'type': "CATEGORY_ID"},
        };
    }
  }
}
