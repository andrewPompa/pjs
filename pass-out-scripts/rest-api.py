#!/usr/bin/python
# -*- coding: utf-8
import json
import sys

import re

import datetime
import requests
from flask import Flask, jsonify, make_response

try:
    import yaml
except ImportError as e:
    print(e)

app = Flask(__name__)
config_file = ""
port = 5000


def print_help():
    print("API REST'owe pobierające z bazy firebase informacje o tym "
          "kto, kiedy i skąd próbował dostać się do naszego serwera")
    print("Użycie: ")
    print("%s app.yml [-p port]" % sys.argv[0])
    print("-h | --help pomoc")
    print("app.yml plik konfiguracyjny zawierający dane do firebase")
    print("\tdatabase.url - adres bazy danych")
    print("\tdatabase.key - API KEY naszej aplikacji")
    print("\tdatabase.user.email adres e-mail zarejestrowanego w firebase użytkownika")
    print("\tdatabase.user.password hasło zarejestrowanego w firebase użytkownika")
    print("-p port [opcjonalnie] numer portu na którym ma być uruchomione nasze API")


def parse_yaml():
    f = open(config_file)
    print("[INFO] Pobrano plik konfiguracyjny")
    return yaml.load(f)


should_change_port = False
port_changed = False
for argument in sys.argv[1:]:
    if argument == '-h' or argument == '--help':
        print_help()
        sys.exit(0)
    elif re.match("^.*\.(yml|yaml)", argument):
        config_file = argument
    elif argument == '-p':
        should_change_port = True
    elif re.match("\d+", argument):
        port_changed = True
        port = argument
    print(argument)

# print("-p: %s, p: %s, yaml: %s" % (should_change_port, port_changed, config_file))
if config_file == "" or \
        (should_change_port is True and port_changed is False) or \
        (should_change_port is False and port_changed is True):
    sys.stderr.write("[ERROR] Niepoprawna składnia\n")
    print_help()
    sys.exit(2)

tasks = [
    {
        'id': 1,
        'title': u'Buy groceries',
        'description': u'Milk, Cheese, Pizza, Fruit, Tylenol',
        'done': False
    },
    {
        'id': 2,
        'title': u'Learn Python',
        'description': u'Need to find a good Python tutorial on the web',
        'done': False
    }
]


def get_user_token(api_key, login, password):
    url = get_token_url(api_key)
    headers = {'Content-type': 'application/json'}
    payload = {'email': login, 'password': password, 'returnSecureToken': True}
    r = requests.post(url, json.dumps(payload), headers=headers)
    if not r.status_code == 200:
        sys.stderr.write("[ERROR] Nie można pobrać tokenu dla aplikacji!\n")
        exit(2)
    # response = json.load(r.json())
    return r.json()['idToken']


def get_data(database_url, id_token):
    url = get_database_url(database_url, id_token)
    r = requests.get(url)
    if not r.status_code == 200:
        sys.stderr.write("[ERROR] Nie można pobrać danych!\n")
        return None
    return r.json()


def get_token_url(api_key):
    return "https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=%s" % api_key


def get_database_url(database_url, id_token):
    return "%s?auth=%s" % (database_url, id_token)


def find_ip(data, ip):
    for key in data:
        for timestamp in data[key]:
            print(data[key][timestamp]['ip'])


@app.route('/login-info/date/<string:date>', methods=['GET'])
def get_info_by_date(date):
    try:
        datetime_object = datetime.datetime.strptime(date, "%d-%m-%Y")
    except ValueError:
        return make_response(jsonify({'error': 'Niepoprwana składnia'}), 400)
    print(datetime_object.day)
    print(datetime_object.time())
    return jsonify({'tasks': tasks})


@app.route('/login-info/ip/<string:ip>', methods=['GET'])
def get_info_by_ip(ip):
    if not re.match("^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$", ip):
        return make_response(jsonify({'error': 'Niepoprwana składnia'}), 400)
    print(ip)
    user_token = get_user_token(data_map['database']['key'],
                                data_map['database']['user']['email'],
                                data_map['database']['user']['password'])
    data = get_data(data_map['database']['url'], user_token)
    if data is None:
        return make_response(jsonify({'error': 'Nie można pobrać danych z bazy'}), 500)
    find_ip(data, ip)
    return jsonify({'tasks': tasks})


data_map = parse_yaml()

if __name__ == '__main__':
    app.run(port=int(port))
