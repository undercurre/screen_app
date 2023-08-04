class Endpoint<T extends Event> {
  int endpoint;
  String? icon;
  String name;
  T event;

  Endpoint({
    required this.endpoint,
    this.icon,
    required this.name,
    required this.event,
  });

  factory Endpoint.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) eventFromJson) {
    return Endpoint(
      endpoint: json['endpoint'],
      icon: json['icon'],
      name: json['name'],
      event: eventFromJson(json['event']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'endpoint': endpoint,
      'icon': icon,
      'name': name,
      'event': event.toJson(),
    };
  }
}

class Event {
  Event();

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event();
  }

  Map<String, dynamic> toJson() {
    return {};
  }
}
