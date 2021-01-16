import os
import json
import utils
import boto3
import datetime
dynamodb = boto3.resource('dynamodb')

def list(event, context):
    name_module = "client"
    table = dynamodb.Table(os.environ['DYNAMODB_TABLE'])
    response = table.scan()
    result = response['Items']

    clients = []
    for client in result:
        b_arr = client['birthday'].split('/')
        format_birthday = datetime.date(int(b_arr[2]),int(b_arr[1]),int(b_arr[0]))
        client.update({'yaers':utils.calculateAge(format_birthday)})
        clients.append(client)

    # create a response
    response = utils.response(name_module, clients, 'list')

    return response