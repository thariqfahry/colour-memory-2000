#
# PNG to .mif converter
# Author: Thariq Fahry
#

import numpy as np, cv2 as cv

i = cv.imread("intro.png")

ROWS = i.shape[0]
COLS = i.shape[1]

header =f"""WIDTH=16;
DEPTH={ROWS*COLS};

ADDRESS_RADIX=UNS;
DATA_RADIX=HEX;

CONTENT BEGIN
"""

body = ""

footer = """
END;"""

for row in range(ROWS):
    for col in range(COLS):
        
        pixel = i[row][col]

        string565 = "{:05b}".format(round((pixel[2]/255)*31)) \
        + "{:06b}".format(round((pixel[1]/255)*63)) \
        + "{:05b}".format(round((pixel[0]/255)*31))

        stringhex = hex(int(string565, 2))

        body = body + f"{row*COLS + col}  :   {stringhex[2:]};\n"

with open("../intro.mif", "w") as f:
    f.write(header)
    f.write(body)
    f.write(footer)