import csv
from datetime import datetime


def normalize_date(date_string):
    date_object = datetime.strptime(date_string, "%B %d, %Y")

    # Step 3: Format the datetime object into the desired string format
    return date_object.strftime("%Y%m%d")


def ingest(csv_file, dynamodb):
    last_event_name = None
    with open(csv_file, 'r') as file:
        reader = csv.reader(file)
        headers = next(reader)
        card_placement = 1
        for row in reader:
            try:
                event_name, date = row[0].split('  ')
                data = {
                    "event_name": event_name, "card_placement": str(card_placement),
                    "date": date,
                    "winner": row[2], "loser": row[3], "w_str": row[4],
                    "l_str": row[5], "w_kd": row[6], "l_kd": row[7],
                    "w_ctrl": row[8], "l_ctrl": row[9], "w_td": row[10],
                    "l_td": row[11], "w_subatt": row[12], "l_subatt": row[13],
                    "w_rev": row[14], "l_rev": row[15], "weight_class": row[16],
                    "method": row[17], "round": row[18], "time": row[19]
                }

                if event_name != last_event_name:
                    card_placement = 1
                else:
                    card_placement = card_placement + 1

                insert_event(data, dynamodb)
                insert_fighter_wins(data, dynamodb)
                insert_figher_losses(data, dynamodb)
                last_event_name = event_name



            except:
                raise


def insert_fighter_wins(data, dynamodb):
    dynamodb.put_item(
        TableName='ufc_fights_xyz',
        Item={
            'fighter_name': {'S': data["winner"]},
            'fight_date': {'S': normalize_date(data["date"])},
            'opponent': {'S': data["loser"]},
            'str': {'S': data["w_str"]},
            'opponent_str': {'S': data["l_str"]},
            'kd': {'S': data["w_kd"]},
            'opponent_kd': {'S': data["l_kd"]},
            'ctrl': {'S': data["w_ctrl"]},
            'opponent_ctrl': {'S': data["l_ctrl"]},
            'td': {'S': data["w_td"]},
            'opponent_td': {'S': data["l_td"]},
            'subatt': {'S': data["w_subatt"]},
            'opponent_subatt': {'S': data["l_subatt"]},
            'rev': {'S': data["w_rev"]},
            'opponent_rev': {'S': data["l_rev"]},
            'weight_class': {'S': data["weight_class"]},
            'method': {'S': data["method"]},
            'round': {'S': data["round"]},
            'time': {'S': data["time"]}
        }
    )


def insert_figher_losses(data, dynamodb):
    dynamodb.put_item(
        TableName='ufc_fights_xyz',
        Item={
            'fighter_name': {'S': data["loser"]},
            'fight_date': {'S': normalize_date(data["date"])},
            'opponent': {'S': data["winner"]},
            'str': {'S': data["l_str"]},
            'opponent_str': {'S': data["w_str"]},
            'kd': {'S': data["l_kd"]},
            'opponent_kd': {'S': data["w_kd"]},
            'ctrl': {'S': data["l_ctrl"]},
            'opponent_ctrl': {'S': data["w_ctrl"]},
            'td': {'S': data["l_td"]},
            'opponent_td': {'S': data["w_td"]},
            'subatt': {'S': data["l_subatt"]},
            'opponent_subatt': {'S': data["w_subatt"]},
            'rev': {'S': data["l_rev"]},
            'opponent_rev': {'S': data["w_rev"]},
            'weight_class': {'S': data["weight_class"]},
            'method': {'S': data["method"]},
            'round': {'S': data["round"]},
            'time': {'S': data["time"]}
        }
    )


def insert_event(data, dynamodb):
    dynamodb.put_item(
        TableName='ufc_matches_xyz',
        Item={
            'event_name': {'S': data["event_name"]},
            'card_placement': {'N': data["card_placement"]},
            'date': {'S': data["date"]},
            'winner': {'S': data["winner"]},
            'loser': {'S': data["loser"]},
            'w_str': {'S': data["w_str"]},
            'l_str': {'S': data["l_str"]},
            'w_kd': {'S': data["w_kd"]},
            'l_kd': {'S': data["l_kd"]},
            'w_ctrl': {'S': data["w_ctrl"]},
            'l_ctrl': {'S': data["l_ctrl"]},
            'w_td': {'S': data["w_td"]},
            'l_td': {'S': data["l_td"]},
            'w_subatt': {'S': data["w_subatt"]},
            'l_subatt': {'S': data["l_subatt"]},
            'w_rev': {'S': data["w_rev"]},
            'l_rev': {'S': data["l_rev"]},
            'weight_class': {'S': data["weight_class"]},
            'method': {'S': data["method"]},
            'round': {'S': data["round"]},
            'time': {'S': data["time"]}
        }
    )
