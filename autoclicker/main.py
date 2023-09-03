import time
import threading
import sys
import pynput.keyboard
import tkinter
from pynput.mouse import Button
from pynput.keyboard import Listener, KeyCode
from infi.systray import SysTrayIcon


# declaring functions, methods and menu
mouse = pynput.mouse.Controller()
keyboard = pynput.keyboard.Controller()
app = tkinter.Tk()
app.geometry("300x280")
app.title("autoclicker-notsopro")
app.resizable(width=False, height=False)


# variables
ClickKey = KeyCode(char="s")
PressKey = KeyCode(char="a")
ExitKey = pynput.keyboard.Key.esc
clicking = False
running = True


#   FUNCTIONS INSIDE BUTTONS   #
# "x" button
def on_closing():
    global running
    running = False
    sysTrayIcon.__exit__()


app.protocol("WM_DELETE_WINDOW", on_closing)


# inside button_function1 changes "ClickKey" to pressed key
def keyassign1(key):
    if key == pynput.keyboard.Key.esc or key == ExitKey or key == PressKey:
        sys.exit()
    else:
        global ClickKey
        ClickKey = key
        label_b1.config(text=ClickKey)
        sys.exit()


# Listen of a key
def button_function1():
    listener = Listener(on_press=keyassign1)
    listener.start()


# inside button_function2 changes "PressKey" to pressed key
def keyassign2(key):
    if key == pynput.keyboard.Key.esc or key == ExitKey or key == ClickKey:
        sys.exit()
    else:
        global PressKey
        PressKey = key
        label_b2.config(text=PressKey)
        sys.exit()


# Listen of a key
def button_function2():
    listener = Listener(on_press=keyassign2)
    listener.start()


# inside button_function3 changes "ExitKey" to pressed key
def keyassign3(key):
    if key == pynput.keyboard.Key.esc or key == ClickKey or key == PressKey:
        sys.exit()
    else:
        global ExitKey
        ExitKey = key
        label_b3.config(text=ExitKey)
        sys.exit()


# Listen of a key
def button_function3():
    listener = Listener(on_press=keyassign3)
    listener.start()


# start button - turn off menu (menu is a loop, breaking the loop will start rest of the program)
def button_f4():
    global running
    running = True
    app.quit()


#   DECLARING MENU VIEW   #
# menu 0 row
label_0 = tkinter.Label(master=app, text="start/stop clicking")
label_0.pack(side=tkinter.TOP, padx=10, pady=5)

# menu 1 row
label_1 = tkinter.Label(master=app)
label_1.pack(side=tkinter.TOP)
label_b1 = tkinter.Label(master=label_1, text="s")
label_b1.pack(side=tkinter.LEFT, padx=10, pady=5)
button_1 = tkinter.Button(master=label_1, command=button_function1, text="assign button")
button_1.pack(side=tkinter.RIGHT, padx=10, pady=5)

# menu 2 row
label_2 = tkinter.Label(master=app, text="press/release clicking")
label_2.pack(side=tkinter.TOP, padx=10, pady=5)

# menu 3 row
label_3 = tkinter.Label(master=app)
label_3.pack(side=tkinter.TOP)
label_b2 = tkinter.Label(master=label_3, text="a")
label_b2.pack(side=tkinter.LEFT, padx=10, pady=5)
button_2 = tkinter.Button(master=label_3, command=button_function2, text="assign button")
button_2.pack(side=tkinter.RIGHT, padx=10, pady=5)

# menu 4 row
label_4 = tkinter.Label(master=app, text="turn off")
label_4.pack(side=tkinter.TOP, padx=10, pady=5)

# menu 5 row
label_5 = tkinter.Label(master=app)
label_5.pack(side=tkinter.TOP)
label_b3 = tkinter.Label(master=label_5, text="esc")
label_b3.pack(side=tkinter.LEFT, padx=10, pady=5)
button_3 = tkinter.Button(master=label_5, command=button_function3, text="assign button")
button_3.pack(side=tkinter.RIGHT, padx=10, pady=5)

# start button
button_4 = tkinter.Button(master=app, command=app.destroy, text="start")
button_4.pack(side=tkinter.BOTTOM, padx=10, pady=10)

# TRAY ICON #
# hover text
hover_text = "autoclicker-notsopro"


# functions inside tray
def quittray(sysTrayIcon):
    app.quit()
    global running
    running = False
    keyboard.press(ExitKey)


# declaring tray
sysTrayIcon = SysTrayIcon("main.ico", hover_text, on_quit=quittray, default_menu_index=1)


#   MAIN FUNCTIONS   #
# loop inside Thread - allows clicking
def clicker():
    global running
    while running:
        if clicking:
            mouse.click(Button.left, 1)
        time.sleep(0.001)
    sys.exit()


# inside Listener - checks of a pressed key and change values to start/stop clicking
def toggle_event(key):
    global running
    if not running:
        sys.exit()
    elif key == ClickKey:
        global clicking
        clicking = not clicking
    elif key == PressKey:
        clicking = True
    elif key == ExitKey:
        running = False
        sysTrayIcon.__exit__()
        sys.exit()


# inside Listener - stops clicking when "PressKey" was used
def cut_event(key):
    if key == PressKey:
        global clicking
        clicking = False


#   MAIN   #
def main():
    sysTrayIcon.start()
    app.mainloop()
    if running:
        click_thread = threading.Thread(target=clicker)
        click_thread.start()
        with Listener(on_click=toggle_event, on_press=toggle_event, on_release=cut_event, daemon=False) as listener:
            listener.join()
    return 0


#   PROGRAM START   #
if __name__ == "__main__":
    main()
