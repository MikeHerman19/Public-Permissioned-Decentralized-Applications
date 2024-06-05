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

if __name__ == "__main__":
    signKey = PrivateKey.from_rand()

    threshold = 990201510 #18.05.2001

    ######### VC Generation for the Zip Code ######### 

    attr_ID_Zip_1 = int.to_bytes(9, 64, "big") # Attr id for zip code
    vc_Zip_1 = int.to_bytes(45054, 64, "big") #ZipCode

    attr_ID_Zip_2 = int.to_bytes(9, 64, "big") # Attr id for zip code
    vc_Zip_2 = int.to_bytes(45054, 64, "big") #ZipCode

    attr_ID_Zip_3 = int.to_bytes(9, 64, "big") # Attr id for zip code
    vc_Zip_3 = int.to_bytes(45054, 64, "big") #ZipCode


    ######### VC Generation for the Date of Birth ######### 

    attr_ID_Dob_1 = int.to_bytes(24, 64, "big") # Attr id for dateofbirth
    vc_Dob_1 = int.to_bytes(895507110, 64, "big") # birthdate | 18.05.1998

    attr_ID_Dob_2 = int.to_bytes(24, 64, "big") # Attr id for dateofbirth
    vc_Dob_2 = int.to_bytes(895507110, 64, "big") # birthdate | 18.05.1998

    attr_ID_Dob_3 = int.to_bytes(24, 64, "big") # Attr id for dateofbirth
    vc_Dob_3 = int.to_bytes(895507110, 64, "big") # birthdate | 18.05.1998
    
    ######### Hash Generation for the Zip Code ######### 

    resultHash_Zip_1 = hashlib.sha256(b"".join([attr_ID_Zip_1[-32:], vc_Zip_1[-32:]])).digest()
    resultHash_Zip_1 += resultHash_Zip_1

    resultHash_Zip_2 = hashlib.sha256(b"".join([attr_ID_Zip_2[-32:], vc_Zip_2[-32:]])).digest()
    resultHash_Zip_2 += resultHash_Zip_2

    resultHash_Zip_3 = hashlib.sha256(b"".join([attr_ID_Zip_3[-32:], vc_Zip_3[-32:]])).digest()
    resultHash_Zip_3 += resultHash_Zip_3
    
    ######### Hash Generation for the DateofBirth ######### 

    resultHash_Dob_1 = hashlib.sha256(b"".join([attr_ID_Dob_1[-32:], vc_Dob_1[-32:]])).digest()
    resultHash_Dob_1 += resultHash_Dob_1

    resultHash_Dob_2 = hashlib.sha256(b"".join([attr_ID_Dob_2[-32:], vc_Dob_2[-32:]])).digest()
    resultHash_Dob_2 += resultHash_Dob_2

    resultHash_Dob_3 = hashlib.sha256(b"".join([attr_ID_Dob_3[-32:], vc_Dob_3[-32:]])).digest()
    resultHash_Dob_3 += resultHash_Dob_3

    ######### Signature Generation for Zip Code ######### 
    sig_Zip_1 = signKey.sign(resultHash_Zip_1)
    sig_Zip_2 = signKey.sign(resultHash_Zip_2)
    sig_Zip_3 = signKey.sign(resultHash_Zip_3)

    ######### Signature Generation for Date of Birth #########
    sig2_Dob_1 = signKey.sign(resultHash_Dob_1)
    sig2_Dob_2 = signKey.sign(resultHash_Dob_2)
    sig2_Dob_3 = signKey.sign(resultHash_Dob_3)
            
    #Create Public Key
    verifyKey = PublicKey.from_private(signKey)

    outputs = [
        "1337",         #Untergrenze
        "51966",        #Obergrenze
        str(threshold),
        " ".join([str(i) for i in struct.unpack(">16I", attr_ID_Zip_1)][-8:]),   #ZIP AtrributID
        " ".join([str(i) for i in struct.unpack(">16I", vc_Zip_1)][-8:]), #ZIP VC Value
        write_signature_for_zokrates_cli(verifyKey, sig_Zip_1, resultHash_Zip_1), #Signature of the Issuers 
        " ".join([str(i) for i in struct.unpack(">16I", attr_ID_Dob_1)][-8:]),
        " ".join([str(i) for i in struct.unpack(">16I", vc_Dob_1)][-8:]),
        write_signature_for_zokrates_cli(verifyKey, sig2_Dob_2, resultHash_Dob_2),
        " ".join([str(i) for i in struct.unpack(">16I", attr_ID_Zip_2)][-8:]),   #ZIP AtrributID
        " ".join([str(i) for i in struct.unpack(">16I", vc_Zip_2)][-8:]), #ZIP VC Value
        write_signature_for_zokrates_cli(verifyKey, sig_Zip_2, resultHash_Zip_2), #Signature of the Issuers 
        " ".join([str(i) for i in struct.unpack(">16I", attr_ID_Dob_2)][-8:]),
        " ".join([str(i) for i in struct.unpack(">16I", vc_Dob_2)][-8:]),
        write_signature_for_zokrates_cli(verifyKey, sig2_Dob_2, resultHash_Dob_2),
        " ".join([str(i) for i in struct.unpack(">16I", attr_ID_Zip_3)][-8:]),   #ZIP AtrributID
        " ".join([str(i) for i in struct.unpack(">16I", vc_Zip_3)][-8:]), #ZIP VC Value
        write_signature_for_zokrates_cli(verifyKey, sig_Zip_3, resultHash_Zip_3), #Signature of the Issuers 
        " ".join([str(i) for i in struct.unpack(">16I", attr_ID_Dob_3)][-8:]),
        " ".join([str(i) for i in struct.unpack(">16I", vc_Dob_3)][-8:]),
        write_signature_for_zokrates_cli(verifyKey, sig2_Dob_3, resultHash_Dob_3)
    ]
    
    sys.stdout.write(" ".join(outputs))

