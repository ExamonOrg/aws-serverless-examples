import csv



def ingest_trnx(csv_file, dynamodb):
    last_event_name = None
    with open(csv_file, 'r') as file:
        reader = csv.reader(file)
        headers = next(reader)
        card_placement = 1
        transaction_items = []
        for row in reader:
            try:
                event_name, date = row[0].split('  ')
                winner = row[2]
                loser = row[3]
                w_str = row[4]
                l_str = row[5]
                w_kd = row[6]
                l_kd = row[7]
                w_ctrl = row[8]
                l_ctrl = row[9]
                w_td = row[10]
                l_td = row[11]
                w_subatt = row[12]
                l_subatt = row[13]
                w_rev = row[14]
                l_rev = row[15]
                weight_class = row[16]
                method = row[17]
                round = row[18]
                time = row[19]

                if event_name != last_event_name:
                    card_placement = 1
                else:
                    card_placement = card_placement + 1

                transaction_items.append({
                    'Put': {
                        'TableName': 'ufc_matches',
                        'Item': {
                            'event_name': {'S': event_name},
                            'card_placement': {'N': str(card_placement)},
                            'date': {'S': date},
                            'winner': {'S': winner},
                            'loser': {'S': loser},
                            'w_str': {'S': w_str},
                            'l_str': {'S': l_str},
                            'w_kd': {'S': w_kd},
                            'l_kd': {'S': l_kd},
                            'w_ctrl': {'S': w_ctrl},
                            'l_ctrl': {'S': l_ctrl},
                            'w_td': {'S': w_td},
                            'l_td': {'S': l_td},
                            'w_subatt': {'S': w_subatt},
                            'l_subatt': {'S': l_subatt},
                            'w_rev': {'S': w_rev},
                            'l_rev': {'S': l_rev},
                            'weight_class': {'S': weight_class},
                            'method': {'S': method},
                            'round': {'S': round},
                            'time': {'S': time}
                        }
                    }
                })

                # DynamoDB transactions can handle up to 25 items at a time
                if len(transaction_items) == 25:
                    dynamodb.transact_write_items(TransactItems=transaction_items)
                    transaction_items = []

                last_event_name = event_name

            except Exception as e:
                print(f"Error processing row: {row}. Error: {str(e)}")
