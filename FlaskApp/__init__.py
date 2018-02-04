from flask import Flask, request, render_template, redirect, url_for, flash
from flask_sqlalchemy import SQLAlchemy
from flask_admin import Admin, AdminIndexView, expose
from flask_admin.contrib.sqla.view import ModelView, func
from flask_login import LoginManager, login_user , logout_user , current_user , login_required
from models import Group, User, db, Click
from datetime import datetime, timedelta
from wtforms import PasswordField, HiddenField
from wtforms.validators import InputRequired
import re
import os

# https://blog.openshift.com/use-flask-login-to-add-user-authentication-to-your-python-application/

def create_app():
    db_user = os.environ['app_db_user']
    db_pw   = os.environ['app_db_pass']
    db_host = os.environ['app_db_host']
    db_name = os.environ['app_db_name']

    if db_user == None or db_pw == None:
        db_uri = "sqlite:////tmp/flask.db" 
    else:
        db_uri = "mysql://" + db_user + ":" + db_pw + "@" + db_host + "/" + db_name

    print("Connecting to " + db_uri)

    app = Flask(__name__)
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
    app.config['SQLALCHEMY_DATABASE_URI'] = db_uri
    app.secret_key = 'L6wK8IN.AQV0kyR5QkaHIyS^&gbHiC&wnaRAow.&(ik8))ncIfVs0Pf%c@OTm2VYM)n.2Pb0'
    db.init_app(app)
    with app.app_context():
        db.create_all()
    return app

app = create_app()

def add_admin(name, password):
    create_app().app_context().push()
    superuser = User()
    superuser.name = name
    superuser.password = password
    superuser.admin = True
    db.session.add(superuser)
    db.session.commit()

class MyHomeView(AdminIndexView):
    def is_accessible(self):
        if current_user.is_authenticated and current_user.admin:
            return True
        return False

    def inaccessible_callback(self, name, **kwargs):
        return redirect(url_for('adminlogin', next=request.url))


class AdminModelView(ModelView):
    can_export = True
    can_set_page_size = True
    def is_accessible(self):
        return current_user.is_authenticated

    def inaccessible_callback(self, name, **kwargs):
        return redirect(url_for('adminlogin', next=request.url))



class AdminModelView_admin(AdminModelView):
    can_export = False
    column_exclude_list = ('password','group', 'admin')
    form_extra_fields = {
        'password': PasswordField('Password', validators=[InputRequired()]),
        'admin': HiddenField(default=True)
    }
    form_columns = ('admin', 'name', 'password', 'puzzle_lever', 'puzzle_towers', 'clicks')
    def get_query(self):
        return self.session.query(self.model).filter(self.model.admin==True)
    def get_count_query(self):
        return self.session.query(func.count('*')).filter(self.model.admin==True)

class AdminModelView_user(AdminModelView):
    column_export_exclude_list = ('password','admin')
    column_exclude_list = ('password','admin')
    form_columns = ('name', 'group', 'puzzle_lever', 'puzzle_towers', 'clicks')
    column_list = ('name', 'group' , 'puzzle_lever', 'puzzle_towers', 'creation_time')
    def get_query(self):
        return self.session.query(self.model).filter(self.model.admin==False)
    def get_count_query(self):
        return self.session.query(func.count('*')).filter(self.model.admin==False)


admin = Admin(app,index_view=MyHomeView())

admin.add_view(AdminModelView_admin(User, db.session, name='Admin', endpoint='admin_user'))
admin.add_view(AdminModelView(Group, db.session))
admin.add_view(AdminModelView_user(User, db.session))
admin.add_view(AdminModelView(Click, db.session))

login_manager = LoginManager()
login_manager.init_app(app)
login_manager.login_view = 'login'

@login_manager.user_loader
def load_user(id):
    user = User.query.get(int(id))
    return user

@app.route('/login',methods=['GET','POST'])
def login():
    error = ''
    if current_user.is_authenticated:
        return redirect(url_for('menu'))
    if request.method == 'GET':
        return render_template('login.html')
    group = request.form['group']
    username = request.form['username']
    registered_group = Group.query.filter_by(name=group).first()
    if registered_group is None:
        error = 'Invalid group'
    elif registered_group.start_date>datetime.now():
        error = 'Group not yet available'
    elif registered_group.end_date<datetime.now():
        error = 'Group no longer available'
    else:
        pattern = re.compile(registered_group.regex)
        user = User.query.filter_by(name=username).first()
        if user==None:
            if pattern.match(username):
                user = User()
                user.name = username
                user.group_id = registered_group.id
                db.session.add(user)
                db.session.commit()
            else:
                error = 'Invalid username'
        elif user.group_id != registered_group.id:
            error = 'Invalid username'

    if error != '':
        return render_template('login.html',error=error)
    """
    user_number = db.session.query(db.func.max(User.user_number)).scalar()
    if user_number != None: user_number+=1
    else: user_number = 1
    user = User(user_number, registered_group.id)
    db.session.add(user)
    db.session.commit()
    """

    login_user(user)
    return redirect(url_for('menu'))

@app.route('/adminlogin',methods=['GET','POST'])
def adminlogin():
    error = ''
    if current_user.is_authenticated and current_user.admin:
        return redirect('/admin/')
    if request.method == 'GET':
        return render_template('adminlogin.html')
    username = request.form['username']
    password = request.form['password']
    user = User.query.filter_by(name=username).first()
    if (user is None) or (user.password != password):
        error = 'Invalid username or password'
        return render_template('adminlogin.html',error=error)
    login_user(user)
    return redirect('/admin')

@app.route('/')
@login_required
def menu():
    return render_template("index.html")

@app.route('/leverproblem',methods=['GET','POST'])
@login_required
def leverproblem():
    if request.method == 'GET':
        if current_user.puzzle_lever == True:
            return redirect(url_for('menu'))
        return render_template("leverproblem.html")
    if request.form['complete'] == 'true':
        current_user.puzzle_lever = True
    logClick('levers',int(request.form['item']),int(request.form['move']))
    return 'click logged'

@app.route('/towers',methods=['GET','POST'])
@login_required
def towers():
    if request.method == 'GET':
        if current_user.puzzle_towers == True:
            return redirect(url_for('menu'))
        return render_template("towers.html")
    if request.form['complete'] == 'true':
        current_user.puzzle_towers = True
    logClick('towers',int(request.form['item']),int(request.form['move']))
    return 'click logged'

@app.route('/logout')
@login_required
def logout():
    logout_user()
    return redirect(url_for('login'))

def logClick(puzzle, item, number):
    log = Click()
    log.user_id = current_user.id
    log.puzzle = puzzle
    log.item = item
    log.number = number
    db.session.add(log)
    db.session.commit()

if __name__ == "__main__":
    app.debug = True
    app.run()
    pass
