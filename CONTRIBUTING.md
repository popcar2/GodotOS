# Contributing to GodotOS

Thanks for coming by! Here are some general contributing tips:

* Please make your variables and functions statically typed.
* Try to follow the [GDScript style guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html) as closely as you can (though this isn't entirely required)
* If you're planning on submitting a PR for a major feature or drastic change, please discuss it with me first.

# Adding your game/app to GodotOS

One thing I will always welcome is more games! There are just a few notes I have before you try to submit a PR for your game.

* **Try to make your game as small as you can.** GodotOS is built in mind to run on the web, so any large files can greatly detract from its loading times and portability.
As a rule of thumb, try to make your game under 1 megabyte. Consider compressing your assets, going for a pixel-art or minimalist style, using a sprite atlas, etc.
* Don't use autoloads in your game since it would have to always be running for the entire application. If you **really** need an autoload, consider passing data through save files or adding a node in `/root/`.
  Just make sure to delete it on window exit. 
* Make sure your scene and script names less generic. If you have a player and the game is called Super Bit Boy for example, call it `bit_boy_player.gd` instead of `player.gd`.

That's it. Good luck!
