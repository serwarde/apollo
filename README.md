# APOLLO
A POLLing app with LOcation awareness


## Build

After the initial pull use `$ flutter pub get` to download all necessary dependencies.

Since the project uses automatic code generation, make sure having a build runner active in the background:
`$ flutter packages pub run build_runner watch --delete-conflicting-outputs`

Alternatively if you only want to update the generated code once, use: `$ flutter packages pub run build_runner build --delete-conflicting-outputs`


Based on youre build target use:

- web: `$ flutter build web` (located in `build/web`)
- android: `$ flutter build apk` (located in `build/app/outputs/apk/release/app-release.apk`)

The app will automatically connect to the uploaded backend on http://185.131.52.147:5000.

<br /><br /><br />


# Development 
## Testing
You can run existing tests with `$ flutter test`

## Projectstructure / general notes

### 'nice to know' things
- `flutter run -d web-server --web-port=9000`
will create hot-reloadable webserver with a fixed port

### project structure outline
- `lib/components` mostly ui design
- `lib/services` provides functionality for ui components (auth, database fetching), dto's
- `lib/config` configuration when/what/how services should be used
- `lib/router.dart` defines navigation between components

## Database Scheme

contains following tables:

- `users`, where account specific properties are saved that should be synchronized
- `poll-overview`, where within each user has a list of his own polls (everthing that should be displayed on the `MyPoll` overview list)
- `poll-details`, grouped by user, contains basically everything so that the user is able to edit all questions, time, location... (corresponds to the create/edit poll view)
- `polls`, grouped by poll id, queried for finding nearby polls (for participate poll view), (if this gets to large, we could split it in expired/archived and running polls, furthermore we could chunk it based on the location to reduce size even more, these changes shouldn't effect client usage at all)
- `poll-results`, grouped by poll id, contains answers, participates (as discussed where answer key is the hased uid and client-owned salt), the answer value might references a fixed option or is an independent value (this can be evaluated based on the question type), simmilar to `polls`, this could also be split into smaller subsets to improve querying. an overview field might be present for question types that have a fixes set of answer possibilities.

## Running the Backend
You have three options:
1. Use the uploaded backend (simplest)
2. Install the backend with pip
3. Install the backend from Docker image

### Use the Uploaded Backend
1. Set the url in `/assets/serverurl.txt` to http://185.131.52.147:5000
2. Start the app

### Backend Installation with pip
1. Install Python (at least version 3.6)
2. Navigate to the `/backend` folder in a terminal
3. `> python -m venv ./env`
4.  On Windows: `> env\Scripts\activate`   (displays a wrong parameter error on Windows: "Parameterformat falsch")  
    On Mac / Linux: `> source env/bin/activate`
5. `(env)> pip install -r requirements.txt`
    In case this fails, you can also manually install the needed packages one by one: flask, flask_cors, functools, json, pyrebase, firebase-admin
6. Replace the url in `/assets/serverurl.txt` by your PCs local ip address

### Backend Installation from Docker Image
1. Find the needed files in the `/backend` folder

#### Start Backend after Installation
1.  On Windows: `> env\Scripts\activate`  
    On Mac / Linux: `> source env/bin/activate`
2. `(env)> python app.py`

## Firebase Emulator

### Install
1. install node (tested with v14) with npm
2. run `$ npm install -g firebase-tools`
3. inside the project folder use `$ firebase emulators:start`
4. once started, the dashboard is available at `localhost:8081`

### Using existing data
Within `docs/sample_data` should be valid data with the corresponding version.
`firebase emulators:start --import <export-directory>` will load the sample data on start.
If you want to save you're changes to the sample data add the flag `--export-on-exit`.


## Theming

### General Styles
- Our themes are defined in `theme/themes.dart` and apply to the whole app depending on the type of the widget

### Global Colors
- Define a color for a widget either in the general theme (global scope) or directly in your widget (applies just to that one) by using 
    + `Theme.of(context).colorScheme.primary` or 
    + `Theme.of(context).colorScheme.secondary` or
    + `context.theme` or
    + `context.customTheme`
    + ...

- Some additional colors can be defined in `theme/themes.dart` per theme and queried by:
    + e.g. `context.customTheme`
    + you need to import 'package:awesome_poll_app/utils/commons.dart' for that

## Localization

to access properties include `import 'package:awesome_poll_app/utils/language_utils.dart';` in the file if not already present. 

You can then use `context.lang('property.name')` to access the defined property.

If you want to add a new property, goto `assets/lang` and add them to it. By default `strings.json` will be used as default (which should be in english).

You can access the current language with `context.locale`.

Language settings are currently limited to english and german.

## Logging
Instead of calling `print()`, you should preferably use `context.`, `info`, `debug`, `warn` and `error` for displaying messages. 

Whenever there's no build context available use `static Logger logger = Logger.of('class');`.

Make sure to include `import 'package:awesome_poll_app/utils/logger_utils.dart';`

### Debugging Overlay
on web you can enable the overlay with a `semicolon` and disable it with `singleQuote`. on android you can toggle it by shaking you're phone (for like half a second pretty hard).