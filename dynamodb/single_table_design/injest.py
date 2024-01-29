import csv

from schema import TABLE


def ingest_events(csv_file, dynamodb):
    last_event_name = None
    with open(csv_file, 'r') as file:
        reader = csv.reader(file)
        next(reader)
        card_placement = 1
        nrows = []
        for row in reader:
            try:
                data = build_dict(card_placement, row)

                if data["event_name"] != last_event_name:
                    dynamodb.put_item(
                        TableName=TABLE,
                        Item={
                            'PK': {'S': f'event#{data["event_name"]}'},
                            'SK': {'S': data["date"]},
                            'type': {'S': 'event'},
                            'event_name': {'S': data["event_name"]},
                            'date': {'S': data["date"]},
                            'matches': {'L': [
                                {"M": {k: {'S': str(v)} for k, v in nr.items()}} for nr in nrows
                            ]}
                        }
                    )

                    card_placement = 1
                    nrows = []
                    nrows.append(data)
                else:
                    nrows.append(data)
                    card_placement = int(card_placement + 1)

                last_event_name = data['event_name']

            except:
                raise


        dynamodb.put_item(
            TableName=TABLE,
            Item={
                'PK': {'S': f'event#{data["event_name"]}'},
                'SK': {'S': data["date"]},
                'type': {'S': 'event'},
                'event_name': {'S': data["event_name"]},
                'date': {'S': data["date"]},
                'matches': {'L': [
                    {"M": {k: {'S': str(v)} for k, v in nr.items()}} for nr in nrows
                ]}
            }
        )

def build_dict(card_placement, row):
    data = {}
    data["event_name"] = row[0].split('  ')[0]
    data["date"] = row[0].split('  ')[1]
    data["winner"] = row[2]
    data["loser"] = row[3]
    data["w_str"] = row[4]
    data["l_str"] = row[5]
    data["w_kd"] = row[6]
    data["l_kd"] = row[7]
    data["w_ctrl"] = row[8]
    data["l_ctrl"] = row[9]
    data["w_td"] = row[10]
    data["l_td"] = row[11]
    data["w_subatt"] = row[12]
    data["l_subatt"] = row[13]
    data["w_rev"] = row[14]
    data["l_rev"] = row[15]
    data["weight_class"] = row[16]
    data["method"] = row[17]
    data["round"] = row[18]
    data["time"] = row[19]
    data["card_placement"] = card_placement
    return data
