# first stage
FROM python:3.9 AS builder 
ADD requirements.txt /

# install dependencies to local user directory (eg. /root/.local)
RUN pip install --upgrade pip 
RUN pip install --user -r requirements.txt

# second unnamed stage
FROM python:3.9-slim

# copy only the dependencies that are needed for our application and the sourse files
COPY --from=builder /root/.local /root/.local 

WORKDIR /root/cam 

ADD rtsp_cam.py /root/cam/ 
ADD stok_left.jpg /root/cam/ 
ADD stok_right.jpg /root/cam/ 

CMD [ "python3", "/root/cam/rtsp_cam.py"]