FROM python:3.6-buster
RUN mkdir -p /work/backend
RUN mkdir -p /work/assets
WORKDIR /work/backend
RUN /usr/local/bin/python -m pip install --upgrade pip
RUN pip3 install virtualenv
COPY . .
RUN source env/bin/activate; pip install flask; pip install flask_cors; pip install functools; pip install json; pip install pyrebase; pip install firebase-admin; exit 0
EXPOSE 5000
CMD [ "python", "app.py" ]