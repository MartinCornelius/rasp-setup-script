#!/bin/sh
sudo apt-get update
sudo apt-get install lightdm -y
sudo apt-get install --no-install-recommends xserver-xorg x11-xserver-utils xinit openbox -y
sudo apt-get install --no-install-recommends chromium-browser -y
sudo apt-get install plymouth plymouth-themes -y
sudo apt-get install pix-plym-splash -y

sudo printf "xset s off\nxset s noblank\nxset -dpms\nchromium-browser --disable-infobars --kiosk '%s'" $1 > /etc/xdg/openbox/autostart
sudo printf "[[ -z \$DISPLAY && \$XDG_VTNR -eq 1 ]] && startx -- -nocursor" > .bash_profile
sudo mv splash.png /usr/share/plymouth/themes/pix

echo "disable_splash=1" | sudo tee -a /boot/config.txt
echo " quiet splash plymouth.ignore-serial-consoles logo.nologo vt.global_cursor_default=0" | sudo tee -a /boot/cmdline.txt

sudo echo "screen_width = Window.GetWidth();
screen_height = Window.GetHeight();

theme_image = Image("splash.png");
image_width = theme_image.GetWidth();
image_height = theme_image.GetHeight();

scale_x = image_width / screen_width;
scale_y = image_height / screen_height;

flag = 1;

if (scale_x > 1 || scale_y > 1)
{
        if (scale_x > scale_y)
        {
                resized_image = theme_image.Scale (screen_width, image_height / scale_x);
                image_x = 0;
                image_y = (screen_height - ((image_height  * screen_width) / image_width)) / 2;
        }
        else
        {
                resized_image = theme_image.Scale (image_width / scale_y, screen_height);
                image_x = (screen_width - ((image_width  * screen_height) / image_height)) / 2;
                image_y = 0;
        }
}
else
{
        resized_image = theme_image.Scale (image_width, image_height);
        image_x = (screen_width - image_width) / 2;
        image_y = (screen_height - image_height) / 2;
}

if (Plymouth.GetMode() != "shutdown")
{
        sprite = Sprite (resized_image);
        sprite.SetPosition (image_x, image_y, -100);
}

fun message_callback (text) {
        sprite.SetImage (resized_image);
}

Plymouth.SetUpdateStatusFunction(message_callback);" | sudo tee /usr/share/plymouth/themes/pix/pix.script
