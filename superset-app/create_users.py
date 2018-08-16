import csv
import sys
import requests
from bs4 import BeautifulSoup

auth_payload = {'username':'admin', 'password':'pa55word'}


if __name__ == '__main__':
    filename = sys.argv[1]
    print(filename)

    with requests.Session() as session:
        r = session.get('http://demo-app.staging.savvybi.enterprises/login/')
        soup = BeautifulSoup(r.text, 'html.parser')
        csrf_token = soup.find('input', {'id':'csrf_token'})['value']
        auth_payload = {'username':'admin', 'password':'pa55word', 'csrf_token':csrf_token}
        r = session.post('http://demo-app.staging.savvybi.enterprises/login/', data=auth_payload)

        print("logged in")

        with open(filename, 'rb') as users:
            reader = csv.reader(users)
            next(reader)
            for user_row in users:
                user = user_row.split(',')
                print(user[0])

                r = session.get('http://demo-app.staging.savvybi.enterprises/users/add')

                soup = BeautifulSoup(r.text, 'html.parser')
                csrf_token = soup.find('input', {'id':'csrf_token'})['value']

                form_data = {
                    'first_name':('',user[0]),
                    'last_name':('',user[1]),
                    'username':('',user[2]),
                    'active':('','y'),
                    'email':('',user[3]),
                    'roles':('',user[4]),
                    'password':('','pa55word'),
                    'conf_password':('','pa55word'),
                    'csrf_token':('',csrf_token)
                }
                r = session.post('http://demo-app.staging.savvybi.enterprises/users/add', files=form_data)
