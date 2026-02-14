class DraftModal {
  final String formId;
  final bool? accepted;
  final bool isDraft;
  final String description;
  final Map<String, dynamic> location;
  final List<Map<String, dynamic>> compliantsList;
  final List<Map<String, dynamic>> attachments;
  final bool? isAnonymous;
  final int? step;
  final bool? isAiSuggested;
  final Map<String, dynamic> additionalFields;

  DraftModal({
    required this.formId,
    this.accepted = true,
    required this.isDraft,
    required this.description,
    required this.location,
    required this.compliantsList,
    required this.attachments,
    this.isAnonymous = false,
    this.step = 3,
    this.isAiSuggested = false,
    required this.additionalFields,
  });

  Map<String, dynamic> toJson() {
    return {
      'data': {
        'consentDetails': {'formId': formId, 'accepted': accepted},
        'draft': isDraft,
        'description': description,
        'location': location,
        'complainants': compliantsList,
        'attachments': attachments,
        'isAnonymous': isAnonymous,
        'step': step,
        'isAiSuggested': isAiSuggested,
        'additionalFields': additionalFields,
      },
    };
  }
}
