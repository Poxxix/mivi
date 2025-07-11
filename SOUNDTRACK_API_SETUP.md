# 🎵 Soundtrack API Setup Guide

This guide explains how to setup real soundtrack APIs for the Mivi app to work with all movies.

## 🆓 Free APIs (Recommended)

### 1. **MusicBrainz API** (Already Integrated)
- ✅ **Completely FREE**
- ✅ **No API key required**
- ✅ **Open source music database**
- ✅ **Already working in the app**

**What it provides:**
- Artist information
- Album metadata
- Release information
- Track listings

### 2. **TheAudioDB API** (Already Integrated)
- ✅ **Free tier: 1000 requests/month**
- ✅ **No registration required for basic usage**
- ✅ **High quality artwork**
- ✅ **Already working in the app**

**What it provides:**
- Album artwork
- Artist biographies
- Track information
- Music metadata

### 3. **Movie Theme Song Database** (Optional)
A community-driven GitHub project that maps movies to their soundtracks.

**Setup:**
```bash
# Clone the repository
git clone https://github.com/atlexis/movieThemeSongDatabase.git
cd movieThemeSongDatabase

# Install dependencies
pip install -r requirement.txt

# Set environment variable
export FLASK_APP=api

# Run local server
flask run
# Server will run on http://localhost:5000
```

**What it provides:**
- Direct movie ID to soundtrack mapping
- Spotify track IDs
- IMDB integration
- Curated movie soundtrack data

## 💰 Premium APIs (Optional Upgrades)

### 4. **Spotify Web API**
For direct Spotify integration with playable previews.

**Setup:**
1. Go to [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
2. Create a new app
3. Get Client ID and Client Secret
4. Add to your environment variables:

```dart
// In lib/core/constants/api_constants.dart
static const String spotifyClientId = 'YOUR_CLIENT_ID';
static const String spotifyClientSecret = 'YOUR_CLIENT_SECRET';
```

**Benefits:**
- 30-second track previews
- Direct Spotify integration
- Real track metadata
- Playlist creation

### 5. **MusicFetch API**
Universal music link finder across 30+ platforms.

**Setup:**
1. Sign up at [MusicFetch.io](https://musicfetch.io/)
2. Get API token
3. Add to your constants:

```dart
static const String musicFetchApiKey = 'YOUR_API_KEY';
```

**Benefits:**
- Links to all major music platforms
- Universal track matching
- Cross-platform availability

### 6. **Last.fm API**
Music metadata and user statistics.

**Setup:**
1. Register at [Last.fm API](https://www.last.fm/api)
2. Get API key
3. Add to your constants

**Benefits:**
- Rich metadata
- User listening statistics
- Similar artists/tracks
- Music recommendations

## 🚀 Current Implementation Status

### ✅ What's Working Now:
1. **MusicBrainz search** - Finding albums and artists
2. **TheAudioDB search** - Getting artwork and metadata
3. **Fallback generation** - AI-suggested soundtracks for any movie
4. **Search links** - Direct links to Spotify, YouTube, Apple Music
5. **Audio playback** - Working audio URLs for testing

### 🔄 Fallback Strategy:
The app uses a smart fallback system:

1. **Mock data** for popular movies (fastest)
2. **Real APIs** for general search
3. **AI-generated suggestions** as last resort
4. **Always provide search links** to major platforms

## 🛠 How to Add More APIs

### Adding a New API:
1. Add constants to `ApiConstants`:
```dart
static const String newApiBase = 'https://api.example.com';
static const String newApiKey = 'YOUR_KEY';
```

2. Add method to `MovieSoundtrackService`:
```dart
Future<MovieSoundtrack?> _searchNewAPI(String movieTitle) async {
  // Implementation here
}
```

3. Add to fallback chain in `_searchSoundtrackByTitle()`

### Testing Your Setup:
1. Run the app
2. Navigate to a movie detail page
3. Check debug console for API call logs:
   - `🎵 Fetching real soundtrack data...`
   - `🎵 Found data from [API_NAME]`
   - `❌ [API_NAME] search failed:` (if issues)

## 🎯 Recommended Setup for Production

### Minimal Setup (FREE):
- ✅ MusicBrainz (already working)
- ✅ TheAudioDB (already working)
- ✅ Search links (already working)

### Enhanced Setup (+$6/month):
- ✅ All free APIs above
- ✅ MusicFetch API ($6/month)
- ✅ Spotify Web API (free tier)

### Premium Setup (+$50/month):
- ✅ All above
- ✅ Higher API limits
- ✅ Real-time track previews
- ✅ Advanced recommendations

## 🐛 Troubleshooting

### Common Issues:

1. **"Movie Theme DB not available"**
   - This is normal - it's an optional local server
   - App will fallback to other APIs automatically

2. **"No tracks found"**
   - Check internet connection
   - Verify API endpoints are accessible
   - Check debug logs for specific API errors

3. **"API search failed"**
   - APIs might be temporarily down
   - Rate limiting reached (especially on free tiers)
   - Check API key configuration

### Debug Mode:
Enable debug logging to see which APIs are being called:
```dart
// In your debug settings
print('🎵 API Debug Mode Enabled');
```

## 📊 API Comparison

| API | Cost | Setup | Data Quality | Coverage |
|-----|------|-------|--------------|----------|
| MusicBrainz | Free | None | ⭐⭐⭐⭐ | Global |
| TheAudioDB | Free | None | ⭐⭐⭐⭐⭐ | High |
| Movie Theme DB | Free | Local setup | ⭐⭐⭐ | Limited |
| Spotify API | Free tier | App registration | ⭐⭐⭐⭐⭐ | Massive |
| MusicFetch | $6/month | API key | ⭐⭐⭐⭐⭐ | Universal |

## 🎬 Ready to Use!

Your app is already configured to work with free APIs and will provide soundtrack data for all movies. The premium APIs are optional upgrades for enhanced functionality.

Test it now by:
1. Running the app
2. Opening any movie detail page  
3. Scrolling to the Soundtrack section
4. Enjoying the music! 🎵 