#!/usr/bin/python
# -*- coding: utf-8
import json
import sys

import re

import datetime
import requests
from flask import Flask, jsonify, make_response


class LoginInfo:
    ip = ''
    country = ''
    city = ''
    zip_code = ''
    user_to_log = ''
    dates = []

    def __init__(self, ip, country, city, zip_code, user_to_log):
        self.ip = ip
        self.country = country
        self.city = city
        self.zip_code = zip_code
        self.user_to_log = user_to_log
        self.dates = []

    def add_date(self, new_date, result):
        for date in self.dates:
            if date.date == new_date:
                # print("adding to exitsting")
                date.add_attempt(result)
                return
        # print("adding new")
        self.dates.append(Date(new_date, result))

    def print_info(self):
        str_to_return = "============================\n"
        str_to_return += ("Komputer o IP: %s, z %s(%s), o kodzie: %s, próbował zalogować się na użytkownika: %s\n" %
              (str(self.ip), str(self.city), str(self.country), str(self.zip_code), str(self.user_to_log)))
        for date in self.dates:
            str_to_return += (date.print_info())
        str_to_return += "============================\n"
        return str_to_return


class Date:
    date = ''
    ok_attempts = 0
    bad_attempts = 0

    def __init__(self, date, attempt):
        self.date = date
        if attempt == "failure":
            # print("failure")
            self.ok_attempts = 0
            self.bad_attempts = 1
        else:
            self.ok_attempts = 1
            self.bad_attempts = 0

    def add_attempt(self, result):
        if result == "failure":
            # print("failure")
            self.bad_attempts = self.bad_attempts + 1
        else:
            self.ok_attempts = self.ok_attempts + 1

    def print_info(self):
        return "W dniu %s, udanych prób zalogowania: %d, nieudanych: %d\n" % \
               (str(self.date), int(self.ok_attempts), int(self.bad_attempts))


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

# print("-p: %s, p: %s, yaml: %s" % (should_change_port, port_changed, config_file))
if config_file == "" or \
        (should_change_port is True and port_changed is False) or \
        (should_change_port is False and port_changed is True):
    sys.stderr.write("[ERROR] Niepoprawna składnia\n")
    print_help()
    sys.exit(2)


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
    individual = None
    for key in data:
        for timestamp in data[key]:
            # print("checking %s with %s" % (ip, data[key][timestamp]['ip']))
            if data[key][timestamp]['ip'] == ip:
                # print("got same guy")
                if individual is None:
                    # print("initializing")
                    individual = LoginInfo(ip,
                                           data[key][timestamp]['country_name'],
                                           data[key][timestamp]['city'],
                                           data[key][timestamp]['zip_code'],
                                           data[key][timestamp]['user'])
                date = datetime.datetime.fromtimestamp(float(timestamp)).strftime('%d-%m-%Y')
                # print(date)
                individual.add_date(date, data[key][timestamp]['result'])
    return individual


@app.route('/login-info/date/<string:date>', methods=['GET'])
def get_info_by_date(date):
    try:
        datetime_object = datetime.datetime.strptime(date, "%d-%m-%Y")
    except ValueError:
        return make_response(jsonify({'error': 'Niepoprawna składnia'}), 400)
    print(datetime_object.day)
    print(datetime_object.time())
    return ""


@app.route('/login-info/ip/<string:ip>', methods=['GET'])
def get_info_by_ip(ip):
    if not re.match("^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$", ip):
        return make_response(jsonify({'error': 'Niepoprawna składnia'}), 400)
    print(ip)
    user_token = get_user_token(data_map['database']['key'],
                                data_map['database']['user']['email'],
                                data_map['database']['user']['password'])
    data = get_data(data_map['database']['url'], user_token)
    if data is None:
        return make_response(jsonify({'error': 'Nie można pobrać danych z bazy :('}), 500)
    computer = find_ip(data, ip)

    return computer.print_info()


data_map = parse_yaml()

if __name__ == '__main__':
    app.run(port=int(port))
