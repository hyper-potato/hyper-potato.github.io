# A boring look into my Spotify playlist


__Sit tight and listen to music__

For the past weeks, I’ve taken breaks from staring blankly into the middle distance to dip deeper into my playlists than I have in years.

I’m using Spotify only since last year here and there, most of time I use apple music as the main source of music. I like the feature of adding songs to library on apple music. By innertion I’m still using the library to save songs that I like. After moving apple music library to Spotify, I nerded out to see how my playlist looks under Spotify's standard.



## Preparation

To get the data I used [Spotify API](https://developer.spotify.com/documentation/web-api/) and [spotipy](https://github.com/plamere/spotipy) as a Python client. After creating a web application in Spotify API Dashboard and gathering the credentials, I was able to initialize and authorize the client.

```python
import spotipy
import spotipy.util as util

token = util.prompt_for_user_token(user_id,
                                   scope = 'playlist-read-collaborative',
                                   client_id=client_id,
                                   client_secret=client_secret,
                                   redirect_uri= redirect_uri)
sp = spotipy.Spotify(auth=token)
```



## Get audio features of song tracks

As everything is inside just one playlist, it was easy to gather. The only problem was that `user_playlist` method in Spotipy doesn’t support pagination and can only return the first 100 track, but it was easily solved by adding condition of `while more_songs`

```python
def get_features_from_playlist(user='', playlist_id=''):
    '''
    Takes in a user_id and a playlist_id and returns a dataframe of a user's playlist songs
    '''
    df_result = pd.DataFrame()
    track_list = ''
    uploader_list = []
    added_ts_list = []
    artist_list = []
    title_list = []

    more_songs = True #As long as there is tracks not fetched from API, continue looping
    offset_index = 0

    if playlist_id != '' and user == '':
        print("Enter username for playlist")
        return

    while more_songs:
        songs = sp.user_playlist_tracks(user, playlist_id=playlist_id, offset=offset_index)

        for song in songs['items']:
        #join track ids to a single string as an input parameter for audio_features function
            track_list += song['track']['id'] +','

            #get the time when the song was added
            added_ts_list.append(song['added_at'])

            #get the title of the song
            title_list.append(song['track']['name'])

            #get all the artists in the song
            artists = song['track']['artists']
            artists_name = ''
            for artist in artists:
                artists_name += artist['name']  + ','
            artist_list.append(artists_name[:-1])

            #get user who added song in the playlist, catering for collaboration playlists
            uploader_list.append(song['added_by']['id'])

        #get the track features and append into a dataframe
        track_features = sp.audio_features(track_list[:-1])
        df_temp = pd.DataFrame(track_features)
        df_result = df_result.append(df_temp)
        track_list = ''

        if songs['next'] == None:
            # no more songs in playlist
            more_songs = False
        else:
            # get the next n songs
            offset_index += songs['limit']
            print('Progress: ' + str(offset_index) + ' of '+ str(songs['total']))

    #add the timestamp added, title and artists of a song
    df_result['added_at'], df_result['song_title'], df_result['artists'] = added_ts_list, title_list, artist_list
    return df_result    
```





## A glimpse of my playlists

get all my playlist:

```python
user_playlists = sp.user_playlists(user='6sv95ub14tdhriy0zglf28t6a')

for playlist in user_playlists['items']:
    print(playlist['id'], playlist['name'])
```

```
6BgM0WE6GXv2HLXYj1D4lu Quarantine Lib
42PZihHa5JlJOqfNjd470c Driving
3NVmRhOFS8OATMTRHP6mUB In Case Of Running
21BwKkjfxTc1AKYTl7QxkL wedding
5y7VC5N6v4M8ZqeN7SWTvK Detached
6sRetqhCIdjFqh1AONjCF2 From Movies
```

first column is playlist id, second is the name of playlist



Let's dive into playlist 'Quarantine Lib'  🙌

```python
playlist = sp.user_playlist(user_id, '6BgM0WE6GXv2HLXYj1D4lu')
tracks = playlist['tracks']['items']
next_uri = playlist['tracks']['next']
for _ in range(int(playlist['tracks']['total'] / playlist['tracks']['limit'])):
    response = sp._get(next_uri)
    tracks += response['items']
    next_uri = response['next']

tracks_df = pd.DataFrame([(track['track']['id'],
                           track['track']['artists'][0]['name'],
                           track['track']['name'],
                           parse_date(track['track']['album']['release_date']) if track['track']['album']['release_date'] else None,
                           parse_date(track['added_at']))
                          for track in playlist['tracks']['items']],
                         columns=['id', 'artist', 'name', 'release_date', 'added_at'] )
```



### Top artists

The first vanilla idea was the list of the most appearing artists in my playlist:

```python
tracks_df \
    .groupby('artist') \
    .count()['id'] \
    .reset_index() \
    .sort_values('id', ascending=False) \
    .rename(columns={'id': 'amount'}) \
    .head(10)
```

<img src="https://i.loli.net/2020/04/06/8Ceh7XnRbWOPvDu.png" alt="image.png" style="zoom:50%;" />



### Audio features of song tracks

Spotify API has [an endpoint](https://developer.spotify.com/documentation/web-api/reference/tracks/get-audio-features/) that provides features like danceability, energy, loudness and etc for tracks. So I gathered features for all tracks from the playlist. I don't have years of records on Spotify so it's difficult to check how my taste has changed over years. 🤷‍♀️

So I looked at if my music habits changes under lockdown. It turns out only `Valence` had some visible difference:

> Valence: A measure from 0.0 to 1.0 describing the musical positiveness conveyed by a track. Tracks with high valence sound more positive (e.g. happy, cheerful, euphoric), while tracks with low valence sound more negative (e.g. sad, depressed, angry).

```python
plt.figure(figsize=(6,4))

sns.boxplot(x=df_2020.added_at.dt.month, y=df_2020.valence, color='#1eb954')

plt.title("Valence changes over months", fontsize=12,y=1.01,weight='bold')

plt.tight_layout()
```



<img src="https://i.loli.net/2020/04/06/ER7gCzIdf3BtaLM.png" alt="image.png" style="zoom:50%;" />







But right now it looks like this

![image.png](https://i.loli.net/2020/04/06/PjBUf851hLvrHdi.png)



Let's just say I've tried to be chipper under quarantine, because I’m afraid that if there's one crack, I’ll fall apart completely.



## How different and similar among songs?

I took those features out and calculate the distance between every two different tracks. (matrix production)

```python
encode_fields = [
    'danceability',
    'energy',
    'key',
    'loudness',
    'mode',
    'speechiness',
    'acousticness',
    'instrumentalness',
    'liveness',
    'valence',
    'tempo',
    'duration_ms',
    'time_signature',
]

def encode(row):
    return np.array([
        (row[k] - tracks_with_features_df[k].min())
        / (tracks_with_features_df[k].max() - tracks_with_features_df[k].min())
        for k in encode_fields])

tracks_with_features_encoded_df = tracks_with_features_df.assign(
    encoded=tracks_with_features_df.apply(encode, axis=1))
```

```python
tracks_w_features_encoded_product = tracks_w_features_encoded \
    .assign(temp=0) \
    .merge(tracks_w_features_encoded.assign(temp=0), on='temp', how='left') \
    .drop(columns='temp')

tracks_w_features_encoded_product = tracks_w_features_encoded_product[
    tracks_w_features_encoded_product.id_x != tracks_w_features_encoded_product.id_y
]

tracks_w_features_encoded_product['merge_id'] = tracks_w_features_encoded_product \
    .apply(lambda row: ''.join(sorted([row['id_x'], row['id_y']])), axis=1)

tracks_w_features_encoded_product['distance'] = tracks_w_features_encoded_product \
    .apply(lambda row: np.linalg.norm(row['encoded_x'] - row['encoded_y']), axis=1)
```



### Most similar songs

After that I was able to get most similar songs/songs with the minimal distance, and it selected kind of similar songs:

```python
tracks_w_features_encoded_product \
    .sort_values('distance') \
    .drop_duplicates('merge_id') \
    [['artists_x', 'song_title_x', 'artists_y', 'song_title_y', 'distance']] \
    .head(10)
```



| artists_x              | song_title_x            | artists_y                | song_title_y          | distance |
| ---------------------- | ----------------------- | ------------------------ | --------------------- | -------- |
| Florence + The Machine | The End Of Love         | Glass Animals            | Gooey                 | 0.011732 |
| OK Go                  | Here It Goes Again      | The Jesus and Mary Chain | Some Candy Talking    | 0.108457 |
| Muse                   | Starlight               | AC/DC                    | Thunderstruck         | 0.141387 |
| Ween                   | Mutilated Lips          | Pulp                     | Something Changed     | 0.158513 |
| Men I Trust            | Tailwhip                | Blur                     | My Terracotta Heart   | 0.161328 |
| Talking Heads          | Road to Nowhere         | HAIM                     | The Steps             | 0.162264 |
| Halestorm              | Bad Romance             | Dodgy                    | Good Enough           | 0.162886 |
| Oasis                  | Wonderwall - Remastered | The Vaccines             | If You Wanna          | 0.163632 |
| Glass Animals          | Black Mambo             | Christine and the Queens | People, I've been sad | 0.165064 |
| DYGL                   | Let It Out              | Razorlight               | In The Morning        | 0.165887 |

Interesting...

and suprisely make sense!



### Most average songs

eg the songs with the least distance from every other song:

```python
tracks_w_features_encoded_product \
    .groupby(['artists_x', 'song_title_x']) \
    .sum()['distance'] \
    .reset_index() \
    .sort_values('distance') \
    .head(10)
```

| artists                       | song_title                               | distance   |
| ----------------------------- | ---------------------------------------- | ---------- |
| The Animals                   | We Gotta Get Out Of This Place           | 758.802868 |
| The Band Perry                | If I Die Young                           | 761.310917 |
| Arctic Monkeys                | Do I Wanna Know?                         | 767.353926 |
| One Direction                 | Story of My Life                         | 773.588932 |
| Urge Overkill                 | Girl, You'll Be a Woman Soon             | 775.938550 |
| alt-J                         | Tessellate                               | 783.974366 |
| Guns N' Roses                 | Knockin' On Heaven's Door                | 786.414124 |
| alt-J                         | Breezeblocks                             | 787.258564 |
| Divinyls                      | I Touch Myself                           | 787.683498 |
| Tears For Fears,Dave Bascombe | Head Over Heels - Dave Bascombe 7" N.Mix | 789.882583 |

### Most 'So not me' songs

| Artists                        | song_title                                 | distance    |
| ------------------------------ | ------------------------------------------ | ----------- |
| Per-Olov Kindgren              | After Silence                              | 1344.912261 |
| MONO                           | Ashes in the Snow - Remastered             | 1277.382099 |
| Wang Wen                       | Daybreak                                   | 1248.961555 |
| Immortal Technique             | Dance with the Devil                       | 1234.134745 |
| Flanger                        | Bosco's Disposable Driver                  | 1229.194120 |
| Lera Lynn                      | My Least Favorite Life                     | 1224.326841 |
| Dire Straits                   | Brothers in Arms                           | 1222.817652 |
| Bad Brains                     | Untitled (Bonus Track)                     | 1203.332781 |
| Dire Straits                   | Private Investigations                     | 1201.117077 |
| Gorillaz,Mavis Staples,Pusha T | Let Me Out (feat. Mavis Staples & Pusha T) | 1199.232041 |



## Next

I'll use cluster to bucket my favorite tracks when I get really bored.

<img src='/images/google cute.jpeg'>

# TL; DR

**Let's jam out!**

How do you find good music you've never heard before?

Try this website... [www.gnoosic.com](http://www.gnoosic.com/) you put in three of your favorite bands/artists, and it will recommend similar stuff that you most likely haven't heard of, or listened to.

And you will come back and thank me. You are welcome. 
