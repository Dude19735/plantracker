class ColumnName {
  // So far used for PlanedWorkUnit, these can be for the WorkUnitEntry
  static const String date = "Date";
  // So far used for PlanedWorkUnit, these can be for the WorkUnitEntry
  static const String fromTime = "FromTime";
  // these can be used for the WorkUnitEntry
  static const String toTime = "ToTime";
  // break, work or a rainbow unicorn
  static const String workUnitType = "WorkUnitType";
  static const String workUnitGroupId = "WorkUnitGroupId";
  // planed time in the time table => should be a number typed by the user
  static const String planedTime = "PlanedTime";
  // recorded time using stop watch => result of group by and sum
  static const String recordedTime = "RecordedTime";
  // from stored data, updatable in settings
  static const String subjectId = "SubjectId";
  // from stored data, updatable in settings
  static const String subject = "Subject";
  // from stored data, updatable in settings
  static const String subjectAcronym = "SubjectAcronym";
  // from stored data, updatable in settings??? Maybe not because everything depends on it
  static const String planUnitTypeId = "PlanUnitTypeId";
  // free work, lecture, exercise... from stored data
  static const String planUnitType = "PlanUnitType";
  // series table?
  static const String seriesId = "SeriesId";
  static const String series = "Series";
  // maybe this is not necessary => can be determined on the fly
  static const String seriesFromDate = "SeriesFromDate";
  // maybe this is not necessary => can be determined on the fly
  static const String seriesToDate = "SeriesToDate";
  // just some suplementary stuff
  static const String noteId = "NoteId";
  // some suplementary stuff
  static const String note = "Note";
  // ability to activate or deactivate subjects
  static const String active = "Active";
  // maybe not necessary, too complicated...
  static const String activeFromDate = "ActiveFromDate";
  // maybe not necessary, too complicated...
  static const String activeToDate = "ActiveToDate";
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

  static const List<String> subjectAcronym = [
    "0_Mo_a",
    "1_Tu_a",
    "2_We_a",
    "3_Th_a",
    "4_Fr_a",
    "5_Sa_a",
    "6_Su_a"
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
