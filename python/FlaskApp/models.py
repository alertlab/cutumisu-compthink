from flask_sqlalchemy import SQLAlchemy
from datetime import datetime

# https://blog.openshift.com/use-flask-login-to-add-user-authentication-to-your-python-application/

db = SQLAlchemy()

class Group(db.Model):
    __tablename__ = 'group'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(80), unique=True, nullable=False)
    regex = db.Column(db.String(80), unique=False, nullable=False)
    start_date = db.Column(db.DateTime, nullable=False)
    end_date = db.Column(db.DateTime, nullable=False)
    users = db.relationship("User", backref="group")

    def __repr__(self):
        return '<Group %r>' % (self.name)

class User(db.Model):
    __tablename__ = 'user'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(80), unique=True, nullable=False)
    password = db.Column(db.String(80), nullable=True)
    group_id = db.Column(db.Integer, db.ForeignKey('group.id'))
    puzzle_lever = db.Column(db.Boolean, default=False)
    puzzle_towers = db.Column(db.Boolean, default=False)
    creation_time = db.Column(db.DateTime, nullable=False, default=datetime.now())
    clicks = db.relationship("Click", cascade="all,delete", backref="user")
    admin = db.Column(db.Boolean, nullable=False, default=False)

    def __repr__(self):
        if self.admin:
            return '<Admin %r>' % (self.name)
        return '<User %r>' % (self.name)

    def is_authenticated(self):
        return True

    def is_active(self):
        return True

    def is_anonymous(self):
        return False

    def get_id(self):
        return str(self.id)

class Click(db.Model):
    __tablename__ = 'click'
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    puzzle = db.Column(db.String(40), nullable=False)
    item = db.Column(db.Integer)
    number = db.Column(db.Integer)
    time = db.Column(db.DateTime, nullable=False)

    def __init__(self):
        self.time = datetime.now()


if __name__ == "__main__":
    pass
