class ColumnName {
  static const String date = "Date";
  static const String fromTime = "FromTime";
  static const String toTime = "ToTime";
  static const String planed = "Planed";
  static const String recorded = "Recorded";
  static const String subject = "Subject";
  static const String subjectAcronym = "SubjectAcronym";
  static const String subjectId = "SubjectId";
  static const String workTypeId = "WorkTypeId";
  static const String workType = "WorkType";
  static const String seriesId = "SeriesId";
  static const String series = "Series";
  static const String seriesFromDate = "SeriesFromDate";
  static const String seriesToDate = "SeriesToDate";
  static const String noteId = "NoteId";
  static const String note = "Note";
}

class DataValues {
  static const List<String> subjectNames = [
    "0_Mo",
    "1_Tu",
    "2_We",
    "3_Th",
    "4_Fr",
    "5_Sa",
    "6_Su"
  ];

  static const double _maxPlanedTime = 5.0;
  static const List<double> planedTime = [
    _maxPlanedTime,
    _maxPlanedTime,
    _maxPlanedTime,
    _maxPlanedTime,
    _maxPlanedTime,
    _maxPlanedTime,
    _maxPlanedTime,
    _maxPlanedTime
  ];
  static const List<double> recordedTime = [
    _maxPlanedTime * 0,
    _maxPlanedTime * 0,
    _maxPlanedTime * 0.16,
    _maxPlanedTime * 0.32,
    _maxPlanedTime * 0.48,
    _maxPlanedTime * 0.64,
    _maxPlanedTime * 0.80,
    _maxPlanedTime * 1.0
  ];
}
