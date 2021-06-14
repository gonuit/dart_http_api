library http_api;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:http_parser/http_parser.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'package:objectid/objectid.dart';

/// exports
export 'package:objectid/objectid.dart' show ObjectId;
export 'package:http_parser/http_parser.dart' show MediaType;

/// Link exports
export 'package:http_api/src/links/exception_link.dart' show ExceptionLink;
export 'package:http_api/src/links/logger_link.dart' show LoggerLink;
export 'package:http_api/src/links/headers_mapper_link.dart'
    show HeadersMapperLink;

/// BaseApi
part 'src/base_api.dart';

/// Utils
part 'src/utils/exceptions.dart';
part 'src/utils/types.dart';
part 'src/utils/body_encoding.dart';

/// Links core
part 'src/links/api_link.dart';
part 'src/links/in_place_link.dart';
part 'src/links/http_link.dart';
part 'src/links/debug_link.dart';

/// Requests
part 'src/requests/request.dart';
part 'src/requests/form_data_request.dart';

/// Responses
part 'src/responses/response.dart';

/// Data
part 'src/data/data.dart';
part 'src/data/form_data.dart';

/// Cache
part 'src/cache/cache_key.dart';
part 'src/cache/cache.dart';
part 'src/cache/in_memory_cache.dart';
