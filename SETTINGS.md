### settings.plist configuration options

If the key has a default, it will be noted as an **Optional** field

**Key:** GoogleMapsAPIKey  
**Value:** *(String)* The key to use to initialize the Google Maps API for the polling list map view.

**Key:** GoogleAnalyticsTrackingID  
**Value:** *(String)* The key to use to initialize the Google Analytics SDK for app tracking.

**Key:** GoogleDirectionsAPIKey  
**Value:** *(String)* The key to use for calls to the Google Directions API.

**Key:** BrandNameText  
**Value:** *(String)* The brand name to display on the app homepage.

**Key:** electionId  
**Value:** *(String)* Forces the app to search for this electionId only as part of the v2 API voterInfo query.  
**Optional:** Default nil

**Key:** OfficialOnly  
**Value:** *(BOOL)* Sets the API query param officialOnly. If false, unoffiical sources will be returned and displayed via the API.
**Optional:** Default NO

**Key:** UseTestData
**Value:** *(BOOL)* If YES, pulls data from the VIP Test Election
**Optional:** Default NO

