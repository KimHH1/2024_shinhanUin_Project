# -*- coding: utf-8 -*-

from flask import Flask, request, jsonify
import json

app = Flask(__name__)

user_id = None  # 전역 변수로 userId 저장

# 데이터를 저장할 파일 경로 설정
DATA_FILE_PATH = 'received_data.json'
RATING_DATA_FILE_PATH = 'rating_data.json'  # rating 데이터를 저장할 파일 경로

@app.route('/', methods=['POST'])
def receive_data():
    global user_id
    data = request.get_json()
    print(f"Received data: {data}")  # 수신한 전체 데이터 로그

    if data:  # 데이터가 None이 아닐 때
        print("Data format is valid.")
        if 'userId' in data:  # 'userId' 키가 있는지 확인
            user_id = data['userId']
            print(f"Received userId: {user_id}")
            
            # CurrentCourse가 있는 경우 데이터를 파일에 저장 (파일 쓰기 최적화)
            if 'city' in data:
                with open(DATA_FILE_PATH, 'w', encoding='utf-8') as file:
                    json.dump(data, file, ensure_ascii=False)  # indent 옵션 제거로 속도 최적화
                print("CurrentCourse data saved successfully.")
            
            # rating 필드가 있는 경우 rating 데이터를 별도 파일에 저장
            if 'rating' in data:
                rating_data = {
                    'userId': user_id,
                    'rating': data['rating']
                }
                with open(RATING_DATA_FILE_PATH, 'w', encoding='utf-8') as rating_file:
                    json.dump(rating_data, rating_file, ensure_ascii=False)
                print("Rating data saved successfully.")

            return jsonify(message="Data received successfully!"), 200
        else:
            print("userId is missing in the data.")
            return jsonify(message="Data format error: 'userId' is missing"), 400
    else:
        print("No data received.")
        return jsonify(message="Data format error: No data received"), 400

@app.route('/user_id', methods=['GET'])
def get_user_id():
    return jsonify(userId=user_id), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=2000)

