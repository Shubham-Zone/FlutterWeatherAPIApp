import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_application/business/ApiProvider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ApiCall(),
      child: MaterialApp(
        title: 'Weather App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
        ),
        home: const WeatherHome(),
      ),
    );
  }
}

class WeatherHome extends StatefulWidget {
  const WeatherHome({Key? key}) : super(key: key);

  @override
  State<WeatherHome> createState() => _WeatherHomeState();
}

class _WeatherHomeState extends State<WeatherHome> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      Provider.of<ApiCall>(context, listen: false).fetchWeatherDetails();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Weather Forecast"),
        elevation: 0,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height*1,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade800],
          ),
        ),
        child: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: SearchBar2(),
              ),
              SizedBox(height: 20),
              CurrentLocationButton(),
              SizedBox(
                height: 20,
              ),
              WeatherDisplay(),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchBar2 extends StatefulWidget {
  const SearchBar2({Key? key}) : super(key: key);

  @override
  _SearchBar2State createState() => _SearchBar2State();
}

class _SearchBar2State extends State<SearchBar2> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      color: Colors.deepPurple,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)
      ),
      child: TextField(
        controller: _controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: "Enter city name",
          labelStyle: const TextStyle(color: Colors.white),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            borderSide: BorderSide.none,
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              final apiCall = Provider.of<ApiCall>(context, listen: false);
              apiCall.cityName = _controller.text;
              apiCall.fetchWeatherFromApi();
            },
          ),
        ),
      ),
    );
  }
}

class CurrentLocationButton extends StatelessWidget {
  const CurrentLocationButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.location_on),
        label: const Text("Get Current Location Weather", style: TextStyle(color: Colors.purple),),
        onPressed: () {
          final apiCall = Provider.of<ApiCall>(context, listen: false);
          apiCall.fetchWeatherDetails();
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          primary: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}

class WeatherDisplay extends StatelessWidget {
  const WeatherDisplay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ApiCall>(
      builder: (context, apiCall, child) {
        final weather = apiCall.weatherModel;

        if (weather == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Location: ${apiCall.cityName}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  weather.city,
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  '${weather.temp}°C',
                  style: const TextStyle(fontSize: 48, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  weather.desc,
                  style: const TextStyle(fontSize: 24, color: Colors.white),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
