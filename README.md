# ISS Passes

This repository contains iOS app for ISSPass code challenge, named "ISS Passes", and developed by Maxim Klimov. 

## Basic features
- The app tries to obtain device's GPS coordinates 
- If coordinates are available, the app passes them to ISS Pass Times API 
- API returns information for each ISS "pass"
- The app shows each "pass" date abd duration in a list

## Bonus features
- App shows location address (city, state/province, country code) based on device coordinates. 
To get address, the app uses iOS MapKit 'reverse' geocoding of device coordinates.

- App allows to view ISS Passes information for any location, different from device coordinates. 
On "ISS Passes" tab screen:
	* Tap on location address;
	* In appeared popover, switch to "Use Coordinates Form" to "Address"
	* Enter address
	* Tap "Find" button
	* App will use iOS MapKit 'forward' geocoding to find address coordinates
	* If app shows "Address Found" status, tap on "Done"
	* The app will show ISS Passes information for entered address

- App shows current ISS Location on World map, and updates them every 5 sec.
	* App uses "ISS Current Location" API to get location data
	* Uses iOS MapKit to show ISS location on World map

- Unit tests

## Notes
- Didn’t create app artwork because of lack of time
- If had more time, could also develop Android app with similar features
