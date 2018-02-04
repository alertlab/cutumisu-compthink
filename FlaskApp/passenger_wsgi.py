import sys, os
INTERP = "/mnt/www/cutumisu-compthink/FlaskApp/venv/bin/python"

#print(sys.executable)
#print(sys.executable != INTERP)

#INTERP is present twice so that the new Python interpreter knows the actual executable path
if sys.executable != INTERP: os.execl(INTERP, INTERP, *sys.argv)

#print("derp")

from __init__ import app as application

#print("derp2")
