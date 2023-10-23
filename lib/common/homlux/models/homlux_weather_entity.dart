part 'homlux_weather_entity.g.dart';

class HomluxWeatherEntity {
  final String? condition;
  final String? icon;
  final String? locationName;
  final String? temperature;

  const HomluxWeatherEntity({
    this.condition,
    this.icon,
    this.locationName,
    this.temperature,
  });

  factory HomluxWeatherEntity.fromJson(Map<String, dynamic> json) =>
      _$HomluxWeatherEntityFromJson(json);

  Map<String, dynamic> toJson() => _$HomluxWeatherEntityToJson(this);
}
