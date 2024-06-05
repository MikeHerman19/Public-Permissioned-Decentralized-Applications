# flask_app.py
from flask import Flask, jsonify, request, render_template
from flask_cors import CORS
from calculation_script import get_vc

app = Flask(__name__)
CORS(app)


@app.route('/api/calculate', methods=['GET'])
def calculate():
    print("API aufgerufen")
    attrID = int(request.args.get('attrID'))
    print(attrID)
    attrWert = int(request.args.get('attrWert'))
    print(attrWert)
    issuer = request.args.get('issuer')
    print(issuer)
    result = get_vc(attrID, attrWert,issuer)
    print(result)
    return jsonify({'result': result})


#asdasdas

if __name__ == '__main__':
    app.run(debug=True)
