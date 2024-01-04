class Endpoint<T extends Event> {
  int endpoint;
  dynamic icon;
  dynamic name;
  dynamic cname;
  T event;

  Endpoint({
    required this.endpoint,
    this.icon,
    this.name,
    this.cname,
    required this.event,
  });

  factory Endpoint.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) eventFromJson) {
    return Endpoint(
      endpoint: json['endpoint'],
      icon: json['icon'],
      name: json['name'],
      cname: json['cname'],
      event: eventFromJson(json['event']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'endpoint': endpoint,
      'icon': icon,
      'name': name,
      'cname': cname,
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
