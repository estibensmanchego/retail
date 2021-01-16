import os
import json
import utils
import boto3
import datetime
dynamodb = boto3.resource('dynamodb')

def kpi(event, context):
    name_module = "client"
    table = dynamodb.Table(os.environ['DYNAMODB_TABLE'])
    response = table.scan()
    clients = response['Items']

    total_cli = len(clients)
    suma_tot_cli = 0
    years_data = []
    for client in clients:
        b_arr = client['birthday'].split('/')
        format_birthday = datetime.date(int(b_arr[2]),int(b_arr[1]),int(b_arr[0]))
        years = utils.calculateAge(format_birthday)
        years_data.append(years)
        suma_tot_cli += int(years)

    media = suma_tot_cli / total_cli

    #data
    data = {
        "averageAge": media,
        "standardDeviation": utils.standardDeviation(years_data, media)
    }

    # create a response
    response = utils.response(name_module, data, 'authorization')

    return response