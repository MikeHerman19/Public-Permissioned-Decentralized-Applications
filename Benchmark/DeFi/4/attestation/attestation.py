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

def zok_hash(lhs, rhs):
    preimage = int.to_bytes(lhs, 32, "big") + int.to_bytes(rhs, 32, "big")

    return hashlib.sha256(preimage).digest() 

def zok_out_u32(val):
    M0 = val.hex()[:64]
    M1 = val.hex()[64:]
    b0 = [str(int(M0[i:i+8], 16)) for i in range(0,len(M0), 8)]
    b1 = [str(int(M1[i:i+8], 16)) for i in range(0,len(M1), 8)]
    return " ".join(b0 + b1)

if __name__ == "__main__":
    signKey = PrivateKey.from_rand()

    ######## merkle tree ##########
    ### Trusted Borrower IDs:
    leaf0 = 1337
    leaf1 = 7234
    leaf2 = 1989
    leaf3 = 5196
    leaf4 = 1234
    leaf5 = 9999
    leaf6 = 3042
    leaf7 = 6123

    h0 = zok_hash(leaf0, leaf1)
    h1 = zok_hash(leaf2, leaf3)
    h2 = zok_hash(leaf4, leaf5)
    h3 = zok_hash(leaf6, leaf7)

    h00 = hashlib.sha256(h0 + h1).digest()
    h01 = hashlib.sha256(h2 + h3).digest()

    root = hashlib.sha256(h00 + h01).digest()

    msg_merkle1 = hashlib.sha256(int.to_bytes(leaf1, 64, "big")).digest()
    msg_merkle1 += msg_merkle1

    leaf0 = [0, 0, 0, 0, 0, 0, 0, leaf0]
    leaf1 = [0, 0, 0, 0, 0, 0, 0, leaf1]

    leaf8 = 1337
    leaf9 = 7234
    leaf10 = 1989
    leaf11 = 5196
    leaf12 = 1234
    leaf13 = 9999
    leaf14 = 3042
    leaf15 = 6123

    h4 = zok_hash(leaf8, leaf9)
    h5 = zok_hash(leaf10, leaf11)
    h6 = zok_hash(leaf12, leaf13)
    h7 = zok_hash(leaf14, leaf15)

    h10 = hashlib.sha256(h4 + h5).digest()
    h11 = hashlib.sha256(h6 + h7).digest()

    root = hashlib.sha256(h10 + h11).digest()

    msg_merkle2 = hashlib.sha256(int.to_bytes(leaf9, 64, "big")).digest()
    msg_merkle2 += msg_merkle2

    leaf8 = [0, 0, 0, 0, 0, 0, 0, leaf8]
    leaf9 = [0, 0, 0, 0, 0, 0, 0, leaf9]

    directionSelector = "1 0 0"

    path1 = [" ".join([str(i) for i in leaf0]), zok_out_u32(h1), zok_out_u32(h01)]
    path2 = [" ".join([str(i) for i in leaf8]), zok_out_u32(h5), zok_out_u32(h11)]

    sig_merkle1 = signKey.sign(msg_merkle1)
    sig_merkle2 = signKey.sign(msg_merkle2)

    ######### VC Generation for the Zip Code ######### 

    attr_ID_CreditScore_1 = int.to_bytes(17, 64, "big") # Attr id for zip code
    vc_CreditScore_1 = int.to_bytes(200, 64, "big") #ZipCode

    attr_ID_CreditScore_2 = int.to_bytes(17, 64, "big") # Attr id for zip code
    vc_CreditScore_2 = int.to_bytes(200, 64, "big") #ZipCode

    
    ######### Hash Generation for the Credit Score ######### 

    resultHash_CreditScore_1 = hashlib.sha256(b"".join([attr_ID_CreditScore_1[-32:], vc_CreditScore_1[-32:]])).digest()
    resultHash_CreditScore_1 += resultHash_CreditScore_1

    resultHash_CreditScore_2 = hashlib.sha256(b"".join([attr_ID_CreditScore_2[-32:], vc_CreditScore_2[-32:]])).digest()
    resultHash_CreditScore_2 += resultHash_CreditScore_2
    
    ######### Signature Generation for Zip Code ######### 
    sig_CreditScore_1 = signKey.sign(resultHash_CreditScore_1)
    sig_CreditScore_2 = signKey.sign(resultHash_CreditScore_2)
            
    #Create Public Key
    verifyKey = PublicKey.from_private(signKey)

    outputs = [
        "150",         #Untergrenze
        "250",        #Obergrenze
        " ".join([str(i) for i in struct.unpack(">16I", attr_ID_CreditScore_1)][-8:]),   #ZIP AtrributID
        " ".join([str(i) for i in struct.unpack(">16I", vc_CreditScore_1)][-8:]), #ZIP VC Value
        write_signature_for_zokrates_cli(verifyKey, sig_CreditScore_1, resultHash_CreditScore_1), #Signature of the Issuers 
        " ".join([str(i) for i in leaf1]) + " " + zok_out_u32(root) + " " + directionSelector + " " + " ".join(path1) + " ",
        write_signature_for_zokrates_cli(verifyKey, sig_merkle1, msg_merkle1),
        " ".join([str(i) for i in struct.unpack(">16I", attr_ID_CreditScore_2)][-8:]),   #ZIP AtrributID
        " ".join([str(i) for i in struct.unpack(">16I", vc_CreditScore_2)][-8:]), #ZIP VC Value
        write_signature_for_zokrates_cli(verifyKey, sig_CreditScore_2, resultHash_CreditScore_2), #Signature of the Issuers 
        " ".join([str(i) for i in leaf1]) + " " + zok_out_u32(root) + " " + directionSelector + " " + " ".join(path2) + " ",
        write_signature_for_zokrates_cli(verifyKey, sig_merkle2, msg_merkle2),
    ]
    
    sys.stdout.write(" ".join(outputs))
