# <img src="windows/runner/resources/app_icon.ico" style="height: 22px; transform: translateY(2px)" /> folder_thumbnail_setter

With this windows application, you can apply custom thumbnails to your folders.  
It works like this:  

1. Open the app:  
	 <img src="readme_files/initial state.jpg" height="250px" />

2. In windows explorer, navigate to the thumbnail you want to pick.  
	 It needs to be a descendant of the folder whose thumbnail you want to set!

3. Drag the image inside the app window.  

	 <img src="readme_files/dropping image.gif" height="200px" />

4. Adjust the images position, scale and rotation.  
	 (Use your mousewheel to zoom and additionally press `ctrl` to rotate)

	 <img src="readme_files/adjusting image.gif" height="260px" />

5. The target folder is automatically set to the parent folder of the image, but you can 'navigate up' the ancestor chain. (Can't select an arbitrary folder, sorry!)  
	 __Optional__:  
	 <img src="readme_files/navigate up button.jpg" height="150px" />

6. Press 'Set Thumbnail'.  
	 
	 <img src="readme_files/pressing the button.gif" height="250px" />

7. This will create a hidden `desktop.ini` and `[RANDOM_HASH].ico` file in your folder.  
	 It might take a while (between 1 and 2 minutes) for your folder to show the new thumbnail.
	 
	 <img src="readme_files/final folder thumbnail.jpg" height="200px" />

Please be aware that this app is not super polished. There is pretty much no error handling at the moment.  
If the folder already has a thumbnail, the app will get stuck at `Please wait ...`. It will have generated *another* `.ico` file, but won't be able to apply it!  
(It's a good idea to delete this newer ico file to keep your folder tidy).  
Don't know when i will get around to fixing it!  
See the limitations-section below for more fun like this.  


## How to build

The build process is exactly the same as in my other app:

https://github.com/flurrux/video_snapshooter#how-i-build-it


## Limitations and Issues

### Image file must be descendant of folder

That's an artifical limiation. In my use cases i'm almost always picking a thumbnail that's inside the target folder.  
The workaround is to copy the image inside the folder and then select it.  


### Existing desktop.ini

This app does not check if a `desktop.ini` already exists in the folder!  
If it does, the app will get stuck at `Please wait ...` and it will have generated an unused .ico file.  
It would definitely be nice to be able to __change__ the thumbnail if one already exists (keeping its contents, while only updating the icon).  
The current workaround is to create a new folder and move the contents over.  
There you can create a brandnew `desktop.ini`.  


### Glitched explorer

It can happen windows explorer starts to glitch (e.g. Some folders are not showing up, Thumbnails are completely wrong and pixel-scrambled, Selection impossible) and i don't know why it happens. Rebooting my PC always fixes it, but it's annoying.  

It might have something to do with the way i'm forcing explorer to show the thumbnail with this cmd command:

`Start-Sleep -Seconds 60; New-Item "$folderPath\\.refresh" -ItemType File; Remove-Item "$folderPath\\.refresh"`.  

It sleeps for a minute (waiting for the thumbnail cache to update) and then creates an empty file and deletes it again.  
