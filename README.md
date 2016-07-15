# game-closet
A collector's gaming collection should be organized and accessible at the tip of their fingers. With Game Closet, search through an online game database and add games you own to your gaming library. You can then organize and search through your own personal library to find the game you're looking for!

## Features
- Search for games by name and platform using Giant Bomb's extensive online video game library.
- Add and Remove games to/from personal collection.
- View cover art and details about individual games.
- Share a link to your favorite game's details with others through iMessage/SMS, Email, and Twitter!

## Coming Soon
- Highlight your favorite games in your personal collection by adding them to your Favorites list!

## Setup
NOTE: You'll need your own Giant Bomb API Key.

- Import project into Xcode.
- Duplicate the "Keys.sample.plist" file.
- Rename the duplicate file as "Keys.plist" and edit it within Xcode.
- Replace value "INSERT_GIANT_BOMB_API_KEY_HERE" with your own Giant Bomb API Key.

## Current Status of App
Currently in a beta stage.

## Known Issues
- Even if all games are removed for a particular platform, the platform still appears in the BrowsePlatformViewController.
- Data size of app increases without adding games to collection.
- Adding game to collection after searching online and then attempting to remove game will not remove game from collection.

**API Database created and hosted by Giant Bomb http://www.giantbomb.com/**
