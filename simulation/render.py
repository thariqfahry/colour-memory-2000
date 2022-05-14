#
# Functional Model Framebuffer Renderer
# Author: Thariq Fahry
#

# powershell -ExecutionPolicy ByPass -command "python render.py"

# NOTE
# we currently only render the BLUE channel in OpenCV


from time import sleep
import cv2 as cv, numpy as np

with open("write.txt", "r") as f:
    z = f.read()

if not z:
    raise ValueError("Framebuffer file empty.")

z = eval(z.replace("'","").replace("\n","").replace("{","[").replace("}","]"))
frames = np.float32(z)

for idx, frame in enumerate(frames):
    print(idx)
    #img = frame.reshape(320,240,3)
    if idx == 0:
        cv.imshow("preview",np.flip(frame[0]))
        cv.setWindowTitle("preview",f"{idx}/{len(frames)-1}")
    else:
        cv.setWindowTitle("preview",f"{idx}/{len(frames)-1}")
    #sleep(0.1)
    cv.waitKey()

cv.destroyAllWindows() 