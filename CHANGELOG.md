## [0.8.3-dev.5] 09 December 2020.
- Added [FormData] class.
  - Removed `multipart` and `isMultipart` values from `ApiRequest`.
  - Added [FormData] serialization.
- Renamed `apiRequest` property in `ApiResponse` class to `request`.
## [0.7.3] - 06 November 2020.
- Added support for ApiRequest and ApiResponse serialization (simplify caching).
  - Added toJson methods and fromJson constructors.
## [0.7.2+2] - 09 September 2020.
- Added `ApiLink.next` constructor to allows in-place link creation.
- ⚠️ `ApiLink` now cannot be used as mixin. 
- Added `ApiLink.next` example to the readme.
## [0.7.1] - 07 September 2020.
- Removed flutter from dependency (add crossplatform support).
  - Replaced Flutter `Key` class with `CacheKey`.
- Cache system changes:
  - `CacheKey` class now operates on `String` values.
  - Create `CacheManager` class.
  - Added `Cache` mixin that adds cache to `BaseApi` instances.
    ```dart
    class Api extends BaseApi with Cache {

      @override
      CacheManager createCacheManager() => InMemoryCache();

      /// ** your custom Api class implementation **
    }
    ```
- Now displaying `hexString` for id's in logger link.
- Added `createdAt` property to `ApiRequest`. 
- Made `saveCache` function optionally asynchronous.
- url is now a required positional argument in BaseApi class constructor.
- Improved readme file.
- Bug fixes:
  - Fixed example app compilation error.
  - Disallowed chaining DebugLink in release apps when only one link is provided.
## [0.6.0] - 06 September 2020.
- Renamed current `DebugLink` class to `LoggerLink`.
- Added abstract `DebugLink` class. DebugLinks are special types of links that will never be chained (will be skipped) in release builds. 
- Replaced internal `ApiException`s with `ApiError`s.
## [0.5.0] - 05 September 2020.
* Added cache support.
* Added id property to ApiRequest and ApiResponse objects.
## [0.4.2] - 03 June 2020.
* Added `ok` property to `ApiResponse`
* Added `redirect` property to `ApiResponse`
## [0.4.1] - 27 April 2020.
* Added `FileField.fromStream` constructor.
## [0.4.0] - 19 April 2020.
* `BaseApi` now uses Uri path from `url` argument (not only host) also port and queryParameters are coppied.
* Added unit tests
## [0.3.0] - 19 April 2020.
### Breaking changes
* Renamed `ApiBase` to `BaseApi`
* Replaced `BaseApi` `call` method with `send` method which accepts the argument `ApiRequest`.
## [0.2.0] - 18 April 2020.
* Add example
* Fixed request duration bug (DebugLink)
## [0.1.0+3] - 18 April 2020.
* Initial release.
