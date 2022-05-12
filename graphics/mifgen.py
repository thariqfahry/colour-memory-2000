import numpy as np, cv2 as cv

header ="""WIDTH=16;
DEPTH=76800;

ADDRESS_RADIX=UNS;
DATA_RADIX=HEX;

CONTENT BEGIN
"""


footer = """
END;"""


i = cv.imread("gameover.png")

body = ""

for row in range(i.shape[0]):
    for col in range(i.shape[1]):

        pixel = i[row][col]

        string565 = "{:05b}".format(round((pixel[2]/255)*31)) \
        + "{:06b}".format(round((pixel[1]/255)*63)) \
        + "{:05b}".format(round((pixel[0]/255)*31))

        stringhex = hex(int(string565, 2))

        body = body + f"{row*240 + col}  :   {stringhex[2:]};\n"

with open("gameover.mif", "w") as f:
    f.write(header)
    f.write(body)
    f.write(footer)