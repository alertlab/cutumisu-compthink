from __init__ import add_admin
from sqlalchemy.exc import IntegrityError
import getpass

username = raw_input('Username:')
while True:
    password = getpass.getpass()
    if password == getpass.getpass('Confirm password:'):
        break
    else:
        print('Passwords did not match.')

try:
    add_admin(username, password)
    print("Superuser '" + username + "' created.")
except IntegrityError:
    print('User with that name already exists.')
