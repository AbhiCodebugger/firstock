import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mindorigin/src/config/app_http_client.dart';
import 'package:mindorigin/src/utils/failure.dart';
import 'package:mindorigin/src/utils/typedefs.dart';

class ScriptedQuote {
  const ScriptedQuote({required this.status, this.data});

  final int status;
  final Map<String, Object?>? data;
}

class FakeAppHttpClient implements AppHttpClient {
  FakeAppHttpClient(this._bySymbol);

  final Map<String, ScriptedQuote> _bySymbol;
  final List<String> requestedSymbols = [];

  @override
  FutureEither<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool allowClientError = false,
  }) async {
    final symbol = '${queryParameters?['symbol'] ?? ''}';
    requestedSymbols.add(symbol);
    final scripted = _bySymbol[symbol];
    if (scripted == null) {
      return left(ServerFailure('Unexpected quote symbol $symbol'));
    }
    return right(
      Response<dynamic>(
        requestOptions: RequestOptions(path: path),
        statusCode: scripted.status,
        data: scripted.data,
      ),
    );
  }
}
