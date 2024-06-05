import hashlib
from zokrates_pycrypto.eddsa import PrivateKey, PublicKey
from zokrates_pycrypto.field import FQ
from zokrates_pycrypto.utils import write_signature_for_zokrates_cli
import struct
import sys

def write_signature_for_zokrates_cli(pk, sig, msg):
    "Writes the input arguments for verifyEddsa in the ZoKrates stdlib to file."
    sig_R, sig_S = sig
    args = [sig_R.x, sig_R.y, sig_S, pk.p.x.n, pk.p.y.n]
    args = " ".join(map(str, args))
    M0 = msg.hex()[:64]
    M1 = msg.hex()[64:]
    b0 = [str(int(M0[i:i+8], 16)) for i in range(0,len(M0), 8)]
    b1 = [str(int(M1[i:i+8], 16)) for i in range(0,len(M1), 8)]
    args = args + " " + " ".join(b0 + b1)
    return args

def get_vc(attrID,attrWert,issuer):


    attr = int.to_bytes(attrID, 64, "big") # attr id for zip code
    vc_value = int.to_bytes(attrWert, 64, "big")

    resultHash = hashlib.sha256(b"".join([attr[-32:], vc_value[-32:]])).digest()
    resultHash += resultHash

    if issuer == "Bundesdruckerei Deutschland":
        print("Bundesdruckerei Deutschland")
        privKey = PrivateKey(FQ(14164338519848721439767314822173706078318556622606192969303321324246830886198))
    elif issuer == "Technische Universität Berlin":
        print("TUB")
        privKey = PrivateKey(FQ(19935176680824634973519175935102431589534120448022907406436656995409843592992))
    else: 
        print("Else")
        privKey = PrivateKey.from_rand()

    #Sign Message with private Key
    sig = privKey.sign(resultHash)
            
    #Create Public Key
    verifyKey = PublicKey.from_private(privKey)

    outputs = [
        " ".join([str(i) for i in struct.unpack(">16I", attr)][-8:]),   #AtrributID
        " ".join([str(i) for i in struct.unpack(">16I", vc_value)][-8:]), #Verifiable Credential Wert
        write_signature_for_zokrates_cli(verifyKey, sig, resultHash), #Signatur des  Issuers 
    ]
    
    return outputs

