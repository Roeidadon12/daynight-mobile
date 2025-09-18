class PaginationLink {
  final String? url;
  final String label;
  final bool active;

  PaginationLink({
    this.url,
    required this.label,
    required this.active,
  });

  factory PaginationLink.fromJson(Map<String, dynamic> json) {
    return PaginationLink(
      url: json['url'],
      label: json['label'],
      active: json['active'],
    );
  }
}
