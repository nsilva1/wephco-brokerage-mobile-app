import 'package:wephco_brokerage/models/bank.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class FlutterwaveService {
  static const bool _isProduction = bool.fromEnvironment('dart.vm.product');

  static const String apiKey = _isProduction ? String.fromEnvironment('API_KEY_PROD') : String.fromEnvironment('API_KEY_DEV', defaultValue: '');

  static const String _baseUrl = 'https://api.flutterwave.com/v3';

  Future<List<Bank>> getBanks() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/banks/NG?include_provider_type=1'),
      headers: {
        'Authorization': 'Bearer FLWSECK_TEST-4e746968d414be06fdbf04206dd533f5-X',
        'Content-Type': 'application/json',
        'accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body['data'] ?? [];
      return data.map((bank) => Bank.fromMap(bank)).toList();
    } else {
      throw Exception('Failed to load banks: ${response.statusCode} ${response.reasonPhrase}');
    }
  }

  Future<String> resolveAccountName(String accountNumber, String bankCode) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/accounts/resolve'),
      headers: {
        'Authorization': 'Bearer FLWSECK_TEST-4e746968d414be06fdbf04206dd533f5-X',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'account_number': accountNumber,
        'account_bank': bankCode
      }),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['data']['account_name'] ?? '';
    } else {
      throw Exception('Failed to resolve account name: ${response.statusCode} ${response.reasonPhrase}');
    }
  }

}