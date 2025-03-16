# Contributing to GodotOS

Thanks for coming by! Here are some general contributing tips:

* Please make your variables and functions statically typed.
* Try to follow the [GDScript style guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html) as closely as you can (though this isn't entirely required)
* If you're planning on submitting a PR for a major feature or drastic change, please discuss it with me first.

# Adding your game/app to GodotOS

One thing I will always welcome is more games! There are just a few notes I have before you try to submit a PR for your game.

* **Try to make your game as small as you can.** GodotOS is built in mind to run on the web, so any large files can greatly detract from its loading times and portability. 
This doesn't mean you can't have SFX or sprites, just use them in moderation!
As a rule of thumb, try to make your game under 1 megabyte. Consider compressing your assets, going for a pixel-art or minimalist style, using a sprite atlas, etc.
* Don't use autoloads in your game since it would have to always be running for the entire application. If you **really** need an autoload, consider passing data through save files or adding a node in `/root/`.
  Remember to delete it on window exit if you're doing this!
* Avoid using functions that affect the entire scene such as `get_tree().change_scene_to_file()`. This will affect GodotOS as a whole, not just your game. Check the official games included for examples on how to safely change scenes only for the game window.
* Make sure your scene and script names less generic. If you have a player and the game is called Super Bit Boy for example, call it `bit_boy_player.gd` instead of `player.gd`.

That's it. Good luck!
