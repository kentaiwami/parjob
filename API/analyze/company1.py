from model import *
import subprocess
import os
import mojimoji
import xml.etree.ElementTree as ET
from datetime import datetime as DT
import datetime


tmp_file_path = ''


def create_main(company_id, title, number, start, end, file):
    global tmp_file_path

    _, file_ext = os.path.splitext(file.filename)
    tmp_file_path = 'uploads/tmp/company_{}{}'.format(company_id, file_ext)
    file.save(tmp_file_path)

    try:
        results = subprocess.check_output(['pdf2txt.py', tmp_file_path, '-t', 'xml'])
    except ValueError:
        os.remove(tmp_file_path)
        raise Exception('解析コマンドの実行中にエラーが発生しました')

    page = ET.fromstring(results)[0]

    x_y_text_list = get_x_y_text_from_xml(page)
    same_line_list, day_line_index = get_same_line_list(x_y_text_list)
    day_x_list = get_day_x(start, same_line_list, day_line_index)
    users_line = get_user_line(company_id, same_line_list, day_x_list[0]['x'], number)
    should_join_shift = get_should_join_shift(users_line)

    # TODO 日付ごとにシフトをまとめる（その際に、結合も考慮）
    users_shift_list = get_user_shift(users_line, day_x_list, should_join_shift)

    # TODO 空文字を連結する処理




    # hoge = open('sample/test.txt', 'w')
    # for hhh in x_sorted_same_line_list:
    #     for abc in hhh:
    #         hoge.write('{}({}) '.format(abc['text'], abc['x']))
    #     hoge.write('\n')

    # table = ShiftTable(title=title, company_id=company_id)
    # session.add(table)
    # session.commit()
    #
    # return table
    # raise ValueError
    os.remove(tmp_file_path)


def get_x_y_text_from_xml(page):
    """
    xmlからx,y,textを抽出した結果をリストとして返す
    :param page:    ElementTreeで抽出したxml
    :return:        x,y,textの辞書が格納された1次元配列
    """

    x_y_text_list = []
    for textbox in page:
        for textline in textbox:
            for text in textline:
                if text.text != '\n' and 'bbox' in text.attrib:
                    bbox = text.attrib['bbox'].split(',')
                    x_y_text_list.append({
                        'x': float(bbox[0]),
                        'y': float(bbox[1]),
                        'text': mojimoji.zen_to_han(text.text, kana=False)
                    })

    if len(x_y_text_list) == 0:
        os.remove(tmp_file_path)
        raise Exception('情報抽出中にエラーが発生しました')

    return x_y_text_list


def get_same_line_list(x_y_text_list):
    """
    x, yの値で並び替えを行い、日付が記述されている箇所の判定を行う
    :param x_y_text_list:   x,y,textの辞書が格納された1次元配列
    :return:                xでソート済みの同じ行ごとにまとめたx_y_text_list, 日付が記述されている配列番号
    """

    threshold_y = 3.0

    x_y_text_list = sorted(x_y_text_list, key=lambda dict: dict['y'], reverse=True)

    current_y = x_y_text_list[0]['y']
    same_line_list = []
    tmp_same_one_line = []

    for x_y_text in x_y_text_list:
        if abs(x_y_text['y'] - current_y) <= threshold_y:
            tmp_same_one_line.append(x_y_text)
        else:
            same_line_list.append(tmp_same_one_line)

            tmp_same_one_line = [x_y_text]
            current_y = x_y_text['y']

    # xで並び替え、日付が記述されている箇所（要素数）の特定
    x_sorted_same_line_list = []
    day_line_index = -1
    for i, same_line in enumerate(same_line_list):
        # まだ数字のみの行を見つけていない時のみ数値判定の検索を実施
        if day_line_index == -1:
            if len(list(filter(lambda x: x['text'].isdigit(), same_line))) == len(same_line):
                day_line_index = i

        x_sorted_same_line_list.append(sorted(same_line, key=lambda dict: dict['x'], reverse=False))

    if day_line_index == -1:
        os.remove(tmp_file_path)
        raise Exception('日付の判定中にエラーが発生しました')

    return x_sorted_same_line_list, day_line_index


def get_day_x(start, same_line_list, day_line_index):
    """
    日付の記載場所を判定して結果を返す
    :param start:                   postで受け取った開始日付
    :param same_line_list: xでソート済みの同じ行ごとにまとめた配列
    :param day_line_index:          日付が記述されている配列番号
    :return:                        日付と記載場所(x)を格納した1次元配列
    """

    start_date = DT.strptime(start, '%Y-%m-%d')
    day_x_list = []
    current_date = str(start_date.day)
    tmp_current_date = ''
    timedelta = 1
    for date_x_y_text in same_line_list[day_line_index]:
        tmp_current_date += date_x_y_text['text']

        if len(tmp_current_date) >= 3:
            os.remove(tmp_file_path)
            raise Exception('日付の解析中にエラーが発生しました')

        if current_date == tmp_current_date:
            day_x_list.append({'day': current_date, 'x': date_x_y_text['x']})

            tmp_current_date = ''
            current_date = str((start_date + datetime.timedelta(days=timedelta)).day)
            timedelta += 1

    return day_x_list


def get_user_line(company_id, same_line_list, first_day_limit, number):
    """
    ユーザ名が含まれている行のみを抽出し、ユーザ名の一致と各ユーザのシフトの開始位置を格納した2次元配列を返す
    :param company_id:          ユーザが属する企業のID
    :param same_line_list:      xでソート済みの同じ行ごとにまとめた配列
    :param first_day_limit:     シフトの最初の日付が記述されているxの値
    :param number:              取り込もうとしているシフト表に記載されているユーザの人数（POSTで受付）
    :return:
    """

    threshold_x = 10.0

    users = session.query(User).filter(User.company_id == company_id).order_by('order').all()
    users_line = []

    for user in users:
        for line in same_line_list[:]:
            # ユーザ名が含まれている文字列（日付より前）を抽出
            candidate_username = list(filter(lambda h: h['x'] < first_day_limit - threshold_x, line))
            candidate_username = [x['text'] for x in candidate_username]
            candidate_username = ''.join(candidate_username)

            if candidate_username.find(user.name) != -1:
                last_char_username = user.name[-1:]
                last_username_obj = next((item for item in line if item["text"] == last_char_username))
                shift_start_index = line.index(last_username_obj) + 1
                users_line.append({
                    'line': line,
                    'shift_start': shift_start_index,
                    'name': user.name
                })
                same_line_list.remove(line)
                break

    if number != len(users_line):
        os.remove(tmp_file_path)
        raise Exception('シフト表に記載されているユーザの人数が一致しません')

    return users_line


def get_should_join_shift(users_line):
    """
    全ユーザのシフト文字列から、連結した文字列（1つのシフト）とするべきものを判別して返す
    :param users_line:  全ユーザのシフトが記述された2次元配列
    :return:            全ユーザのシフトの連結開始・終了位置を辞書ごと格納した2次元配列
    """

    results = []
    threshold_x = 8.0

    for user in users_line:
        tmp_user_line = []
        shift_list = user['line'][user['shift_start']:]

        # 閾値より近いシフトを後で開始終了位置を判別するために（長い文字列への対応）、1次元配列へ格納していく
        candidate_join_shift = []
        for shift1, shift2 in zip(shift_list, shift_list[1:]):
            if abs(shift1['x'] - shift2['x']) <= threshold_x:
                candidate_join_shift.append(shift1)
                candidate_join_shift.append(shift2)
            else:
                tmp_user_line.append(shift1)

        # 連結すべき文字列の範囲を検出
        # ex.) 導, 入, 入, 研, 研, 修を「開始：導, 終了：修」として記録する
        search_index = 1
        join_start_end = []
        start = 0

        while search_index < len(candidate_join_shift) - 1:
            if candidate_join_shift[search_index] != candidate_join_shift[search_index+1]:
                join_start_end.append({'s': candidate_join_shift[start], 'e': candidate_join_shift[search_index]})
                start = search_index + 1

            search_index += 2

        join_start_end.append({'s': candidate_join_shift[start], 'e': candidate_join_shift[search_index]})
        results.append(join_start_end)

    return results


def get_user_shift(users_line, day_x_list, should_join_shift):
    """
    全ユーザのシフトを日付ごとにまとめる。結合セルがあった場合は空文字として登録する。
    :param users_line:          全ユーザのシフト情報が記載された2次元配列
    :param day_x_list:          日付の場所が記載された1次元配列
    :param should_join_shift:   aa
    :return:                    全ユーザ×全日付の2次元配列
    """

    threshold_x = 10.0
    results = []

    for user in users_line:
        shift_list = users_line[4]['line'][users_line[4]['shift_start']:]
        # shift_list = user['line'][user['shift_start']:]
        usr_result = []
        day_index = 0
        shift_index = 0
        tmp_current_day_shift = ''
        tmp_shift_x = 0.0
        tmp_shift_x_count = 0.0

        while len(day_x_list)-1 >= day_index and len(shift_list)-1 >= shift_index:
            print(shift_list[shift_index]['text'], day_x_list[day_index]['day'], tmp_current_day_shift)
            if abs(shift_list[shift_index]['x'] - day_x_list[day_index]['x']) <= threshold_x:
                tmp_current_day_shift += shift_list[shift_index]['text']
                tmp_shift_x += shift_list[shift_index]['x']
                tmp_shift_x_count += 1
                shift_index += 1
            else:
                usr_result.append({
                    'shift': tmp_current_day_shift,
                    'x': tmp_shift_x / tmp_shift_x_count
                })
                tmp_current_day_shift = ''
                tmp_shift_x = 0.0
                tmp_shift_x_count = 0.0
                day_index += 1

        results.append(usr_result)

        break

    # 全ユーザのシフトが日数分だけ存在するかチェック
    if len(list(filter(lambda x: len(x) != len(day_x_list), results))) != 0:
        raise Exception('シフトの抽出結果に誤りがあったためエラーが発生しました')

    for hoge in results:
        print(hoge)
        print('\n')
    return results


def update_main(table_id):
    print('update', table_id)

    table = session.query(ShiftTable).filter(ShiftTable.id == table_id).one()

    return {'origin': table.origin_path, 'thumbnail': table.thumbnail_path}
