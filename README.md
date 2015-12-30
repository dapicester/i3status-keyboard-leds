# i3status-keyboard-leds

A Ruby wrapper for `i3status` adding current status of keyboard leds
(Caps lock, Num lock, Scroll lock and AltGr).

This is a port of [this](https://github.com/syl20bnr/i3status-keyboard-led)
Python wrapper which I couldn't get to work.

# Install

Get the script and symlink somewhere into you `$PATH`, for example:

    $ git clone https://github.com/dapicester/i3status-keyboard-leds.git
    $ sudo ln -s /path/to/i3status-keyboard-leds/i3status+.rb /usr/local/bin/i3status+

Ensure that in your `~/.i3status.conf` the `output_format` is set to `i3bar`:
```
general {
    output_format = "i3bar"
    ...
}
```

In your `~/.i3/config` replace the call to `i3status` by `i3status+`:
```
# Start i3bar to display a workspace bar (plus the system information i3status
# finds out, if available)
bar {
    status_command i3status+
    ...
}
```
