class CountRIToday {
  final String status;
  final int count;

  CountRIToday({
    this.status,
    this.count,
  });

  factory CountRIToday.fromJson(Map<String, dynamic> json) {
    return CountRIToday(
      status: json['Status'],
      count: json['count'],
    );
  }
}
