---
title: "Android Notes"
date: 2020-04-05T17:16:46+02:00
tags: [android, programming]
draft: true
---

There are four types of components that make up an android app:

 - Activity
 - Service
 - Broadcast Reciever
 - Content Provider

These components are registered in the Android Manifest file.

## Activity
An activity is a single focused thing that the user can do. It is responsible for creating 
a window that the application uses to draw and recieve events from the system.  
Often, we can view a usage of an application as a series of consecutive activities. When 
the back-button is used, we go to the previous activity in the series.  
The *android launcher* knows about the activity because the *intent-filter* category is 
set inside the manifest file:
```xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
          package="io.github.baardkrk.project_name">

    <uses-permission android:name="android.permission.INTERNET" />

    <application
            android:allowBackup="true"
            android:icon="@mipmap/ic_launcher"
            android:label="@string/app_name"
            android:roundIcon="@mipmap/ic_launcher_round"
            android:supportsRtl="true"
            android:theme="@style/AppTheme">
			
        <activity android:name=".MainActivity">
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>

        <activity
            android:name=".AnotherActivity"
            android:parentActivityName=".MainActivity">
            <meta-data
                android:name="android.support.PARENT_ACTIVITY"
                android:value=".MainActivity" />
        </activity>

    </application>
</manifest>
```

Each activity includes a layout which tells android *how* to display the different 
elements that make up the UI.
The layout is stored in the resources folder. We fetch the layout in the `MainActivity` 
file by `setContentView(R.layout.activity_main` in the `onCreate` funciton.

#### UI Components
In the android layout file, we declare different components which *occupy a rectuangular
are of the screen*. These can for example be `TextView`, `EditText`, `ImageView`, 
`Button` or `Chronometer`.

These are again contained in a container view which is extended from a class called
`ViewGroup`. These container views determines where the components are on the screen.
Examples of these are `LinearLayout`, `RecyclerView` or `ConstrainedLayout`.

We can style the components using css-terms such as `textSize` or `padding`.

##### The R class
Generated class that allows you to identify the varoius contents of the resource folder.

### Action Bar
To create the action bar, we have to add the `menu` directory to our resources. 
Add the items we need.  
In the `ActivityMain` file, we declare `onCreateOptionsMenu` and set 
`menuInflater.inflate(R.menu.main, menu)` before returning `true`.

### Networking
okHttp has some good libraries.
android uses UTF-16 encoding.


#### Recycler View
Has an adapter - used to provide the RecyclerView with new data when needed. It is 
connected to a data source.
The adapter sends view to the RecyclerView through an object called a ViewHolder.
It contains a reference to the root-view object for the item. We use the ViewHolder to 
cache the ViewObjects represented in the layout. 
`findViewById` is then only called whenever an object is *created* (so it is not called
when a cached object is loaded in). 

The LayotManager tells the RecyclerView *how* to layout all the views, such as a list, 
grid or staggered grid. You can also extend `LayoutManager` to create your own. 
ListView has now become deprecated because RecyclerView has taken its place.

#### Accessibility
In android we can use two different units for describing the size of things. `dp` and 
`sp`. In earlier android phones the screen was usually 160px wide. On those screens
`1dp == 1px`. On newer phones we can use the formula `px = dp * (dpi / 160)`. This means
that elements with units `dp` and `sp` will be the same approximate physical size, 
regardless of the resolution/pixel density of the display. `sp` works like `dp` but is 
scaled based on the user preferences on the system. We therefore use this for fonts, for
example. 

#### Clicking on Items
In the Android Sunshine app, we implemented item clickers like this:  
In the Adapters constructor, we need to get a `ClickHandler`. This is an interface which
we can define wherever we want, but in this case, we defined the interface in the 
`Adapter` class. The `ClickHandler` defines a method that gets the data from the view,
for example the list items string.

The ViewHolder in the Adapter needs to implement `View.OnClickListener`. The implemented 
method `onClick` fetches whatever data we want from the view, and passes it to the 
`ClickHandler` object from the parent class.

Now, the `MainActivity` class needs to implement the `ClickHandler` interface. Then, 
since it implements the `ClickHandler` we can pass it (`this`) to the `Adapter` class when
we create it.

### Intents
Android uses Intents when we want to start one Activity from another. Although we could
just call the activity directly, android facilitates this communication via messaging-
objects called intents. 

A good image for an intent is an envelope. It has information of where it's going (which
activity we want to start) and can hold a little bit of information known as *extras*.

#### Implicit intents
Describes intents that can open a different app to complete the intent. This could be 
using the system camera to take a picture, a web-browser to open a link ++.  
This can be useful so your app both doesn't have to implement the integration to each 
specific hardware, but also because you don't need extended permissions if you use other 
apps that already have permission.  
For example: an app can create an intent to use the system camera app to take a picture. 
Then, the app making the intent doesn't need permission to use the camera.


#### Share Intent
Used to share more than just a little data between activities. It uses MediaType string 
to describe what is shared.
We can use the `ShareCompat.IntentBuilder` to create share-intents.


### Lifecycle
The activity starts in the `onCreate` phase, which builds and wires up the UI.
Then it goes to the `onStart` which makes the activity visible to the user. And finally 
to the `onResume` which makes the activity the active foreground app.

`onPause` transitions the activity to a Paused state, which indicates that the activity 
has lost focused.  
It is followed by `onStop` which makes the app invisible. Finally the app is completely 
finished with `onDestroy`.

When the application is Paused it can call the `onResume` to become visible again.
Same, when it is Stopped, it can call `onRestart` which takes it back to the `onStart` 
phase.


!! Loaders have been deprecated as of API version 28 !!
It is important to note that async-tasks will keep old activities alive (as 'zombie-
activities') until they finish their `onPostExecute` functions. This means that if we
rotate a device while an AsyncTask is running, the rotated activity will spawn a new 
AsyncTask while the other is still running in the background. This can lead to usage of 
much more resources than we need.  
We can mitigate this by using *Loaders*. If an app is changed by for example rotating 
the device, an `AsyncTaskLoader` will not spawn a new task, but instead wait until 
`onLoadFinished` is called, before it will be able to. It will return the results from 
the `onLoadFinished` to the *current active activity*.



#### Preparing for app Death
Android has the ability to destroy apps in the background if it needs more resources.
This means all apps in the `onPause` or `onStop`. If these are called, we need to 
for example close sockets, if we have internet access in the app. 

We can use `onSaveInstanceState` to persist data which may be lost when we close the app.
This can also be used to preserve data when we rotate the device. When this is done, the 
`onCreate` method is called to rebuild the UI, and so, non-preserved data will be lost.
