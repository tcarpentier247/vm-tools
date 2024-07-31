#!/usr/bin/env python3

import os
import random
import string
from struct import pack

def generate_random_hostid():
    characters = string.digits + 'abcdef'
    random_8cstr = ''.join(random.choice(characters) for _ in range(8))
    mtuple = ('0x', random_8cstr)
    random_hostid = ''.join(mtuple)
    return random_hostid

def write_hostid_to_file(hostid):
    hostid_bytes = pack("I",int(hostid,16))
    with open('/etc/hostid', 'wb') as file:
        file.write(hostid_bytes)

def main():
    hostid = generate_random_hostid()
    write_hostid_to_file(hostid)

    print("random hostid generated and updated : %s"%hostid)

if __name__ == "__main__":
    main()
