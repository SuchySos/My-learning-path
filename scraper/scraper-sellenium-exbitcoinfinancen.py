from bs4 import BeautifulSoup
from selenium.webdriver import Chrome
from datetime import datetime, timedelta
import time
import pandas as pd


def check_for_last_first_digit(element, first_digit):
    while element[first_digit].isdigit() is False:
        first_digit -= 1
    first_digit += 1
    last_digit = first_digit - 1

    while element[last_digit].isdigit() is True or element[last_digit] == ',' or element[last_digit] == '.':
        if element[last_digit] == '.':
            dot = last_digit
        if element[last_digit] == ',':
            comma = last_digit
        last_digit -= 1
    last_digit += 1

    return first_digit, last_digit, dot, comma


def check_element_for_minutes(url, tag, httpclass, inclass, minutes, interval, save):
    '''
    The function is used to scrape data that change in real time and saves them in a candle chart format.

    :param url: your url
    :param tag: 'div', 'span' etc.
    :param httpclass: class inside tag, helps to find current tag
    :param inclass: value in previously given class

    :param minutes: how many minutes function should work expects number
    :param interval: interval between measurements in s
    :param save: expects str or 'False'
            saves to .csv with given name

    :return: #166 examples of output #132 raw scraped data
    '''

    # Checking inputs
    checks = {
        'url': (url, str, 'url is not a string'),
        'tag': (tag, str, 'tag is not a string'),
        'httpclass': (httpclass, str, 'httpclass is not a string'),
        'inclass': (inclass, str, 'inclass is not a string'),
        'minutes': (minutes, int, 'minutes is not an integer'),
        'interval': (interval, int, 'minutes is not an integer'),
        'save': (save, (str, bool), 'save is not a string or bool')
    }

    for var, (value, expected_type, error_message) in checks.items():
        if not isinstance(value, expected_type):
            print(error_message)
            quit()
        else:
            print(var, 'type pass')
    if minutes < 1 or interval < 1:
        print('minutes and interval must be bigger than 0')
        quit()

    # Initialize Google Chrome and open the page
    driver = Chrome()
    driver.get(url)
    time.sleep(3)

    # Defining format, searching for digits
    soup = BeautifulSoup(driver.page_source, 'lxml')

    try:
        element = soup.find(tag, {httpclass: inclass})
    except Exception as e:
        print(f"error: {e}")
        quit()

    element = str(element)
    first_digit = -1

    first_digit, last_digit, dot, comma = check_for_last_first_digit(element, first_digit)

    if dot > comma:  # dot and comma are their place in string, defines what is decimal separator
        form = True
    else:
        form = False

    # Empty table for data in candlestick format every 1 min
    candle1m = pd.DataFrame(columns=['Datetime', 'Open', 'High', 'Low', 'Close', 'Median'])

    current_time = datetime.now()
    time_to_next_min = (60 - current_time.second) % 60
    print('Program starts in: ' + str(time_to_next_min) + ' s')
    print('First respond in: ' + str(time_to_next_min + 60) + ' s')
    time.sleep(time_to_next_min)

    # Main loop
    for i in range(minutes):
        # Specify time duration
        current_time = datetime.now()
        time_to_next_min = (60 - current_time.second) % 60
        if time_to_next_min != 0:
            end_time = time.time() + time_to_next_min
        else:
            end_time = time.time() + 60

        # Empty table for raw data
        df = pd.DataFrame(columns=['date', 'value'])

        while time.time() < end_time:
            try:
                soup = BeautifulSoup(driver.page_source, 'lxml')
                element = soup.find(tag, {httpclass: inclass})

                # Changing the data format
                element = str(element)
                first_digit, last_digit, dot, comma = check_for_last_first_digit(element, first_digit)
                element = element[last_digit:first_digit]

                if form is False:  # Correct decimal separator
                    element = element.replace('.', '')
                    element = float(element.replace(',', '.'))
                else:
                    element = float(element.replace(',', ''))

                # Prevent overlap - it seems to be in a random place, but it's not
                if time.time() >= (end_time-0.8):
                    time.sleep(1)
                    break

                current_time = datetime.now()
                formatted_time = str(current_time.strftime("%Y-%m-%d %H:%M:%S"))
                # print(formatted_time + ' ' + str(element))  # Display the current value
                df.loc[formatted_time, 'value'] = element
                time.sleep(interval-0.25)  # Waits x seconds before checking the item again

            except Exception as e:
                print(f"error: {e}")

        open = df.iloc[1, 1]            # Organizing raw data
        high = df['value'].max()
        low = df['value'].min()
        close = df.iloc[-1, 1]
        median = df['value'].median()

        current_time = current_time.replace(second=0)   # Time fix
        current_time = current_time + timedelta(minutes=1)
        formatted_time = str(current_time.strftime("%Y-%m-%d %H:%M:%S"))

        # New data to add
        new_data = {
            'Datetime': [formatted_time],
            'Open': [open],
            'High': [high],
            'Low': [low],
            'Close': [close],
            'Median': [median]
        }

        # Adding new data to an existing DataFrame
        candle1m = candle1m._append(pd.DataFrame(new_data), ignore_index=True)

        if save is not False:
            save = str(save) + '.csv'
            candle1m.to_csv(save, sep=',')

        # Examples of output
        print(pd.DataFrame(new_data))
        print(candle1m)

    driver.quit()


check_element_for_minutes('https://www.finanzen.net/devisen/realtimekurs/bitcoin-euro-kurs', 'div', 'data-field', 'Bid', 5, 1, '1mindataframe')
# for Ask price     - 'div', 'data-field', 'Ask'
# for current price - 'span', 'data-format', 'minimumFractionDigits:4'
